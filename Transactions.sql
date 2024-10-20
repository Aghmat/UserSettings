-- Enable some advanced options
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Create a schema for our application
CREATE SCHEMA zapper
    GO

-- Create Customers table
CREATE TABLE zapper.customers (
                                  customer_id INT IDENTITY(1,1) PRIMARY KEY,
                                  first_name NVARCHAR(50) NOT NULL,
                                  last_name NVARCHAR(50) NOT NULL,
                                  email NVARCHAR(100) NOT NULL,
                                  phone_number NVARCHAR(20),
                                  date_of_birth DATE,
                                  address_line1 NVARCHAR(100),
                                  address_line2 NVARCHAR(100),
                                  city NVARCHAR(50),
                                  state NVARCHAR(50),
                                  postal_code NVARCHAR(20),
                                  country NVARCHAR(50),
                                  created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
                                  updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
                                  is_active BIT NOT NULL DEFAULT 1,
                                  CONSTRAINT UQ_customers_email UNIQUE (email)
);

-- Create Merchants table
CREATE TABLE zapper.merchants (
                                  merchant_id INT IDENTITY(1,1) PRIMARY KEY,
                                  merchant_name NVARCHAR(100) NOT NULL,
                                  merchant_email NVARCHAR(100) NOT NULL,
                                  merchant_phone NVARCHAR(20),
                                  business_type NVARCHAR(50),
                                  tax_id NVARCHAR(50),
                                  address_line1 NVARCHAR(100),
                                  address_line2 NVARCHAR(100),
                                  city NVARCHAR(50),
                                  state NVARCHAR(50),
                                  postal_code NVARCHAR(20),
                                  country NVARCHAR(50),
                                  created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
                                  updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
                                  is_active BIT NOT NULL DEFAULT 1,
                                  CONSTRAINT UQ_merchants_email UNIQUE (merchant_email)
);

-- Create QR_Codes table
CREATE TABLE zapper.qr_codes (
                                 qr_code_id INT IDENTITY(1,1) PRIMARY KEY,
                                 merchant_id INT NOT NULL,
                                 qr_code_data NVARCHAR(MAX) NOT NULL,
                                 qr_code_type NVARCHAR(20) NOT NULL,
                                 amount DECIMAL(10, 2),
                                 currency NCHAR(3),
                                 expiration_date DATETIME2,
                                 is_active BIT NOT NULL DEFAULT 1,
                                 created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
                                 updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
                                 CONSTRAINT FK_qr_codes_merchants FOREIGN KEY (merchant_id) REFERENCES zapper.merchants(merchant_id)
);

-- Create Payment_Methods table
CREATE TABLE zapper.payment_methods (
                                        payment_method_id INT IDENTITY(1,1) PRIMARY KEY,
                                        method_name NVARCHAR(50) NOT NULL,
                                        method_type NVARCHAR(20) NOT NULL,
                                        is_active BIT NOT NULL DEFAULT 1,
                                        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
                                        updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
                                        CONSTRAINT UQ_payment_methods_name UNIQUE (method_name)
);

-- Insert some common payment methods
INSERT INTO zapper.payment_methods (method_name, method_type) VALUES
                                                                  ('Visa', 'CREDIT_CARD'),
                                                                  ('Mastercard', 'CREDIT_CARD'),
                                                                  ('American Express', 'CREDIT_CARD'),
                                                                  ('Discover', 'CREDIT_CARD'),
                                                                  ('PayPal', 'DIGITAL_WALLET'),
                                                                  ('Apple Pay', 'DIGITAL_WALLET'),
                                                                  ('Google Pay', 'DIGITAL_WALLET');

-- Create Transactions table
CREATE TABLE zapper.transactions (
                                     transaction_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                                     customer_id INT NOT NULL,
                                     merchant_id INT NOT NULL,
                                     qr_code_id INT NOT NULL,
                                     payment_method_id INT NOT NULL,
                                     amount DECIMAL(10, 2) NOT NULL,
                                     currency NCHAR(3) NOT NULL,
                                     transaction_date DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
                                     status NVARCHAR(20) NOT NULL,
                                     description NVARCHAR(255),
                                     is_refunded BIT NOT NULL DEFAULT 0,
                                     refund_transaction_id BIGINT,
                                     created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
                                     updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
                                     CONSTRAINT FK_transactions_customers FOREIGN KEY (customer_id) REFERENCES zapper.customers(customer_id),
                                     CONSTRAINT FK_transactions_merchants FOREIGN KEY (merchant_id) REFERENCES zapper.merchants(merchant_id),
                                     CONSTRAINT FK_transactions_qr_codes FOREIGN KEY (qr_code_id) REFERENCES zapper.qr_codes(qr_code_id),
                                     CONSTRAINT FK_transactions_payment_methods FOREIGN KEY (payment_method_id) REFERENCES zapper.payment_methods(payment_method_id),
                                     CONSTRAINT FK_transactions_refunds FOREIGN KEY (refund_transaction_id) REFERENCES zapper.transactions(transaction_id)
);

