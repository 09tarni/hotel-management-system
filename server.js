require("dotenv").config();

const express = require("express");
const mysql = require("mysql2/promise");
const cors = require("cors");
const path = require("path");

const app = express();

/* =========================
   Middleware
========================= */
app.use(cors());
app.use(express.json());
app.use(express.static("frontend"));

/* =========================
   Environment Config
========================= */
const PORT = process.env.PORT || 3000;

/* =========================
   Database Connection Pool
========================= */
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

/* Test DB connection */
(async () => {
  try {
    const connection = await pool.getConnection();
    console.log("✅ Connected to MySQL database");
    connection.release();
  } catch (err) {
    console.error("❌ Database connection failed:", err.message);
  }
})();

/* =========================
   DEBUG LOGGER
========================= */
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

/* =========================
   API ROUTES
========================= */

/* ---------- Customers ---------- */
app.get("/api/customers", async (req, res) => {
  try {
    const query = `
      SELECT 
        c.Customer_ID,
        c.Name,
        c.Email,
        c.Phone_No,
        b.Room_ID,
        b.CheckIn_Date,
        b.CheckOut_Date,
        r.Room_Type,
        CASE 
          WHEN b.CheckOut_Date >= CURDATE() THEN 'Active'
          WHEN b.CheckOut_Date < CURDATE() THEN 'Past'
          ELSE 'None'
        END AS BookingStatus
      FROM CUSTOMERS c
      LEFT JOIN (
        SELECT b1.*
        FROM BOOKINGS b1
        INNER JOIN (
          SELECT Customer_ID, MAX(CheckIn_Date) AS LastCheckIn
          FROM BOOKINGS
          GROUP BY Customer_ID
        ) b2 
        ON b1.Customer_ID = b2.Customer_ID 
        AND b1.CheckIn_Date = b2.LastCheckIn
      ) b ON c.Customer_ID = b.Customer_ID
      LEFT JOIN ROOMS r ON b.Room_ID = r.Room_ID
      ORDER BY 
        CASE 
          WHEN b.CheckOut_Date >= CURDATE() THEN 1
          WHEN b.CheckOut_Date < CURDATE() THEN 2
          ELSE 3
        END,
        b.CheckIn_Date DESC;
    `;

    const [rows] = await pool.query(query);

    const formatted = rows.map(c => ({
      name: c.Name,
      contactInfo: {
        email: c.Email,
        phone: c.Phone_No
      },
      booking: c.Room_ID
        ? {
            roomInfo: `Room ${c.Room_ID} (${c.Room_Type})`,
            checkIn: c.CheckIn_Date
              ? new Date(c.CheckIn_Date).toLocaleDateString("en-GB")
              : "-",
            checkOut: c.CheckOut_Date
              ? new Date(c.CheckOut_Date).toLocaleDateString("en-GB")
              : "-",
            status: c.BookingStatus
          }
        : null
    }));

    res.json(formatted);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch customers" });
  }
});

/* ---------- Employees ---------- */
app.get("/api/employees", async (req, res) => {
  try {
    const [employees] = await pool.query(`
      SELECT e.*, r.Role_Name
      FROM EMPLOYEES e
      LEFT JOIN ROLES r ON e.Role_ID = r.Role_ID
      ORDER BY e.E_Name
    `);

    res.json(employees);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/* ---------- Rooms ---------- */
app.get("/api/rooms", async (req, res) => {
  try {
    const [rooms] = await pool.query(`
      SELECT r.*, rt.Price_per_Night
      FROM ROOMS r
      JOIN ROOM_TYPES rt ON r.Room_Type = rt.Room_Type
      ORDER BY r.Room_ID
    `);

    res.json(rooms);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/* ---------- Bookings ---------- */
app.get("/api/bookings", async (req, res) => {
  try {
    const [bookings] = await pool.query(`
      SELECT 
        b.*,
        c.Name AS CustomerName,
        c.Email,
        c.Phone_No,
        r.Room_Type
      FROM BOOKINGS b
      JOIN CUSTOMERS c ON b.Customer_ID = c.Customer_ID
      JOIN ROOMS r ON b.Room_ID = r.Room_ID
      ORDER BY b.CheckIn_Date DESC
    `);

    res.json(bookings);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/* ---------- Create Booking ---------- */
app.post("/api/bookings", async (req, res) => {
  let connection;

  try {
    const {
      customerName,
      customerEmail,
      customerPhone,
      checkInDate,
      checkOutDate,
      roomType,
      amount
    } = req.body;

    connection = await pool.getConnection();
    await connection.beginTransaction();

    // Check / insert customer
    const [existing] = await connection.query(
      "SELECT Customer_ID FROM CUSTOMERS WHERE Email = ?",
      [customerEmail]
    );

    let customerId;

    if (existing.length > 0) {
      customerId = existing[0].Customer_ID;
    } else {
      const [[max]] = await connection.query(
        "SELECT MAX(Customer_ID) AS maxId FROM CUSTOMERS"
      );

      customerId = (max.maxId || 110) + 1;

      await connection.query(
        "INSERT INTO CUSTOMERS (Customer_ID, Name, Email, Phone_No) VALUES (?, ?, ?, ?)",
        [customerId, customerName, customerEmail, customerPhone]
      );
    }

    // Get available room
    const [room] = await connection.query(
      `
      SELECT Room_ID FROM ROOMS
      WHERE Room_Type = ?
      AND Room_ID NOT IN (
        SELECT Room_ID FROM BOOKINGS
        WHERE (CheckIn_Date <= ? AND CheckOut_Date >= ?)
      )
      LIMIT 1
      `,
      [roomType, checkOutDate, checkInDate]
    );

    if (!room.length) {
      throw new Error("No rooms available");
    }

    const [[maxBooking]] = await connection.query(
      "SELECT MAX(Booking_ID) AS maxId FROM BOOKINGS"
    );

    const bookingId = (maxBooking.maxId || 300) + 1;

    await connection.query(
      "INSERT INTO BOOKINGS VALUES (?, ?, ?, ?, ?)",
      [bookingId, customerId, room[0].Room_ID, checkInDate, checkOutDate]
    );

    await connection.commit();

    res.json({
      success: true,
      bookingId,
      customerId
    });
  } catch (err) {
    if (connection) await connection.rollback();
    res.status(500).json({ success: false, message: err.message });
  } finally {
    if (connection) connection.release();
  }
});

/* =========================
   SERVER START
========================= */
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
