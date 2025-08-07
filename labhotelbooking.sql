CREATE DATABASE HotelManagementSystem;
USE HotelManagementSystem;
CREATE TABLE ROOMS (
    Room_ID INT PRIMARY KEY,
    Room_Type VARCHAR(50),
    Price_per_Night DECIMAL(10,2)
);
CREATE TABLE CUSTOMERS (
    Customer_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone_No VARCHAR(15)
);
CREATE TABLE EMPLOYEES (
    Employee_ID INT PRIMARY KEY,
    E_Name VARCHAR(100),
    Salary DECIMAL(10,2),
    Shift_Timing VARCHAR(50),
    Role VARCHAR(50)              -- Manager, Security, Receptionist, Housekeeping
);
CREATE TABLE BOOKINGS (
    Booking_ID INT PRIMARY KEY,
    Customer_ID INT,
    Room_ID INT,
    CheckIn_Date DATE,
    CheckOut_Date DATE,
    FOREIGN KEY (Customer_ID) REFERENCES CUSTOMERS(Customer_ID),
    FOREIGN KEY (Room_ID) REFERENCES ROOMS(Room_ID)
);
CREATE TABLE PAYMENTS (
    Payment_ID INT PRIMARY KEY,
    Booking_ID INT,
    Amount DECIMAL(10,2),
    Payment_Method VARCHAR(50),
    Date DATE,
    FOREIGN KEY (Booking_ID) REFERENCES BOOKINGS(Booking_ID)
);
CREATE TABLE MANAGED_BY (
    Employee_ID INT,
    Room_ID INT,
    PRIMARY KEY (Employee_ID, Room_ID),
    FOREIGN KEY (Employee_ID) REFERENCES EMPLOYEES(Employee_ID),
    FOREIGN KEY (Room_ID) REFERENCES ROOMS(Room_ID)
);

CREATE TABLE HANDLES (
    Employee_ID INT,
    Booking_ID INT,
    PRIMARY KEY (Employee_ID, Booking_ID),
    FOREIGN KEY (Employee_ID) REFERENCES EMPLOYEES(Employee_ID),
    FOREIGN KEY (Booking_ID) REFERENCES BOOKINGS(Booking_ID)
);

CREATE TABLE PAYS (
    Customer_ID INT,
    Payment_ID INT,
    PRIMARY KEY (Customer_ID, Payment_ID),
    FOREIGN KEY (Customer_ID) REFERENCES CUSTOMERS(Customer_ID),
    FOREIGN KEY (Payment_ID) REFERENCES PAYMENTS(Payment_ID)
);

INSERT INTO ROOMS VALUES 
(201, 'Single', 1000.00),
(202, 'Double', 2000.00),
(203, 'Suite', 5000.00),
(204, 'Deluxe', 3500.00),
(205, 'Single', 1200.00),
(206, 'Double', 2200.00),
(207, 'Suite', 5500.00);

INSERT INTO CUSTOMERS VALUES 
(111, 'Alice Johnson', 'alice@example.com', '9876543210'),
(112, 'Bob Smith', 'bob@example.com', '9876543211'),
(113, 'Charlie Brown', 'charlie@example.com', '9876543212'),
(114, 'David White', 'david@example.com', '9876543213'),
(115, 'Emma Watson', 'emma@example.com', '9876543214'),
(116, 'Frank Green', 'frank@example.com', '9876543215'),
(117, 'Grace Hall', 'grace@example.com', '9876543216');

INSERT INTO EMPLOYEES VALUES 
(21, 'Tarni khatri', 30000.00, 'Day', 'Manager'),
(22, 'Tanya roy', 20000.00, 'Night', 'Receptionist'),
(23, 'Tanya gupta', 18000.00, 'Day', 'Security'),
(24, 'Tarun jagrit', 15000.00, 'Night', 'Housekeeping'),
(25, 'Tanushree nadella', 22000.00, 'Day', 'Receptionist'),
(26, 'Tejashree Venkatesh', 25000.00, 'Night', 'Manager'),
(27, 'Tejas kharche', 17000.00, 'Day', 'Security');

INSERT INTO BOOKINGS VALUES 
(300, 111, 201, '2024-02-01', '2024-02-05'),
(301, 112, 202, '2024-02-02', '2024-02-06'),
(302, 113, 203, '2024-02-03', '2024-02-07'),
(303, 114, 204, '2024-02-04', '2024-02-08'),
(304, 115, 205, '2024-02-05', '2024-02-09'),
(305, 116, 206, '2024-02-06', '2024-02-10'),
(306, 117, 207, '2024-02-07', '2024-02-11');

