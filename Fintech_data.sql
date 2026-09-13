CREATE DATABASE fintech_data;

USE fintech_data;

-- vw_customer_profile

CREATE OR REPLACE VIEW vw_customer_profile AS
SELECT
    Customer_ID,
    Business_Name,
    Business_Type,
    Customer_Segment,
    Industry,
    Registration_Date,
    State,
    City,
    Business_Age,
    Number_of_Employees,
    Monthly_Revenue,
    Monthly_Revenue_Capped,
    Risk_Score,
    Churn_Status,
    Churn_Date,
    Acquisition_Channel,
    CAST(DATE_FORMAT(Registration_Date, '%Y-%m-01') AS DATE) AS Registration_Month
FROM customers;

SELECT * FROM vw_customer_profile;

-- vw_product_usage_summary

CREATE OR REPLACE VIEW vw_product_usage_summary AS
SELECT
    p.Product_ID,
    p.Product_Name,
    p.Product_Category,
    p.Launch_Date,
    COUNT(DISTINCT fu.Customer_ID) AS Unique_Users,
    COUNT(fu.Usage_ID) AS Usage_Events,
    SUM(COALESCE(fu.Sessions, 0)) AS Total_Sessions,
    SUM(COALESCE(fu.Transactions_Completed, 0)) AS Feature_Transactions_Completed,
    SUM(COALESCE(fu.Failed_Transactions, 0)) AS Feature_Failed_Transactions,
    ROUND(AVG(fu.Session_Duration), 2) AS Avg_Session_Duration,
    ROUND(AVG(COALESCE(fu.Is_Feature_Adopted, 0)), 4) AS Feature_Adoption_Rate
FROM products p
LEFT JOIN feature_usage fu
    ON p.Product_ID = fu.Product_ID
GROUP BY
    p.Product_ID,
    p.Product_Name,
    p.Product_Category,
    p.Launch_Date;

SELECT * FROM vw_product_usage_summary;

-- vw_customer_transaction_summary

CREATE OR REPLACE VIEW vw_customer_transaction_summary AS
SELECT
    c.Customer_ID,
    COUNT(t.Transaction_ID) AS Total_Transaction_Records,
    SUM(COALESCE(t.Is_Successful_Transaction, 0)) AS Successful_Transactions,
    SUM(
        CASE
            WHEN t.Transaction_ID IS NOT NULL
             AND COALESCE(t.Is_Successful_Transaction, 0) = 0
            THEN 1 ELSE 0
        END
    ) AS Failed_Transactions,
	SUM(COALESCE(t.Amount_Capped, 0)) AS Total_Transaction_Value,
    SUM(COALESCE(t.Fees_Capped, 0)) AS Total_Fees,
    SUM(COALESCE(t.Profit_Capped, 0)) AS Total_Profit,
    COUNT(DISTINCT t.Product_ID) AS Products_With_Transactions,
    ROUND(AVG(t.Amount_Capped), 2) AS Avg_Transaction_Value
FROM customers c
LEFT JOIN transactions t
    ON c.Customer_ID = t.Customer_ID
    GROUP BY c.Customer_ID;

SELECT * FROM vw_customer_transaction_summary;

SELECT	
SUM(t.Profit) AS profit_in_june
FROM Customers c
JOIN transactions t
			ON c.Customer_ID = t.Customer_ID
WHERE t.Transaction_Date >= '2025-06-01'
AND t.Transaction_Date < '2025-07-01';

SELECT 
MIN(transaction_date) AS start_date,
MAX(transaction_date) AS end_date
FROM transactions;

-- vw_customer_engagement_summary

CREATE OR REPLACE VIEW vw_customer_engagement_summary AS
SELECT
    c.Customer_ID,
    COUNT(e.Engagement_ID) AS Engagement_Days,
    SUM(COALESCE(e.Login_Count, 0)) AS Total_Logins,
    SUM(COALESCE(e.Push_Notifications_Opened, 0)) AS Push_Notifications_Opened,
    SUM(COALESCE(e.Email_Clicks, 0)) AS Email_Clicks,
    SUM(COALESCE(e.Support_Tickets, 0)) AS Support_Tickets,
    ROUND(AVG(e.Satisfaction_Score), 2) AS Avg_Satisfaction_Score,
    MAX(e.Login_Date) AS Last_Login_Date
FROM customers c
LEFT JOIN engagement e
    ON c.Customer_ID = e.Customer_ID
GROUP BY c.Customer_ID;

SELECT * FROM vw_customer_engagement_summary;

-- vw_moniebook_adoption

