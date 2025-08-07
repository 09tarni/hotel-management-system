CREATE DATABASE HotelManagementSystems;
USE HotelManagementSystems;
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


-- NORMALIZING TABLES:

DROP TABLE MANAGED_BY;

CREATE TABLE EMPLOYEE_ROOM (
    Employee_ID INT,
    Room_ID INT,
    PRIMARY KEY (Employee_ID, Room_ID),
    FOREIGN KEY (Employee_ID) REFERENCES EMPLOYEES(Employee_ID),
    FOREIGN KEY (Room_ID) REFERENCES ROOMS(Room_ID)
);

INSERT INTO EMPLOYEE_ROOM VALUES 
(21, 201), (21, 202), (22, 203), (22, 204), (23, 205), (23, 206), (24, 207);

DROP TABLE HANDLES;

CREATE TABLE EMPLOYEE_BOOKING (
    Employee_ID INT,
    Booking_ID INT,
    PRIMARY KEY (Employee_ID, Booking_ID),
    FOREIGN KEY (Employee_ID) REFERENCES EMPLOYEES(Employee_ID),
    FOREIGN KEY (Booking_ID) REFERENCES BOOKINGS(Booking_ID)
);

INSERT INTO EMPLOYEE_BOOKING VALUES 
(21, 300), (21, 301), (22, 302), (22, 303), (23, 304), (23, 305), (24, 306);

CREATE TABLE ROLES (
    Role_ID INT PRIMARY KEY AUTO_INCREMENT,
    Role_Name VARCHAR(50) UNIQUE
);

ALTER TABLE EMPLOYEES ADD COLUMN Role_ID INT;
ALTER TABLE EMPLOYEES ADD FOREIGN KEY (Role_ID) REFERENCES ROLES(Role_ID);


INSERT INTO ROLES (Role_Name) VALUES
	('Manager'), ('Security'), ('Receptionist'), ('Housekeeping');
UPDATE EMPLOYEES SET Role_ID = (SELECT Role_ID FROM ROLES WHERE Role_Name = 'Manager') WHERE Role = 'Manager';
ALTER TABLE EMPLOYEES DROP COLUMN Role;

desc employees;
select * from employees;

CREATE TABLE PAYMENT_METHODS (
    Method_ID INT PRIMARY KEY AUTO_INCREMENT,
    Method_Name VARCHAR(50) UNIQUE
);
ALTER TABLE PAYMENTS ADD COLUMN Method_ID INT;
ALTER TABLE PAYMENTS ADD FOREIGN KEY (Method_ID) REFERENCES PAYMENT_METHODS(Method_ID);

INSERT INTO PAYMENT_METHODS (Method_Name) VALUES
	('Credit Card'), ('UPI'), ('Debit Card'), ('Cash'), ('Net Banking');
    
UPDATE PAYMENTS SET Method_ID = (SELECT Method_ID FROM PAYMENT_METHODS WHERE Method_Name = 'Credit Card') 
WHERE Payment_Method = 'Credit Card';
ALTER TABLE PAYMENTS DROP COLUMN Payment_Method;

SELECT * FROM PAYMENTS;
select * from payment_methods;
SELECT * FROM PAYS;

CREATE TABLE ROOM_TYPES (
    Room_Type VARCHAR(20) PRIMARY KEY,
    Price_per_Night DECIMAL(10,2)
);
INSERT INTO ROOM_TYPES (Room_Type, Price_per_Night) VALUES
('Single', 1000.00),
('Double', 2000.00),
('Suite', 5000.00),
('Deluxe', 3500.00);

ALTER TABLE ROOMS DROP COLUMN PRICE_PER_NIGHT;
ALTER TABLE ROOMS ADD constraint fk_room_type 
foreign key(ROOM_TYPE) REFERENCES ROOM_TYPES(Room_type);
select * from room_types;
desc room_types;

SELECT DISTINCT Customer_ID, Name, Email, Phone_No 
FROM CUSTOMERS 
WHERE Customer_ID IN (SELECT Customer_ID FROM PAYS);

SELECT ROOM_ID FROM ROOMS WHERE ROOM_ID NOT IN (SELECT ROOM_ID FROM BOOKINGS);

