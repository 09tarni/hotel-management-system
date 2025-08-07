const mysql = require('mysql2/promise');
const express = require('express');
const path = require('path');
const cors = require('cors');
const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('frontend'));

// Database connection pool
const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: 'root@123',
  database: 'HotelManagementSystems',
    port: 3305,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Test database connection
pool.getConnection()
    .then(connection => {
        console.log('✅ Connected to MySQL database!');
        connection.release();
    })
    .catch(err => {
        console.error('❌ Database connection failed:', err);
    });

// Debug middleware to log requests
app.use((req, res, next) => {
    console.log(`${req.method} ${req.path}`, req.body);
    next();
});

// Modified API endpoint with corrected MySQL syntax
app.get('/api/customers', async (req, res) => {
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
                END as BookingStatus
            FROM CUSTOMERS c
            LEFT JOIN (
                SELECT b1.*
                FROM BOOKINGS b1
                INNER JOIN (
                    SELECT Customer_ID, MAX(CheckIn_Date) as LastCheckIn
                    FROM BOOKINGS
                    GROUP BY Customer_ID
                ) b2 ON b1.Customer_ID = b2.Customer_ID 
                AND b1.CheckIn_Date = b2.LastCheckIn
            ) b ON c.Customer_ID = b.Customer_ID
            LEFT JOIN ROOMS r ON b.Room_ID = r.Room_ID
            ORDER BY 
                CASE 
                    WHEN b.CheckOut_Date >= CURDATE() THEN 1
                    WHEN b.CheckOut_Date < CURDATE() THEN 2
                    ELSE 3
                END,
                CASE 
                    WHEN b.CheckIn_Date IS NULL THEN 1
                    ELSE 0
                END,
                b.CheckIn_Date DESC,
                c.Name`;

        const [customers] = await pool.query(query);
        
        const formattedCustomers = customers.map(customer => {
            const hasBooking = customer.Room_ID != null;
            const isActiveBooking = customer.BookingStatus === 'Active';
            
            return {
                name: customer.Name,
                contactInfo: {
                    email: customer.Email,
                    phone: customer.Phone_No
                },
                booking: hasBooking ? {
                    roomInfo: `Room ${customer.Room_ID} (${customer.Room_Type})`,
                    checkIn: customer.CheckIn_Date ? 
                        new Date(customer.CheckIn_Date).toLocaleDateString('en-GB') : '-',
                    checkOut: customer.CheckOut_Date ? 
                        new Date(customer.CheckOut_Date).toLocaleDateString('en-GB') : '-',
                    status: customer.BookingStatus
                } : null
            };
        });

        console.log('Formatted customers:', formattedCustomers);
        res.json(formattedCustomers);
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: 'Failed to fetch customers' });
    }
});

// Simple API endpoint to fetch all employees
app.get('/api/employees', async (req, res) => {
    try {
        const [employees] = await pool.query(`
            SELECT 
                e.*,
                r.Role_Name
            FROM EMPLOYEES e
            LEFT JOIN ROLES r ON e.Role_ID = r.Role_ID
            ORDER BY e.E_Name
        `);
        console.log('Fetched employees:', employees); // Debug log
        res.json(employees);
    } catch (error) {
        console.error('Error fetching employees:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Error fetching employees',
            error: error.message 
        });
    }
});

// API endpoint to fetch all bookings
app.get('/api/bookings', async (req, res) => {
    try {
        const [bookings] = await pool.query(`
            SELECT 
                b.*,
                c.Name as CustomerName,
                c.Email as CustomerEmail,
                c.Phone_No as CustomerPhone,
                r.Room_Type
            FROM BOOKINGS b
            JOIN CUSTOMERS c ON b.Customer_ID = c.Customer_ID
            JOIN ROOMS r ON b.Room_ID = r.Room_ID
            ORDER BY b.CheckIn_Date DESC
        `);
        console.log('Fetched bookings:', bookings); // Debug log
        res.json(bookings);
    } catch (error) {
        console.error('Error fetching bookings:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Error fetching bookings',
            error: error.message 
        });
    }
});

// API endpoint to fetch available rooms
app.get('/api/rooms', async (req, res) => {
    try {
        const [rooms] = await pool.query(`
            SELECT r.*, rt.Price_per_Night 
            FROM ROOMS r
            JOIN ROOM_TYPES rt ON r.Room_Type = rt.Room_Type
            ORDER BY r.Room_ID
        `);
        console.log('Fetched rooms:', rooms); // Debug log
        res.json(rooms);
    } catch (error) {
        console.error('Error fetching rooms:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Error fetching rooms',
            error: error.message 
        });
    }
});

// Booking endpoint
app.post('/api/bookings', async (req, res) => {
    let connection;
    try {
        const {
            customerName,
            customerEmail,
            customerPhone,
            checkInDate,
            checkOutDate,
            roomType,
            amount,
            transactionId
        } = req.body;

        connection = await pool.getConnection();
        
        // Start transaction
        await connection.beginTransaction();

        // 1. Insert or get customer
        const [existingCustomer] = await connection.query(
            'SELECT Customer_ID FROM CUSTOMERS WHERE Email = ?',
            [customerEmail]
        );

        let customerId;
        if (existingCustomer.length > 0) {
            customerId = existingCustomer[0].Customer_ID;
        } else {
            // Get next Customer_ID
            const [maxCustomerId] = await connection.query('SELECT MAX(Customer_ID) as maxId FROM CUSTOMERS');
            customerId = (maxCustomerId[0].maxId || 110) + 1;

            // Insert new customer
            await connection.query(
                'INSERT INTO CUSTOMERS (Customer_ID, Name, Email, Phone_No) VALUES (?, ?, ?, ?)',
                [customerId, customerName, customerEmail, customerPhone]
            );
        }

        // 2. Get available room of requested type
        const [availableRoom] = await connection.query(
            `SELECT r.Room_ID FROM ROOMS r 
             WHERE r.Room_Type = ? AND r.Room_ID NOT IN (
                SELECT Room_ID FROM BOOKINGS 
                WHERE (CheckIn_Date <= ? AND CheckOut_Date >= ?) 
                OR (CheckIn_Date <= ? AND CheckOut_Date >= ?)
             ) LIMIT 1`,
            [roomType, checkOutDate, checkInDate, checkInDate, checkOutDate]
        );

        if (!availableRoom.length) {
            throw new Error('No rooms available for selected dates');
        }

        // 3. Create booking
        const [maxBookingId] = await connection.query('SELECT MAX(Booking_ID) as maxId FROM BOOKINGS');
        const newBookingId = (maxBookingId[0].maxId || 300) + 1;

        await connection.query(
            'INSERT INTO BOOKINGS (Booking_ID, Customer_ID, Room_ID, CheckIn_Date, CheckOut_Date) VALUES (?, ?, ?, ?, ?)',
            [newBookingId, customerId, availableRoom[0].Room_ID, checkInDate, checkOutDate]
        );

        // 4. Create payment record
        const [maxPaymentId] = await connection.query('SELECT MAX(Payment_ID) as maxId FROM PAYMENTS');
        const newPaymentId = (maxPaymentId[0].maxId || 500) + 1;

        // Get UPI Method_ID
        const [upiMethod] = await connection.query('SELECT Method_ID FROM PAYMENT_METHODS WHERE Method_Name = ?', ['UPI']);
        
        await connection.query(
            'INSERT INTO PAYMENTS (Payment_ID, Booking_ID, Amount, Method_ID, Date) VALUES (?, ?, ?, ?, CURDATE())',
            [newPaymentId, newBookingId, amount, upiMethod[0].Method_ID]
        );

        // 5. Create PAYS record
        await connection.query(
            'INSERT INTO PAYS (Customer_ID, Payment_ID) VALUES (?, ?)',
            [customerId, newPaymentId]
        );

        // Commit transaction
        await connection.commit();

        res.json({
            success: true,
            message: 'Booking confirmed successfully',
            bookingId: newBookingId,
            customerId: customerId
        });

    } catch (error) {
        if (connection) {
            await connection.rollback();
        }
        console.error('Booking error:', error);
        res.status(500).json({
            success: false,
            message: error.message
        });
    } finally {
        if (connection) connection.release();
    }
});

// API endpoint to fetch booking details
app.get('/api/bookings/:id', async (req, res) => {
    let connection;
    try {
        const bookingId = req.params.id;
        
        connection = await pool.getConnection();
        const query = `
            SELECT 
                b.Booking_ID,
                b.CheckIn_Date,
                b.CheckOut_Date,
                c.Customer_ID,
                c.Name as CustomerName,
                c.Email,
                c.Phone_No,
                r.Room_ID,
                r.Room_Type,
                rt.Price_per_Night,
                p.Payment_ID,
                p.Amount,
                pm.Method_Name as PaymentMethod
            FROM BOOKINGS b
            JOIN CUSTOMERS c ON b.Customer_ID = c.Customer_ID
            JOIN ROOMS r ON b.Room_ID = r.Room_ID
            JOIN ROOM_TYPES rt ON r.Room_Type = rt.Room_Type
            LEFT JOIN PAYMENTS p ON b.Booking_ID = p.Booking_ID
            LEFT JOIN PAYMENT_METHODS pm ON p.Method_ID = pm.Method_ID
            WHERE b.Booking_ID = ?
        `;

        const [booking] = await connection.query(query, [bookingId]);
        
        if (booking.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Booking not found'
            });
        }

        res.json(booking[0]);

    } catch (error) {
        console.error('Error fetching booking details:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Error fetching booking details',
            error: error.message 
        });
    } finally {
        if (connection) {
            connection.release();
        }
    }
});

// Start server
app.listen(port, () => {
  console.log(`🚀 Server running on http://localhost:${port}`);
});