CREATE OR REPLACE VIEW vw_moniebook_adoption AS
SELECT
    c.Customer_ID,
    MIN(CASE WHEN p.Product_Name = 'Moniebook' THEN fu.Usage_Date END) AS First_Moniebook_Usage_Date,
    DATEDIFF(
        MIN(CASE WHEN p.Product_Name = 'Moniebook' THEN fu.Usage_Date END),
        c.Registration_Date
    ) AS Days_To_Adopt_Moniebook,
    COUNT(CASE WHEN p.Product_Name = 'Moniebook' THEN fu.Usage_ID END) AS Moniebook_Usage_Events,
    SUM(CASE WHEN p.Product_Name = 'Moniebook' THEN COALESCE(fu.Sessions, 0) ELSE 0 END) AS Moniebook_Sessions,
    MAX(CASE WHEN p.Product_Name = 'Moniebook' THEN COALESCE(fu.Is_Feature_Adopted, 0) ELSE 0 END) AS Adopted_Moniebook
FROM customers c
LEFT JOIN feature_usage fu
    ON c.Customer_ID = fu.Customer_ID
LEFT JOIN products p
    ON fu.Product_ID = p.Product_ID
GROUP BY
    c.Customer_ID,
    c.Registration_Date;
    
    SELECT * FROM vw_moniebook_adoption;
    
    -- vw_customer_360
    
    CREATE OR REPLACE VIEW vw_customer_360 AS
WITH ranked_metrics AS (
    SELECT
        cm.*,
        ROW_NUMBER() OVER(
            PARTITION BY cm.Customer_ID
            ORDER BY cm.Metric_Month DESC
        ) AS rn
    FROM customer_metrics cm
),
latest_metrics AS (
    SELECT *
    FROM ranked_metrics
    WHERE rn = 1
)
SELECT
    c.Customer_ID,
    c.Business_Type,
    c.Customer_Segment,
    c.Industry,
    c.State,
    c.City,
    c.Registration_Date,
    c.Registration_Month,
    c.Business_Age,
    c.Number_of_Employees,
    c.Monthly_Revenue_Capped,
    c.Risk_Score,
    c.Churn_Status,
    c.Acquisition_Channel,
    CASE WHEN ma.Adopted_Moniebook = 1 THEN 1 ELSE 0 END AS Is_Moniebook_User,
    ma.First_Moniebook_Usage_Date,
    ma.Days_To_Adopt_Moniebook,
    ma.Moniebook_Usage_Events,
    ma.Moniebook_Sessions,
    ts.Total_Transaction_Records,
    ts.Successful_Transactions,
    ts.Failed_Transactions,
    ts.Total_Transaction_Value,
    ts.Total_Fees,
    ts.Total_Profit,
    ts.Products_With_Transactions,
    ts.Avg_Transaction_Value,
    es.Engagement_Days,
    es.Total_Logins,
    es.Push_Notifications_Opened,
    es.Email_Clicks,
    es.Support_Tickets,
    es.Avg_Satisfaction_Score,
    lm.Customer_Lifetime_Value_Capped AS Latest_CLV,
    lm.Total_Revenue AS Latest_Total_Revenue,
    lm.Total_Transactions AS Latest_Total_Transactions,
    lm.Products_Used AS Latest_Products_Used,
    lm.Days_Since_Last_Login AS Latest_Days_Since_Last_Login
FROM vw_customer_profile c
LEFT JOIN vw_moniebook_adoption ma
    ON c.Customer_ID = ma.Customer_ID
LEFT JOIN vw_customer_transaction_summary ts
    ON c.Customer_ID = ts.Customer_ID
LEFT JOIN vw_customer_engagement_summary es
    ON c.Customer_ID = es.Customer_ID
LEFT JOIN latest_metrics lm
    ON c.Customer_ID = lm.Customer_ID;
    
    SELECT * FROM vw_customer_360;
    
-- Executive KPI Queries

SELECT
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn_Status = 'Active' THEN 1 ELSE 0 END) AS Active_Customers,
    SUM(CASE WHEN Churn_Status = 'Churned' THEN 1 ELSE 0 END) AS Churned_Customers,
    ROUND(SUM(Total_Transaction_Value), 2) AS Total_Transaction_Value,
    ROUND(SUM(Total_Fees), 2) AS Total_Fees,
    ROUND(SUM(Total_Profit), 2) AS Total_Profit,
    ROUND(AVG(Latest_CLV), 2) AS Avg_CLV,
    ROUND(AVG(Is_Moniebook_User), 4) AS Moniebook_Adoption_Rate
FROM vw_customer_360;

