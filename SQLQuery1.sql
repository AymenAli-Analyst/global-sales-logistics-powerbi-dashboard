-- DDL for the dbo.producat table, exactly as seen in the image.
-- Note: ProductID is shown as nullable in the image. In a typical database design,
-- ProductID would commonly be defined as NOT NULL and a PRIMARY KEY for data integrity.
CREATE TABLE dbo.producat (
    ProductID NVARCHAR(50) NULL,
    ProductName NVARCHAR(50) NULL,
    Category NVARCHAR(50) NULL,
    UnitCost FLOAT NULL,
    UnitPrice FLOAT NULL,
    DateAdded DATE NULL,
    SupplierCountry NVARCHAR(50) NULL,
    StockQuantity SMALLINT NULL
);

-- Query 1: Category Profitability and Inventory Value Overview
-- This query calculates the total potential revenue, cost, profit, estimated profit margin percentage,
-- and total stock quantity for each product category.
SELECT
    Category,
    SUM(ISNULL(UnitPrice, 0) * ISNULL(StockQuantity, 0)) AS TotalPotentialRevenue,
    SUM(ISNULL(UnitCost, 0) * ISNULL(StockQuantity, 0)) AS TotalPotentialCost,
    SUM((ISNULL(UnitPrice, 0) - ISNULL(UnitCost, 0)) * ISNULL(StockQuantity, 0)) AS TotalPotentialProfit,
    CASE
        WHEN SUM(ISNULL(UnitPrice, 0) * ISNULL(StockQuantity, 0)) > 0
        THEN (SUM((ISNULL(UnitPrice, 0) - ISNULL(UnitCost, 0)) * ISNULL(StockQuantity, 0)) * 100.0) / SUM(ISNULL(UnitPrice, 0) * ISNULL(StockQuantity, 0))
        ELSE 0
    END AS EstimatedProfitMarginPercentage,
    SUM(ISNULL(StockQuantity, 0)) AS TotalStockQuantityInCategory
FROM
    dbo.producat
GROUP BY
    Category
ORDER BY
    TotalPotentialProfit DESC;

-- Query 2: Product Stock Level Analysis and Reorder Classification
-- This query lists products, their stock quantity, and classifies them into different
-- stock level categories based on arbitrary thresholds, identifying potential reorder candidates.
SELECT
    ProductID,
    ProductName,
    Category,
    StockQuantity,
    CASE
        WHEN StockQuantity IS NULL THEN 'Unknown Stock'
        WHEN StockQuantity <= 10 THEN 'Low Stock - Reorder Needed'
        WHEN StockQuantity > 10 AND StockQuantity <= 50 THEN 'Medium Stock'
        WHEN StockQuantity > 50 AND StockQuantity <= 200 THEN 'High Stock'
        ELSE 'Very High Stock'
    END AS StockLevelStatus,
    UnitCost,
    UnitPrice
FROM
    dbo.producat
ORDER BY
    StockQuantity ASC;

-- Query 3: Monthly Product Additions and Average Pricing Trend
-- This query analyzes the trend of new products added over time, showing the number of
-- new products, their total initial stock quantity, and their average unit price by month and year.
SELECT
    FORMAT(DateAdded, 'yyyy-MM') AS MonthAdded, -- Use TO_CHAR(DateAdded, 'YYYY-MM') for PostgreSQL/Oracle, strftime('%Y-%m', DateAdded) for SQLite
    COUNT(ProductID) AS NumberOfNewProducts,
    SUM(ISNULL(StockQuantity, 0)) AS TotalInitialStockForNewProducts,
    AVG(ISNULL(UnitPrice, 0)) AS AverageUnitPriceForNewProducts
FROM
    dbo.producat
WHERE
    DateAdded IS NOT NULL
GROUP BY
    FORMAT(DateAdded, 'yyyy-MM')
ORDER BY
    MonthAdded ASC;




    -- SQL for creating the table structure exactly as seen in the image.
