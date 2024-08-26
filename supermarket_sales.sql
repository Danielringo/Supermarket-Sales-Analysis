CREATE SCHEMA Supermarket_sales;
USE supermarket_sales;
SELECT * FROM supermarket;
CREATE TABLE `supermarket` (
  `input_date` date DEFAULT NULL,
  `customer_name` text,
  `Gender` text,
  `Domicile` text,
  `member_code` text,
  `Product_id` text,
  `Category` text,
  `product_name` text,
  `Barcode` text,
  `Quantity` int DEFAULT NULL,
  `item_price` int DEFAULT NULL,
  `Tax` text,
  `member_point` text,
  `total_payment` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


UPDATE supermarket
SET `Input Date` = STR_TO_DATE(`Input Date`, '%d/%m/%Y');

ALTER TABLE supermarket_sales.supermarket
MODIFY COLUMN `Input Date` Date;

-- RENAME COLUMN INPUT DATE
ALTER TABLE supermarket_sales.supermarket
RENAME COLUMN `Input Date` TO input_date;

-- RENAME COLUMN CUSTOMER NAME
ALTER TABLE supermarket_sales.supermarket
RENAME COLUMN `Customer Name` TO customer_name;

-- RENAME COLUMN MEMBER CODE
ALTER TABLE supermarket_sales.supermarket
RENAME COLUMN `Member Code` TO member_code;


ALTER TABLE supermarket_sales.supermarket
RENAME COLUMN `Product ID` TO Product_id;


ALTER TABLE supermarket_sales.supermarket
RENAME COLUMN `Name of Product` TO product_name;


ALTER TABLE supermarket_sales.supermarket
RENAME COLUMN `Price Item` TO item_price;


ALTER TABLE supermarket_sales.supermarket
RENAME COLUMN `Member Point` TO member_point;


ALTER TABLE supermarket_sales.supermarket
RENAME COLUMN `Total Payment` TO total_payment;


SELECT * FROM supermarket
ORDER BY total_payment DESC;


    
 WITH sales_data AS (
    SELECT
        input_date,
        Category,
        Gender,
        Domicile,
        member_code,
        product_name,
        Quantity,
        item_price,
        total_payment,
        CASE 
            WHEN Tax LIKE '%%' THEN CAST(REPLACE(Tax, '%', '') AS DECIMAL) / 100 * total_payment
            ELSE 0 
        END AS tax_amount
    FROM
        supermarket
),
total_sales_by_category AS (
    SELECT
        Category,
        SUM(total_payment) AS total_sales,
        SUM(tax_amount) AS total_tax
    FROM
        sales_data
    GROUP BY
        Category
),
avg_purchase_by_gender AS (
    SELECT
        Gender,
        AVG(total_payment) AS avg_purchase_amount
    FROM
        sales_data
    GROUP BY
        Gender
),
monthly_sales AS (
    SELECT
        DATE_FORMAT(input_date, '%Y-%m') AS month,
        SUM(CASE WHEN member_code IS NOT NULL THEN total_payment ELSE 0 END) AS member_sales
    FROM
        sales_data
    GROUP BY
        month
),
top_products AS (
    SELECT
        product_name,
        SUM(total_payment) AS total_sales,
        SUM(Quantity) AS total_quantity
    FROM
        sales_data
    GROUP BY
        product_name
    ORDER BY
        total_sales DESC
    LIMIT 5
),
sales_performance AS (
    SELECT
        Domicile,
        Category,
        SUM(total_payment) AS total_sales
    FROM
        sales_data
    GROUP BY
        Domicile, Category
    ORDER BY
        total_sales DESC
)
SELECT
    cat.Category,
    cat.total_sales,
    cat.total_tax,
    gen.Gender,
    gen.avg_purchase_amount,
    mon.month,
    mon.member_sales,
    tp.product_name,
    tp.total_sales AS product_sales,
    tp.total_quantity AS product_quantity,
    sp.Domicile,
    sp.total_sales AS region_sales
FROM
    total_sales_by_category cat
JOIN
    avg_purchase_by_gender gen ON 1=1
JOIN
    monthly_sales mon ON 1=1
JOIN
    top_products tp ON 1=1
JOIN
    sales_performance sp ON sp.Category = cat.Category
ORDER BY
    cat.total_sales DESC,
    gen.avg_purchase_amount DESC,
    mon.month,
    tp.total_sales DESC,
    sp.total_sales DESC;
    
    
    
    
   
   