SELECT E_Name FROM EMPLOYEES  
WHERE Employee_ID IN (SELECT Employee_ID FROM EMPLOYEE_ROOM WHERE Room_ID = 201);


SELECT * FROM ROOMS 
WHERE Room_ID IN 
    (SELECT Room_ID FROM bookings
     WHERE Customer_ID = 111);



                                         -- view commands

                    -- view table commands;
CREATE VIEW View_Rooms AS 
SELECT Room_ID, Room_Type
FROM ROOMS;
select * from view_rooms;

desc employees;
CREATE VIEW View_Employees AS  
SELECT Employee_ID, E_Name AS Employee_Name, Salary  
FROM EMPLOYEES;
SELECT * FROM View_Employees;


CREATE VIEW View_BookingDetails AS
SELECT 
    R.Booking_ID, 
    C.Customer_ID, C.Name AS Customer_Name, C.Email, C.Phone_No, C.Address, 
    RM.Room_ID, RM.Room_Type, RM.Price_per_Night, 
    R.CheckIn_Date, R.CheckOut_Date
FROM RESERVATIONS R
JOIN CUSTOMERS C ON R.Customer_ID = C.Customer_ID
JOIN ROOMS RM ON R.Room_ID = RM.Room_ID;

select * from View_BookingDetails;


CREATE VIEW View_EmployeeBookingHandling AS
SELECT 
    E.Employee_ID, E.E_Name AS Employee_Name, E.Role, E.Salary,
    R.Booking_ID, C.Customer_ID, C.Name AS Customer_Name, C.Email, 
    RM.Room_ID, RM.Room_Type, R.CheckIn_Date, R.CheckOut_Date
FROM EMPLOYEES E
JOIN HANDLES H ON E.Employee_ID = H.Employee_ID
JOIN RESERVATIONS R ON H.Booking_ID = R.Booking_ID
JOIN CUSTOMERS C ON R.Customer_ID = C.Customer_ID
JOIN ROOMS RM ON R.Room_ID = RM.Room_ID;

select * from View_EmployeeBookingHandling;



                                  -- indexing commands
CREATE INDEX idx_customer_email ON CUSTOMERS(Email);
SHOW INDEX FROM customers;

CREATE INDEX idx_employee_salary ON EMPLOYEES(Salary);
SHOW INDEX FROM employees;

CREATE INDEX idx_payment_method ON PAYMENTS(Payment_Method);
SHOW INDEX FROM Payments;

CREATE INDEX idx_checkin_date ON RESERVATIONS(CheckIn_Date);
SHOW INDEX FROM RESERVATIONS;









-- stored procedure
DELIMITER //

CREATE PROCEDURE AddCustomer(
    IN cust_id INT,
    IN cust_name VARCHAR(100),
    IN cust_email VARCHAR(100),
    IN cust_phone VARCHAR(15)
)
BEGIN
    INSERT INTO CUSTOMERS (Customer_ID, Name, Email, Phone_No) 
    VALUES (cust_id, cust_name, cust_email, cust_phone);
END //

DELIMITER ;
CALL AddCustomer(118, 'Hannah Black', 'hannah@example.com', '9876543217');


DELIMITER //
CREATE PROCEDURE CalculateSquare(INOUT num INT)
BEGIN
    SET num = num * num;
END //
DELIMITER ;

SET @value = 5;
CALL CalculateSquare(@value);
SELECT @value;



DELIMITER //
CREATE PROCEDURE GetCustomerEmail(IN cID INT, OUT cEmail VARCHAR(100))
BEGIN
    SELECT Email INTO cEmail 
    FROM CUSTOMERS 
    WHERE Customer_ID = cID;
END //
DELIMITER ;
CALL GetCustomerEmail(101, @email);
SELECT @email;


DELIMITER //
CREATE PROCEDURE CalculateTotalPayment(IN bID INT, OUT totalAmount DECIMAL(10,2))
BEGIN
    SELECT SUM(Amount) INTO totalAmount 
    FROM PAYMENTS 
    WHERE Booking_ID = bID;
END //
DELIMITER ;
CALL CalculateTotalPayment(300, @total);
SELECT @total;


DROP PROCEDURE IF EXISTS UpdateRoomPrice;

show procedure status where Db='HotelManagementSystems';