-- Product Utilization Analysis
SELECT
    Product_ID,
    Product_Name,
    Product_Category,
    Launch_Date,
    Unique_Users,
    Usage_Events,
    Total_Sessions,
    Feature_Transactions_Completed,
    Feature_Failed_Transactions,
    Avg_Session_Duration,
    Feature_Adoption_Rate
FROM vw_product_usage_summary
ORDER BY Unique_Users DESC, Total_Sessions DESC;

-- Moniebook Adoption Curve

SELECT
    CAST(DATE_FORMAT(First_Moniebook_Usage_Date, '%Y-%m-01') AS DATE) AS Adoption_Month,
    COUNT(*) AS New_Moniebook_Adopters,
    SUM(COUNT(*)) OVER(
        ORDER BY CAST(DATE_FORMAT(First_Moniebook_Usage_Date, '%Y-%m-01') AS DATE)
    ) AS Cumulative_Moniebook_Adopters
FROM vw_moniebook_adoption
WHERE Adopted_Moniebook = 1
GROUP BY CAST(DATE_FORMAT(First_Moniebook_Usage_Date, '%Y-%m-01') AS DATE)
ORDER BY Adoption_Month;

-- Adoption by Segment, Region and Business Size

SELECT
    Customer_Segment,
    COUNT(*) AS Customers,
    SUM(Is_Moniebook_User) AS Moniebook_Users,
    ROUND(SUM(Is_Moniebook_User) / COUNT(*), 4) AS Adoption_Rate,
    ROUND(AVG(Days_To_Adopt_Moniebook), 2) AS Avg_Days_To_Adopt,
    ROUND(AVG(Latest_CLV), 2) AS Avg_CLV
    FROM vw_customer_360
GROUP BY Customer_Segment
ORDER BY Adoption_Rate DESC;

-- Product Adoption Funnel
WITH counts AS (
    SELECT
        COUNT(*) AS registered_customers,
        SUM(CASE WHEN COALESCE(Total_Logins, 0) > 0 THEN 1 ELSE 0 END) AS logged_in_customers,
        SUM(CASE WHEN COALESCE(Latest_Products_Used, 0) > 0 THEN 1 ELSE 0 END) AS used_any_product_customers,
        SUM(CASE WHEN COALESCE(Successful_Transactions, 0) > 0 THEN 1 ELSE 0 END) AS completed_transaction_customers,
        SUM(CASE WHEN COALESCE(Is_Moniebook_User, 0) = 1 THEN 1 ELSE 0 END) AS moniebook_customers,
        SUM(CASE WHEN Churn_Status = 'Active' THEN 1 ELSE 0 END) AS retained_customers
    FROM vw_customer_360
),
funnel AS (
    SELECT 1 AS stage_order, 'Registered Customers' AS stage, registered_customers AS customers, registered_customers
    FROM counts

    UNION ALL

    SELECT 2, 'Logged In', logged_in_customers, registered_customers
    FROM counts

    UNION ALL

    SELECT 3, 'Used Any Product', used_any_product_customers, registered_customers
    FROM counts

    UNION ALL

    SELECT 4, 'Completed Transactions', completed_transaction_customers, registered_customers
    FROM counts

    UNION ALL

    SELECT 5, 'Adopted Moniebook', moniebook_customers, registered_customers
    FROM counts

    UNION ALL

    SELECT 6, 'Retained Customers', retained_customers, registered_customers
    FROM counts
)
SELECT
    stage_order,
    stage,
    customers,
    ROUND((customers * 100.0) / registered_customers, 2) AS percent_of_registered
FROM funnel
ORDER BY stage_order;

-- Non-Adoption Diagnostics

SELECT
    Is_Moniebook_User,
    COUNT(*) AS Customers,
    ROUND(AVG(Total_Logins), 2) AS Avg_Logins,
    ROUND(AVG(Support_Tickets), 2) AS Avg_Support_Tickets,
    ROUND(AVG(Avg_Satisfaction_Score), 2) AS Avg_Satisfaction,
    ROUND(AVG(Failed_Transactions), 2) AS Avg_Failed_Transactions,
    ROUND(AVG(Latest_Days_Since_Last_Login), 2) AS Avg_Days_Since_Last_Login,
    ROUND(AVG(Latest_CLV), 2) AS Avg_CLV
FROM vw_customer_360
GROUP BY Is_Moniebook_User;

-- Retention and Cohort Analysis

SELECT
    Cohort,
    Retention_Month,
    COUNT(DISTINCT Customer_ID) AS Customers_In_Cohort_Month,
    SUM(Monthly_Active_User) AS Active_Customers,
    ROUND(SUM(Monthly_Active_User) / COUNT(DISTINCT Customer_ID), 4) AS Retention_Rate
FROM customer_metrics
GROUP BY Cohort, Retention_Month
ORDER BY Cohort, Retention_Month;