-- No derived or calculated columns are included here, as per instructions.
CREATE TABLE dbo.Fact_Sales (
    CustomerID          NVARCHAR(50) NULL,
    FirstName           NVARCHAR(50) NULL,
    LastName            NVARCHAR(50) NULL,
    Email               NVARCHAR(50) NULL,
    Country             NVARCHAR(50) NULL,
    City                NVARCHAR(50) NULL,
    SignupDate          DATE         NULL,
    CustomerSegment     NVARCHAR(50) NULL,
    Newsletter_Opt_In   BIT          NULL
);

-- Note: The absence of an explicit Primary Key is inferred from the screenshot.
-- If CustomerID is intended to be unique, you might add a primary key constraint.
-- For example: ALTER TABLE dbo.Fact_Sales ADD PRIMARY KEY (CustomerID);
-- However, based *only* on the screenshot, no PK is explicitly shown.


-- Business SQL Query 1: Customer Distribution and Newsletter Opt-in Rate by Country and Customer Segment
-- This query provides insights into where customers are located and their engagement with newsletters
-- based on their segment, useful for targeted marketing strategies.
SELECT
    Country,
    CustomerSegment,
    COUNT(CustomerID) AS TotalCustomers,
    SUM(CASE WHEN Newsletter_Opt_In = 1 THEN 1 ELSE 0 END) AS OptedInCustomers,
    -- Calculate Opt-in Rate as a percentage
    CAST(SUM(CASE WHEN Newsletter_Opt_In = 1 THEN 1 ELSE 0 END) AS DECIMAL(10,2)) * 100.0 / COUNT(CustomerID) AS OptInRatePercentage
FROM
    dbo.Fact_Sales
GROUP BY
    Country,
    CustomerSegment
ORDER BY
    Country,
    CustomerSegment;

-- Business SQL Query 2: Monthly New Customer Sign-ups Trend by Customer Segment
-- This query helps to track customer acquisition over time and identify which segments are growing
-- or declining month-over-month.
SELECT
    FORMAT(SignupDate, 'yyyy-MM') AS SignupMonth, -- Formats the date to 'YYYY-MM' for monthly grouping
    CustomerSegment,
    COUNT(CustomerID) AS NewCustomersCount
FROM
    dbo.Fact_Sales
WHERE
    SignupDate IS NOT NULL -- Exclude rows without a signup date for accurate monthly analysis
GROUP BY
    FORMAT(SignupDate, 'yyyy-MM'),
    CustomerSegment
ORDER BY
    SignupMonth,
    CustomerSegment;

-- Business SQL Query 3: Top 5 Countries with the Most Newsletter Opt-ins
-- This query identifies the countries where customers are most engaged with newsletter subscriptions,
-- which could inform regional marketing focus for email campaigns.
SELECT TOP 5
    Country,
    COUNT(CustomerID) AS TotalCustomersInCountry,
    SUM(CASE WHEN Newsletter_Opt_In = 1 THEN 1 ELSE 0 END) AS OptedInCustomersInCountry,
    -- Calculate Opt-in Rate for the country
    CAST(SUM(CASE WHEN Newsletter_Opt_In = 1 THEN 1 ELSE 0 END) AS DECIMAL(10,2)) * 100.0 / COUNT(CustomerID) AS CountryOptInRatePercentage
FROM
    dbo.Fact_Sales
GROUP BY
    Country
ORDER BY
    OptedInCustomersInCountry DESC;


    -- Create the dbo.Order table
-- Note: 'Order' is a reserved keyword in SQL, so it's best practice to enclose it in square brackets.
-- We assume OrderID is intended to be the primary key, thus NOT NULL, even if the screenshot shows 'null' as an option.
CREATE TABLE dbo.[Order] (
    OrderID nvarchar(50) NOT NULL PRIMARY KEY,
    CustomerID nvarchar(50) NULL,
    OrderDate date NULL,
    SalesChannel nvarchar(50) NULL,
    PaymentMethod nvarchar(50) NULL,
    OrderStatus nvarchar(50) NULL,
    ShippingCountry nvarchar(50) NULL,
    ShippingCost float NULL
);


-- Query 1: Total Orders and Average Shipping Cost by Sales Channel
-- This query helps to understand which sales channels are most active and their associated shipping costs.
SELECT
    SalesChannel,
    COUNT(OrderID) AS TotalOrders,
    AVG(ShippingCost) AS AverageShippingCostPerOrder