INSERT INTO PAYMENTS VALUES 
(500, 300, 5000.00, 'Credit Card', '2024-02-01'),
(501, 301, 8000.00, 'Debit Card', '2024-02-02'),
(502, 302, 25000.00, 'UPI', '2024-02-03'),
(503, 303, 14000.00, 'Cash', '2024-02-04'),
(504, 304, 4800.00, 'Credit Card', '2024-02-05'),
(505, 305, 8800.00, 'Net Banking', '2024-02-06'),
(506, 306, 27500.00, 'UPI', '2024-02-07');

INSERT INTO MANAGED_BY (Employee_ID, Room_ID) VALUES 
(21, 201), (21, 202), (22, 203), (22, 204), (23, 205), (23, 206), (24, 207);

INSERT INTO HANDLES (Employee_ID, Booking_ID) VALUES 
(21, 300), (21, 301), (22, 302), (22, 303), (23, 304), (23, 305), (24, 306);

INSERT INTO PAYS (Customer_ID, Payment_ID) VALUES 
(111, 500), (112, 501), (113, 502), (114, 503), (115, 504), (116, 505), (117, 506);


ALTER TABLE PAYMENTS DROP FOREIGN KEY payments_ibfk_1;
ALTER TABLE PAYMENTS DROP PRIMARY KEY;
DESC PAYMENTS;


ALTER TABLE PAYMENTS ADD PRIMARY KEY (Payment_ID);
ALTER TABLE PAYMENTS ADD CONSTRAINT payments_ibfk_1 
FOREIGN KEY (Booking_ID) REFERENCES BOOKINGS(Booking_ID);
DESC PAYMENTS;

SELECT * FROM ROOMS;
SELECT * FROM CUSTOMERS;
SELECT * FROM EMPLOYEES;
SELECT * FROM Reservations;
SELECT * FROM PAYMENTS;
SELECT * FROM MANAGED_BY;
SELECT * FROM HANDLES;
SELECT * FROM CUSTOMERS;


-- 1️⃣ Add a New Column
ALTER TABLE CUSTOMERS ADD Address VARCHAR(255);

-- 2️⃣ Modify Column Data Type
ALTER TABLE CUSTOMERS MODIFY Phone_No VARCHAR(20);

-- 3️⃣ Rename Column
ALTER TABLE EMPLOYEES CHANGE E_Name Employee_Name VARCHAR(100);

-- 4️⃣ Rename Table
ALTER TABLE BOOKINGS RENAME TO RESERVATIONS;

-- 5️⃣ Drop a Column
ALTER TABLE EMPLOYEES DROP COLUMN Shift_Timing;

-- 6️⃣ Add a Primary Key
ALTER TABLE PAYS ADD PRIMARY KEY (Customer_ID, Payment_ID);

-- 7️⃣ Drop Primary Key
ALTER TABLE PAYMENTS DROP PRIMARY KEY;

-- 8️⃣ Add a Foreign Key
ALTER TABLE PAYMENTS ADD CONSTRAINT fk_booking
FOREIGN KEY (Booking_ID) REFERENCES RESERVATIONS(Booking_ID);
desc payments;

-- 9️⃣ Drop Foreign Key
ALTER TABLE PAYMENTS DROP FOREIGN KEY fk_booking;
tf
-- 🔟 Modify Column Default Value
ALTER TABLE EMPLOYEES ALTER Salary SET DEFAULT 20000;

-- 1️⃣1️⃣ Set Column to NOT NULL
ALTER TABLE CUSTOMERS MODIFY Email VARCHAR(100) NOT NULL;

-- 1️⃣2️⃣ Set Column to AUTO_INCREMENT
ALTER TABLE EMPLOYEES MODIFY Employee_ID INT AUTO_INCREMENT;

-- 1️⃣3️⃣ Add a Unique Constraint
ALTER TABLE CUSTOMERS ADD CONSTRAINT unique_email UNIQUE (Email);



SELECT * FROM CUSTOMERS WHERE Name = 'Alice Johnson';


SELECT * FROM RESERVATIONS WHERE CheckIn_Date > '2024-02-03';


SELECT * FROM EMPLOYEES WHERE Salary > 20000;


SELECT * FROM ROOMS WHERE Room_Type = 'Suite';

SELECT * FROM PAYMENTS WHERE Payment_Method = 'UPI';


SELECT * FROM CUSTOMERS WHERE Phone_No LIKE '9876543%';