-- Create Transaction_Items table for itemized transactions
CREATE TABLE zapper.transaction_items (
                                          item_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                                          transaction_id BIGINT NOT NULL,
                                          item_name NVARCHAR(100) NOT NULL,
                                          quantity INT NOT NULL,
                                          unit_price DECIMAL(10, 2) NOT NULL,
                                          total_price DECIMAL(10, 2) NOT NULL,
                                          created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
                                          CONSTRAINT FK_transaction_items_transactions FOREIGN KEY (transaction_id) REFERENCES zapper.transactions(transaction_id)
);

-- Create Fees table to track fees for each transaction
CREATE TABLE zapper.fees (
                             fee_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                             transaction_id BIGINT NOT NULL,
                             fee_type NVARCHAR(50) NOT NULL,
                             fee_amount DECIMAL(10, 2) NOT NULL,
                             created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
                             CONSTRAINT FK_fees_transactions FOREIGN KEY (transaction_id) REFERENCES zapper.transactions(transaction_id)
);

-- Create indexes for better query performance
CREATE NONCLUSTERED INDEX IX_transactions_customer_id ON zapper.transactions (customer_id);
CREATE NONCLUSTERED INDEX IX_transactions_merchant_id ON zapper.transactions (merchant_id);
CREATE NONCLUSTERED INDEX IX_transactions_transaction_date ON zapper.transactions (transaction_date);
CREATE NONCLUSTERED INDEX IX_transactions_status ON zapper.transactions (status);

-- Create a view for transaction summaries
CREATE VIEW zapper.vw_transaction_summary AS
SELECT
    t.transaction_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    m.merchant_name,
    pm.method_name AS payment_method,
    t.amount,
    t.currency,
    t.transaction_date,
    t.status,
    COALESCE(f.total_fees, 0) AS total_fees
FROM zapper.transactions t
         JOIN zapper.customers c ON t.customer_id = c.customer_id
         JOIN zapper.merchants m ON t.merchant_id = m.merchant_id
         JOIN zapper.payment_methods pm ON t.payment_method_id = pm.payment_method_id
         LEFT JOIN (
    SELECT transaction_id, SUM(fee_amount) AS total_fees
    FROM zapper.fees
    GROUP BY transaction_id
) f ON t.transaction_id = f.transaction_id;

-- Create a stored procedure for generating a merchant report
CREATE PROCEDURE zapper.sp_generate_merchant_report
    @merchant_id INT,
    @start_date DATETIME2,
    @end_date DATETIME2
AS
BEGIN
    SET NOCOUNT ON;

SELECT
    m.merchant_name,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(t.amount) AS total_amount,
    AVG(t.amount) AS average_transaction_amount,
    SUM(f.fee_amount) AS total_fees,
    SUM(t.amount) - SUM(f.fee_amount) AS net_amount
FROM zapper.transactions t
         JOIN zapper.merchants m ON t.merchant_id = m.merchant_id
         LEFT JOIN zapper.fees f ON t.transaction_id = f.transaction_id
WHERE
    t.merchant_id = @merchant_id
  AND t.transaction_date BETWEEN @start_date AND @end_date
  AND t.status = 'COMPLETED'
GROUP BY m.merchant_name;

END;
GO

-- Create a trigger to update the 'updated_at' column
CREATE TRIGGER zapper.trg_transactions_update
    ON zapper.transactions
    AFTER UPDATE
              AS
BEGIN
    SET NOCOUNT ON;
UPDATE zapper.transactions
SET updated_at = SYSDATETIME()
    FROM zapper.transactions t
    INNER JOIN inserted i ON t.transaction_id = i.transaction_id;
END;
GO

-- Create a user-defined function to calculate the age of a customer
CREATE FUNCTION zapper.fn_calculate_age
(
    @date_of_birth DATE
)
    RETURNS INT
AS
BEGIN
RETURN DATEDIFF(YEAR, @date_of_birth, GETDATE()) -
       CASE
           WHEN (MONTH(@date_of_birth) > MONTH(GETDATE())) OR
                (MONTH(@date_of_birth) = MONTH(GETDATE()) AND DAY(@date_of_birth) > DAY(GETDATE()))
               THEN 1
           ELSE 0
           END
END;
GO

-- Example of using the function
-- SELECT customer_id, first_name, last_name, zapper.fn_calculate_age(date_of_birth) AS age
-- FROM zapper.customers;