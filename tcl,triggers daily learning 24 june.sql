-- Create database
CREATE DATABASE squirrel_db;

-- Use the created database
USE squirrel_db;

-- Squirrels table
CREATE TABLE Squirrels (
    squirrel_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    age INT,
    habitat VARCHAR(50) NOT NULL,
    color VARCHAR(20),
    UNIQUE KEY (name, habitat)  -- Ensuring unique squirrel names within habitats
);

-- Acorns table
CREATE TABLE Acorns (
    acorn_id INT PRIMARY KEY,
    squirrel_id INT,
    quantity INT,
    FOREIGN KEY (squirrel_id) REFERENCES Squirrels(squirrel_id)
);

-- SquirrelEvents table
CREATE TABLE SquirrelEvents (
    event_id INT PRIMARY KEY,
    squirrel_id INT,
    event_type VARCHAR(50),
    event_date DATE,
    description VARCHAR(200),
    FOREIGN KEY (squirrel_id) REFERENCES Squirrels(squirrel_id)
);

-- Inserting sample data into Squirrels table
INSERT INTO Squirrels (squirrel_id, name, age, habitat, color)
VALUES (1, 'Fluffy', 3, 'Forest', 'Brown'),
       (2, 'Nibbles', 2, 'Park', 'Gray'),
       (3, 'Whiskers', 4, 'Tree', 'Red');

-- TCL commands
-- Transaction to insert acorn data
START TRANSACTION;
INSERT INTO Acorns (acorn_id, squirrel_id, quantity) VALUES (1, 1, 50);
COMMIT;

-- Rollback example
START TRANSACTION;
INSERT INTO Acorns (acorn_id, squirrel_id, quantity) VALUES (2, 2, 30);
ROLLBACK;

-- Savepoint example
START TRANSACTION;
INSERT INTO Acorns (acorn_id, squirrel_id, quantity) VALUES (3, 3, 20);
SAVEPOINT A;
ROLLBACK TO A;

-- Triggers
-- Trigger to log squirrel updates
DELIMITER //
CREATE TRIGGER log_squirrel_update
AFTER UPDATE ON Squirrels
FOR EACH ROW
BEGIN
    INSERT INTO SquirrelEvents (squirrel_id, event_type, event_date, description)
    VALUES (OLD.squirrel_id, 'Update', CURDATE(), 'Squirrel details updated');
END //
DELIMITER ;

-- Trigger to update acorn quantity after each acorn gathering event
DELIMITER //
CREATE TRIGGER update_acorn_quantity
AFTER INSERT ON Acorns
FOR EACH ROW
BEGIN
    UPDATE Squirrels
    SET age = age + 1
    WHERE squirrel_id = NEW.squirrel_id;
END //
DELIMITER ;

-- Views
-- View to display squirrels in specific habitats
CREATE VIEW SquirrelsInPark AS
SELECT *
FROM Squirrels
WHERE habitat = 'Park';

-- View to show squirrel events
CREATE VIEW SquirrelEventsView AS
SELECT *
FROM SquirrelEvents;

-- Drop a view if it exists
DROP VIEW IF EXISTS SquirrelsInPark;

-- Examples of using TCL, Triggers, and Views with Squirrels database

-- Inserting squirrels into Squirrels table
INSERT INTO Squirrels (squirrel_id, name, age, habitat, color)
VALUES (4, 'Sandy', 5, 'Beach', 'Gray');

-- Update squirrel details
UPDATE Squirrels
SET age = 6
WHERE squirrel_id = 1;

-- Inserting acorns with transaction rollback example
START TRANSACTION;
INSERT INTO Acorns (acorn_id, squirrel_id, quantity) VALUES (4, 1, 10);
ROLLBACK;

-- Viewing squirrel events
SELECT * FROM SquirrelEventsView;

-- Dropping a view
DROP VIEW IF EXISTS SquirrelEventsView;


-- TCL (Transaction control language) Commands
/*
TCL commands are used to manage transactions, maintain ACID properties, and control the flow of data modifications.
TCL commands ensure the consistency and durability of data in a database.
For example, if an operation fails during a transaction, the transaction is rolled back.
When a transaction is committed, its changes are permanent, even if the system fails or restarts.
TCL commands also ensure that all operations within a transaction are executed as a single unit.
*/

-- -- commit
/*
Commit: Saves a transaction to the database
*/

-- rollback
/*
Rollback: Undoes a transaction or change that hasn't been saved to the database
*/

-- savepoint
/*
Savepoint: Temporarily saves a transaction for later rollback 
*/
-- here it will store that as a
-- after we can call that by rollback to a