SELECT * FROM EMPLOYEES WHERE Role IN ('Manager', 'Receptionist');


SELECT * FROM ROOMS WHERE Price_per_Night BETWEEN 2000 AND 5000;

SELECT * FROM RESERVATIONS WHERE CheckOut_Date BETWEEN '2024-02-01' AND '2024-02-29';

SELECT * FROM CUSTOMERS WHERE Name LIKE '%a%';

-- 1️⃣1️⃣ Fetch all employees except those with role 'Security'
SELECT * FROM EMPLOYEES WHERE Role <> 'Security';

-- 1️⃣2️⃣ Fetch all bookings ordered by check-in date (earliest first)
SELECT * FROM RESERVATIONS ORDER BY CheckIn_Date ASC;



-- 1️⃣4️⃣ Fetch the highest salary among employees
SELECT MAX(Salary) AS Highest_Salary FROM EMPLOYEES;

-- 1️⃣5️⃣ Fetch the total amount of all payments made
SELECT SUM(Amount) AS Total_Revenue FROM PAYMENTS;

-- 1️⃣6️⃣ Fetch the count of all rooms available
SELECT COUNT(*) AS Total_Rooms FROM ROOMS;

-- 1️⃣7️⃣ Fetch the average room price
SELECT AVG(Price_per_Night) AS Average_Price FROM ROOMS;

-- 1️⃣8️⃣ Fetch all employees with salaries above average salary
SELECT * FROM EMPLOYEES WHERE Salary > (SELECT AVG(Salary) FROM EMPLOYEES);

-- 1️⃣9️⃣ Fetch the employee who manages room 201
SELECT * FROM EMPLOYEES WHERE Employee_ID IN 
(SELECT Employee_ID FROM MANAGED_BY WHERE Room_ID = 201);


                                    -- Additional Commands


-- Using AND & OR
SELECT * FROM EMPLOYEES WHERE Salary > 20000 AND Role = 'Manager';
SELECT * FROM EMPLOYEES WHERE Salary > 20000 OR Role = 'Security';

-- Using IN
SELECT * FROM EMPLOYEES WHERE Role IN ('Manager', 'Receptionist', 'Security');
SELECT * FROM PAYMENTS WHERE Payment_Method IN ('UPI', 'Credit Card');

--  Using NOT IN
SELECT * FROM EMPLOYEES WHERE Role NOT IN ('Security', 'Housekeeping');

-- using null ,not null
SELECT * FROM CUSTOMERS WHERE Email IS NULL;
SELECT * FROM CUSTOMERS WHERE Email IS NOT NULL;

-- using distinct keyword:
SELECT DISTINCT Role FROM EMPLOYEES;

-- using limit
SELECT * FROM EMPLOYEES ORDER BY Salary DESC LIMIT 3;  -- Top 3 highest salaries
SELECT * FROM CUSTOMERS LIMIT 5;  -- First 5 customers

 -- Using EXISTS and not exists
 SELECT * FROM EMPLOYEES WHERE EXISTS 
(SELECT * FROM MANAGED_BY WHERE MANAGED_BY.Employee_ID = EMPLOYEES.Employee_ID);

SELECT * FROM CUSTOMERS WHERE NOT EXISTS 
(SELECT * FROM RESERVATIONS WHERE RESERVATIONS.Customer_ID = CUSTOMERS.Customer_ID);

-- using like
SELECT * FROM CUSTOMERS WHERE Name LIKE 'A%';  -- Starts with 'A'
SELECT * FROM CUSTOMERS WHERE Name LIKE '%son';  -- Ends with 'son'
SELECT * FROM CUSTOMERS WHERE Name LIKE '_a%';  -- Second letter is 'a'
SELECT * FROM CUSTOMERS WHERE Name LIKE '%a%';  -- Contains 'a'

-- using subQuery
SELECT * FROM EMPLOYEES WHERE Salary > 
(SELECT AVG(Salary) FROM EMPLOYEES);

-- using top clause
SELECT *
FROM EMPLOYEES
ORDER BY Salary DESC
LIMIT 5;

-- using ORDER BY:
SELECT * FROM EMPLOYEES ORDER BY Salary DESC;

-- using group by:
SELECT Role, COUNT(*) AS NumberOfEmployeess
FROM EMPLOYEES
GROUP BY Role;

SELECT * FROM employees WHERE e_name LIKE 't%';

-- USING RAND FUNCTION
SELECT * FROM EMPLOYEES ORDER BY RAND() LIMIT 1;