-- CLV Impact Analysis

SELECT
    CASE WHEN Is_Moniebook_User = 1 THEN 'Moniebook Users' ELSE 'Non-Moniebook Users' END AS Customer_Group,
    COUNT(*) AS Customers,
    ROUND(AVG(Latest_CLV), 2) AS Avg_CLV,
    ROUND(AVG(Total_Transaction_Value), 2) AS Avg_Transaction_Value,
    ROUND(AVG(Total_Profit), 2) AS Avg_Profit,
    ROUND(AVG(Total_Logins), 2) AS Avg_Logins,
    ROUND(AVG(Latest_Products_Used), 2) AS Avg_Products_Used
FROM vw_customer_360
GROUP BY Is_Moniebook_User;

-- Churn Modeling Feature Table

CREATE OR REPLACE VIEW vw_churn_model_features AS
SELECT
Customer_ID,
    Customer_Segment,
    Industry,
    State,
    Business_Age,
    Number_of_Employees,
    Monthly_Revenue_Capped,
    Risk_Score,
    Is_Moniebook_User,
    Days_To_Adopt_Moniebook,
    Moniebook_Usage_Events,
    Moniebook_Sessions,
    Total_Transaction_Records,
    Successful_Transactions,
    Failed_Transactions,
    Total_Transaction_Value,
    Total_Fees,
    Total_Profit,
    Products_With_Transactions,
    Total_Logins,
    Push_Notifications_Opened,
    Email_Clicks,
    Support_Tickets,
    Avg_Satisfaction_Score,
    Latest_CLV,
    Latest_Days_Since_Last_Login,
    CASE WHEN Churn_Status = 'Churned' THEN 1 ELSE 0 END AS Churn_Label
FROM vw_customer_360;

SELECT * FROM vw_churn_model_features;

-- Regional Adoption

SELECT
    State,
    City,
    COUNT(*) AS Customers,
    SUM(Is_Moniebook_User) AS Moniebook_Users,
    ROUND(SUM(Is_Moniebook_User) / COUNT(*), 4) AS Adoption_Rate,
    ROUND(SUM(Total_Transaction_Value), 2) AS Transaction_Value,
    ROUND(AVG(Latest_CLV), 2) AS Avg_CLV
FROM vw_customer_360
GROUP BY State, City
ORDER BY Adoption_Rate DESC, Customers DESC;

-- Business Size Adoption

SELECT
    CASE
        WHEN Number_of_Employees BETWEEN 1 AND 5 THEN 'Micro: 1-5 employees'
        WHEN Number_of_Employees BETWEEN 6 AND 20 THEN 'Small: 6-20 employees'
        WHEN Number_of_Employees BETWEEN 21 AND 50 THEN 'Medium: 21-50 employees'
        ELSE 'Large: 51+ employees'
    END AS Business_Size_Band,
    COUNT(*) AS Customers,
    SUM(Is_Moniebook_User) AS Moniebook_Users,
    ROUND(SUM(Is_Moniebook_User) / COUNT(*), 4) AS Adoption_Rate,
    ROUND(AVG(Latest_CLV), 2) AS Avg_CLV,
    ROUND(AVG(Total_Transaction_Value), 2) AS Avg_Transaction_Value
FROM vw_customer_360
GROUP BY Business_Size_Band
ORDER BY Adoption_Rate DESC;

CREATE OR REPLACE VIEW pbi_customer_360 AS
SELECT *
FROM vw_customer_360;

SELECT * FROM pbi_customer_360;

CREATE OR REPLACE VIEW pbi_product_performance AS
SELECT *
FROM vw_product_usage_summary;

SELECT * FROM pbi_product_performance;

CREATE OR REPLACE VIEW pbi_monthly_moniebook_adoption AS
SELECT
    CAST(DATE_FORMAT(First_Moniebook_Usage_Date, '%Y-%m-01') AS DATE) AS Adoption_Month,
    COUNT(*) AS New_Moniebook_Adopters,
    SUM(COUNT(*)) OVER(
        ORDER BY CAST(DATE_FORMAT(First_Moniebook_Usage_Date, '%Y-%m-01') AS DATE)
        ) AS Cumulative_Moniebook_Adopters
FROM vw_moniebook_adoption
WHERE Adopted_Moniebook = 1
GROUP BY CAST(DATE_FORMAT(First_Moniebook_Usage_Date, '%Y-%m-01') AS DATE);

SELECT * FROM pbi_monthly_moniebook_adoption;

SELECT *
FROM pbi_customer_360
INTO OUTFILE '/var/lib/mysql-files/pbi_customer_360.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