-- any operation performed on table using dml
-- insert,delete,update every command is transaction 

/*
In mysql it is having auto commit so is doesnot make anysense transaction commands in mysql
for this we have to use command start transaction
*/

-- Triggers 

-- Trigger is a statement that a system executes automatically when there is any modification to the database
-- Triggers are used to specify certain integrity constraints and referential constraints that cannot be specified using the constraint mechanism of SQL

-- Trigers are 6 types 
/*
1)after insert -- activated after data is inserted into the table.
2)after update -- activated after data in the table is modified. 
3)after delete -- activated after data is deleted/removed from the table. 
4)before insert -- activated before data is inserted into the table. 
5)before update -- activated before data in the table is modified.
6)before delete --  activated before data is deleted/removed from the table. 
*/
-- Delimiters are necessary when creating stored procedures or triggers
-- Delimiters are used in MySQL to avoid conflicts with semicolons within SQL statements

-- "SQL Trigger for Logging Product Insertions"
-- after insert

/*
While SQL Workbench and many database management tools don't natively support BEFORE UPDATE and BEFORE DELETE triggers
*/

/*
													Uses of tirggers
Enforcing Data Integrity and Business Rules:

Data Validation: Triggers can validate data before it's inserted or updated, ensuring it adheres to specific rules. 
For example, a trigger can prevent negative product stock values or enforce a minimum age requirement for customer entries.

Maintaining Referential Integrity: Triggers can automatically maintain relationships between tables. 
When a record is deleted from a parent table (e.g., customers), a trigger can cascade the deletion to related child records (e.g., orders) or prevent deletion if dependent records exist.

Enforcing Business Logic: Triggers can implement complex business rules that might not be easily achievable with standard SQL statements. 
For instance, a trigger could automatically calculate discounts based on order amount or apply loyalty point adjustments upon successful purchases.

security:Triggers can enforce data access restrictions or security checks on specific events within the database.

Performance Impact: Triggers can introduce overhead to data manipulation operations. Analyze their impact on performance and optimize them if necessary.

Trigger Order: When using multiple triggers, their execution order can be important. Define the order in which triggers fire to ensure desired results.

*/

											-- advance triggers 
-- Advanced triggers can be used to implement row-level security restrictions. For example, a trigger can filter data displayed to a user based on their role:
/*
DELIMITER //
CREATE TRIGGER filter_products_by_role
BEFORE SELECT ON products
FOR EACH ROW
BEGIN
  DECLARE user_role VARCHAR(50);

  -- Get user role from session variable or another source
  SET user_role = 'user';  -- Replace with logic to get actual role

  IF user_role = 'admin' THEN
    SET FOUND = 1;  -- Allow admin to see all products
  ELSEIF user_role = 'user' AND NEW.location = 'Mumbai' THEN
    SET FOUND = 1;  -- Allow users to see only Mumbai products
  ELSE
    SET FOUND = 0;  -- Block other roles from seeing data
  END IF;
END //
DELIMITER ;
*/

# SQL Triggers

# Trigger to update status in payment table after an order is completed
CREATE TRIGGER update_payment_status
AFTER UPDATE ON orders
FOR EACH ROW
WHEN NEW.status = 'completed'
BEGIN
    UPDATE payment
    SET status = 'completed'
    WHERE order_id = NEW.id;
END;

# Trigger to check stock availability before inserting an order
CREATE TRIGGER check_stock_availability
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE stock_count INT;
    SELECT stock INTO stock_count
    FROM products
    WHERE id = NEW.product_id;

    IF stock_count < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock available';
    END IF;
END;

# Trigger to update stock after an order is placed
CREATE TRIGGER update_stock_after_order
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock = stock - NEW.quantity
    WHERE id = NEW.product_id;
END;

# SQL Views

# Create a view that displays the customers with their corresponding orders
CREATE VIEW customers_with_orders AS
SELECT customers.id AS customer_id, customers.name AS customer_name, orders.id AS order_id, orders.date AS order_date
FROM customers
JOIN orders ON customers.id = orders.customer_id;

# Create or Replace View to show payment details with order and customer information
CREATE OR REPLACE VIEW payment_details AS
SELECT payments.id AS payment_id, payments.amount, payments.status, orders.id AS order_id, customers.name AS customer_name
FROM payments
JOIN orders ON payments.order_id = orders.id
JOIN customers ON orders.customer_id = customers.id;

# Drop View if it exists
DROP VIEW IF EXISTS payment_details;