FROM
    dbo.[Order]
GROUP BY
    SalesChannel
ORDER BY
    TotalOrders DESC;

-- Query 2: Monthly Order Volume and Total Shipping Cost for a Specific Country
-- This query provides insights into sales performance and shipping expenses over time for a particular region.
SELECT
    FORMAT(OrderDate, 'yyyy-MM') AS OrderMonth, -- Formats the date to 'YYYY-MM' for grouping by month
    COUNT(OrderID) AS MonthlyOrderCount,
    SUM(ShippingCost) AS TotalMonthlyShippingCost
FROM
    dbo.[Order]
WHERE
    ShippingCountry = 'USA' -- Example: You can change 'USA' to any desired country
GROUP BY
    FORMAT(OrderDate, 'yyyy-MM')
ORDER BY
    OrderMonth;

-- Query 3: Percentage of Orders by Order Status
-- This query helps monitor the distribution of order statuses (e.g., 'Completed', 'Pending', 'Cancelled')
-- to identify potential bottlenecks or areas for improvement in order fulfillment.
SELECT
    OrderStatus,
    COUNT(OrderID) AS OrdersInThisStatus,
    CAST(COUNT(OrderID) AS float) * 100 / SUM(COUNT(OrderID)) OVER () AS PercentageOfTotalOrders
FROM
    dbo.[Order]
GROUP BY
    OrderStatus
ORDER BY
    PercentageOfTotalOrders DESC;




CREATE TABLE dbo.Order_item (
    OrderItemID NVARCHAR(50) NULL,
    OrderID NVARCHAR(50) NULL,
    ProductID NVARCHAR(50) NULL,
    Quantity TINYINT NULL,
    UnitPriceAtSale FLOAT NULL,
    DiscountPercent TINYINT NULL
);



CREATE VIEW dbo.OrderItem_CalculatedDetails AS
SELECT
    oi.OrderItemID,
    oi.OrderID,
    oi.ProductID,
    oi.Quantity,
    oi.UnitPriceAtSale,
    oi.DiscountPercent,
    -- Calculate the gross amount before discount
    ISNULL(oi.Quantity, 0) * ISNULL(oi.UnitPriceAtSale, 0.0) AS GrossLineAmount,
    -- Calculate the actual discount amount for the line item
    ISNULL(oi.Quantity, 0) * ISNULL(oi.UnitPriceAtSale, 0.0) * (ISNULL(CAST(oi.DiscountPercent AS FLOAT), 0.0) / 100.0) AS LineDiscountAmount,
    -- Calculate the net amount after discount for the line item
    ISNULL(oi.Quantity, 0) * ISNULL(oi.UnitPriceAtSale, 0.0) * (1 - ISNULL(CAST(oi.DiscountPercent AS FLOAT), 0.0) / 100.0) AS NetLineAmount
FROM
    dbo.Order_item AS oi;





CREATE VIEW dbo.Order_Summary AS
SELECT
    oid.OrderID,
    COUNT(oid.OrderItemID) AS NumberOfItems,
    SUM(oid.GrossLineAmount) AS TotalGrossOrderAmount,
    SUM(oid.LineDiscountAmount) AS TotalOrderDiscountAmount,
    SUM(oid.NetLineAmount) AS TotalNetOrderRevenue
FROM
    dbo.OrderItem_CalculatedDetails AS oid
GROUP BY
    oid.OrderID;





CREATE VIEW dbo.Discounted_Items_Analysis AS
SELECT
    oi.OrderItemID,
    oi.OrderID,
    oi.ProductID,
    oi.UnitPriceAtSale,
    oi.DiscountPercent,
    -- Calculate the effective unit price after discount
    ISNULL(oi.UnitPriceAtSale, 0.0) * (1 - ISNULL(CAST(oi.DiscountPercent AS FLOAT), 0.0) / 100.0) AS EffectiveUnitPrice,
    -- Flag to easily identify if an item was discounted
    CASE
        WHEN ISNULL(oi.DiscountPercent, 0) > 0 THEN 'Yes'
        ELSE 'No'
    END AS IsDiscounted
FROM
    dbo.Order_item AS oi
WHERE
    ISNULL(oi.DiscountPercent, 0) > 0; -- Only include items with an actual discount







    -- DDL for the dbo.payment table
-- Note: PaymentID is inferred as NOT NULL and PRIMARY KEY, which is standard for ID columns,
-- even though the image indicates it could be NULL. For a robust data model, IDs should be primary keys.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

CREATE TABLE dbo.payment (
    PaymentID       nvarchar(50)    NOT NULL PRIMARY KEY, -- Assumed Primary Key and NOT NULL
    OrderID         nvarchar(50)    NULL,
    PaymentDate     date            NULL,
    Amount          float           NULL,
    Currency        nvarchar(50)    NULL,
    PaymentStatus   nvarchar(50)    NULL
);

-- Optional: Example of inserting some dummy data for testing the queries
/*
INSERT INTO dbo.payment (PaymentID, OrderID, PaymentDate, Amount, Currency, PaymentStatus) VALUES
('P001', 'O101', '2023-01-15', 120.50, 'USD', 'Completed'),
('P002', 'O102', '2023-01-16', 75.00, 'EUR', 'Pending'),
('P003', 'O101', '2023-01-15', 120.50, 'USD', 'Completed'), -- Duplicate for order but distinct payment
('P004', 'O103', '2023-02-01', 300.25, 'GBP', 'Completed'),
('P005', 'O104', '2023-02-05', 45.99, 'USD', 'Failed'),
('P006', 'O105', '2023-02-10', 500.00, 'EUR', 'Completed'),
('P007', 'O106', '2023-03-01', 150.00, 'USD', 'Completed'),
('P008', 'O107', '2023-03-02', 25.00, 'USD', 'Refunded'),
('P009', 'O108', '2023-03-05', 80.00, 'GBP', 'Completed'),
('P010', 'O109', '2023-03-10', 1200.00, 'EUR', 'Completed');
*/





SELECT
        Currency,
        PaymentStatus,
        SUM(Amount) AS TotalAmount
    FROM
        dbo.payment
    WHERE
        PaymentDate IS NOT NULL AND Amount IS NOT NULL -- Exclude records with missing date or amount for meaningful aggregation
    GROUP BY
        Currency,
        PaymentStatus
    ORDER BY
        Currency,
        PaymentStatus;



SELECT
        FORMAT(PaymentDate, 'yyyy-MM') AS PaymentMonth,
        COUNT(PaymentID) AS NumberOfPayments,
        SUM(Amount) AS TotalMonthlyAmount,
        AVG(Amount) AS AveragePaymentAmount
    FROM
        dbo.payment
    WHERE
        PaymentDate IS NOT NULL AND Amount IS NOT NULL -- Exclude records with missing date or amount
    GROUP BY
        FORMAT(PaymentDate, 'yyyy-MM')
    ORDER BY
        PaymentMonth;




SELECT
        CASE
            WHEN Amount IS NULL THEN 'Unknown'
            WHEN Amount < 50.0 THEN 'Small Payment'
            WHEN Amount >= 50.0 AND Amount < 200.0 THEN 'Medium Payment'
            WHEN Amount >= 200.0 AND Amount < 1000.0 THEN 'Large Payment'
            ELSE 'Very Large Payment'
        END AS PaymentAmountCategory,
        PaymentStatus,
        COUNT(PaymentID) AS NumberOfPayments,
        SUM(Amount) AS TotalAmountInCategory
    FROM
        dbo.payment
    WHERE
        PaymentStatus IS NOT NULL -- Ensure a valid status for grouping
    GROUP BY
        CASE
            WHEN Amount IS NULL THEN 'Unknown'
            WHEN Amount < 50.0 THEN 'Small Payment'
            WHEN Amount >= 50.0 AND Amount < 200.0 THEN 'Medium Payment'
            WHEN Amount >= 200.0 AND Amount < 1000.0 THEN 'Large Payment'
            ELSE 'Very Large Payment'
        END,
        PaymentStatus
    ORDER BY
        PaymentAmountCategory, PaymentStatus;















































