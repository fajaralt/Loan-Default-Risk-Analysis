# Setting up The Database and Table in MySQL Server

CREATE DATABASE `loan`;

# Create Table and Import Datasets

CREATE TABLE loan_applications (
	loan_id	VARCHAR(20) PRIMARY KEY,
    borrower_id	VARCHAR(20) NOT NULL,
    application_date DATE NOT NULL,
    loan_purpose VARCHAR(50) NOT NULL,
    loan_amount	DECIMAL(10, 2) NOT NULL,
    term_months	INT NOT NULL,
    interest_rate DECIMAL(4, 2) DEFAULT 0.00,
    monthly_payment	DECIMAL(10,2) NOT NULL,
    dti_ratio DECIMAL(5, 2) DEFAULT 0.00,
    loan_status	VARCHAR(50),
    days_delinquent	SMALLINT UNSIGNED DEFAULT 0,
    defaulted TINYINT NOT NULL DEFAULT 0
);

SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE '/loan_applications.csv'
INTO TABLE loan_applications
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

CREATE TABLE borrower_profiles (
	borrower_id	VARCHAR(20) PRIMARY KEY,
    age INT,
    state VARCHAR(5),
    education_level VARCHAR(50),
    employment_status VARCHAR(50),
    years_employed INT,
    annual_income DECIMAL(10, 2) NOT NULL,
    credit_score SMALLINT UNSIGNED,
    home_ownership VARCHAR(20),
    dependents INT,
    existing_monthly_debt DECIMAL(10, 2)
);

LOAD DATA LOCAL INFILE '/borrower_profiles.csv'
INTO TABLE borrower_profiles
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SET GLOBAL local_infile = 0;
SHOW VARIABLES LIKE 'local_infile';

-- Cleaning Data and Checking the Datas -- 

-- 1. Create Staging Table
-- 2. Remove Duplicates
-- 3. Standardizing Data
-- 4. Handling Null / Blank Values
-- 5. Fix Data Type
-- 6. Delete Uneccesary Column

-- Checking Duplicates 

WITH duplicate_cte AS (
	SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY loan_id, borrower_id, application_date, 
		loan_purpose, loan_amount, term_months, interest_rate, 
		monthly_payment, dti_ratio, loan_status, days_delinquent, 
		defaulted) AS row_num
    FROM loan_applications
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

## No duplcate Data in loan_applications table

WITH duplicate_cte AS (
	SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY borrower_id, age, state, education_level, 
        employment_status, years_employed, annual_income, credit_score, 
        home_ownership, dependents, existing_monthly_debt) AS row_num
    FROM borrower_profiles
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

## No duplicate Data in borrower_profiles table

## Checking data types

DESCRIBE loan_applications;

DESCRIBE borrower_profiles;

## Lock all the datasets

ALTER TABLE loan_applications
MODIFY COLUMN interest_rate DECIMAL(4, 2) NOT NULL DEFAULT 0.00,
MODIFY COLUMN dti_ratio DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
MODIFY COLUMN loan_status VARCHAR(50) NOT NULL,
MODIFY COLUMN days_delinquent SMALLINT UNSIGNED NOT NULL DEFAULT 0;

ALTER TABLE borrower_profiles
MODIFY COLUMN age INT NOT NULL,
MODIFY COLUMN state VARCHAR(5) NOT NULL,
MODIFY COLUMN education_level VARCHAR(50) NOT NULL,
MODIFY COLUMN employment_status VARCHAR(50) NOT NULL,
MODIFY COLUMN years_employed INT NOT NULL,
MODIFY COLUMN credit_score SMALLINT UNSIGNED NOT NULL,
MODIFY COLUMN home_ownership VARCHAR(20) NOT NULL,
MODIFY COLUMN dependents INT NOT NULL,
MODIFY COLUMN existing_monthly_debt DECIMAL(10, 2) NOT NULL;

-- All the Datasets already cleaned and ready to analyze

# Question to answer and breakdown what types of analytics 

# -- Descriptive Analytics -- 
# 1. What is the overall default rate, and how does it break down by credit score range?
# 2. Which loan purposes have the highest default rates?
# 3. How do employment status and years employed affect default risk?
# 4. Which loan status has the most loan amount?
# 5. What is average loan amount by defaulted vs non-defaulted?
# 6. How does Loan Characteristics by total loan based on loan purpose and loan terms?

# -- Diagnostic Analytics -- 
# 1. What factors may explain higher default rates among certain loan purposes?
# 2. What factors may explain higher default rates among borrowers with shorter employment tenure?

# -- Prescriptive Analytics -- 
# 1. What DTI threshold would you recommend as a cutoff for loan approval?

# -- Descriptive Analytics -- 
# 1. What is the overall default rate, and how does it break down by credit score range?
# (e.g., 520–599, 600–649, 650–699, 700–749, 750+)? Which credit score bucket has the highest default rate?

SELECT
    COUNT(*) AS total_loans,
    SUM(defaulted) AS defaulted_loans,
    ROUND(
        SUM(defaulted) * 100.0 / COUNT(*),
        2
    ) AS overall_default_rate
FROM loan_applications;

## From the datasets a total of 601 loans, with 146 loans in default and an average default rate of 24.29%.

# Default rate by employment_status

SELECT 
	b.employment_status,
    ROUND(SUM(defaulted) * 100 / COUNT(*), 2) AS defaulted_rate
FROM borrower_profiles b
JOIN loan_applications l
	ON b.borrower_id = l.borrower_id
GROUP BY employment_status
ORDER BY defaulted_rate DESC;

## The highest defaulted rate by employment status is Part-Time with 27.69%, --
-- while the lowest defaulted rate is Contract with 22.73%

# Default rate by DTI bands

WITH dti_cte AS(
	SELECT
		loan_id,
        dti_ratio,
        defaulted,
		CASE
			WHEN dti_ratio < 40 THEN 'less than 40%'
            WHEN dti_ratio < 60 THEN '40-59.9%'
            WHEN dti_ratio < 80 THEN '60-79.9%'
            ELSE '80% or higher'
		END AS dti_bands
        FROM loan_applications
)
SELECT
	dti_bands,
    COUNT(*) AS total_loans,
    SUM(defaulted) AS defaulted_loans,
    ROUND(SUM(defaulted) * 100 / COUNT(*), 2) AS defaulted_rate
FROM dti_cte
GROUP BY dti_bands
ORDER BY
	CASE dti_bands
        WHEN 'less than 40%' THEN 1
        WHEN '40-59.9%' THEN 2
        WHEN '60-79.9%' THEN 3
        WHEN '80% or higher' THEN 4
    END ASC;

## The highest defaulted_rate by dti bands is 80% or higher, while the lowest defaulted rate by dti_bands is less than 40%

# Defaulted rate by credit score

WITH cte AS(
	SELECT 
		b.borrower_id,
        b.credit_score,
		CASE
			WHEN credit_score BETWEEN 520 AND 599 THEN '520-599'
			WHEN credit_score BETWEEN 600 AND 649 THEN '600-649'
			WHEN credit_score BETWEEN 650 AND 699 THEN '650-699'
			WHEN credit_score BETWEEN 700 AND 749 THEN '700-749'
			WHEN credit_score >= 750 THEN '750+'
		END AS credit_score_bucket,
        l.loan_status,
        l.defaulted
    FROM borrower_profiles b
    JOIN loan_applications l
		ON b.borrower_id = l.borrower_id
)
SELECT 
	credit_score_bucket,
    COUNT(*) AS total_loans,
    SUM(defaulted) AS defaulted_loans,
    ROUND(SUM(defaulted) * 100 / COUNT(*), 2) AS defaulted_rate
FROM cte
GROUP BY credit_score_bucket
ORDER BY credit_score_bucket ASC;

## The highest defaulted rate represent the lowest credit score bucket range between 520 - 599 with 49.14% defaulted rate
-- for the detail with total 116 total_loans and 57 defaulted_loans

# 2. Which loan purposes have the highest default rates?

SELECT 
	l.loan_purpose,
    ROUND(SUM(defaulted) * 100 / COUNT(*), 2) AS defaulted_rate
FROM borrower_profiles b
JOIN loan_applications l
	ON b.borrower_id = l.borrower_id
GROUP BY loan_purpose
ORDER BY defaulted_rate DESC;

## The highest defaulted rate by loan purpose is Wedding with 32.14%, --
-- while the lowest defaulted rate is Medical Expenses with 20.59%

# 3. How do employment status and years employed affect default risk?

-- Defaulted rate by employment status

SELECT
    b.employment_status,
    COUNT(*) AS total_loans,
    SUM(l.defaulted) AS defaulted_loans,
    ROUND(SUM(l.defaulted) * 100.0 / COUNT(*), 2) AS default_rate
FROM borrower_profiles b
JOIN loan_applications l
    ON b.borrower_id = l.borrower_id
GROUP BY b.employment_status
ORDER BY default_rate DESC;

## The highest defaulted rate by employment_status is Part-Time with 27.69% defaulted rate,
-- while the lowest defaulted rate by employment_status is Contract with 22.73% defaulted rate.

-- Defaulted rate by years employed

WITH cte AS (
    SELECT
        b.borrower_id,
        b.years_employed,
        l.defaulted,
        CASE
            WHEN b.years_employed < 2 THEN '<2 years'
            WHEN b.years_employed BETWEEN 2 AND 5 THEN '2-5 years'
            WHEN b.years_employed BETWEEN 6 AND 10 THEN '6-10 years'
            WHEN b.years_employed BETWEEN 11 AND 20 THEN '11-20 years'
            ELSE '21+ years'
        END AS years_employed_bands
    FROM borrower_profiles b
    JOIN loan_applications l
        ON b.borrower_id = l.borrower_id
)
SELECT
    years_employed_bands,
    COUNT(*) AS total_loans,
    SUM(defaulted) AS defaulted_loans,
    ROUND(SUM(defaulted) * 100.0 / COUNT(*), 2) AS default_rate
FROM cte
GROUP BY years_employed_bands
ORDER BY
    CASE years_employed_bands
        WHEN '<2 years' THEN 1
        WHEN '2-5 years' THEN 2
        WHEN '6-10 years' THEN 3
        WHEN '11-20 years' THEN 4
        WHEN '21+ years' THEN 5
    END;

## The highest defaulted rate by years employed is less than 2 years,
-- while the lowest defaulted rate by years employed is 2-5 years.

-- Are borrowers with less than 2 years of employment significantly more likely to default?

SELECT
    CASE
        WHEN b.years_employed < 2 THEN '<2 years'
        ELSE '2+ years'
    END AS employment_group,
    COUNT(*) AS total_loans,
    SUM(l.defaulted) AS defaulted_loans,
    ROUND(SUM(l.defaulted) * 100.0 / COUNT(*), 2) AS default_rate
FROM borrower_profiles b
JOIN loan_applications l
    ON b.borrower_id = l.borrower_id
GROUP BY employment_group;

## Employment years employed with less than 2 years is significantly more likely to default with 34.52% default rate,
-- while employment years employed with 2 years or higher is not significantly more likely to default.

# 4. Which loan status has the most loan amount?

SELECT
    loan_status,
    COUNT(*) AS total_loans,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM loan_applications), 2) AS loan_share_pct,
    ROUND(SUM(loan_amount), 2) AS total_loan_amount,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount
FROM loan_applications
GROUP BY loan_status
ORDER BY total_loan_amount DESC;

## The highest total loan amount by loan_status is Current with $5,089,300 total loan amount,
-- while the lowest total loan amount by loan_status is Paid Off with $2,416,000 total loan amount.
    
# 5. What is average loan amount by defaulted vs non-defaulted?

SELECT
    CASE
		WHEN defaulted = 1 THEN 'Defaulted'
        ELSE 'Non-Defaulted' 
	END AS defaulted_status,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_amount), 2) AS average_loan_amount,
    ROUND(MIN(loan_amount), 2) AS minimum_loan_amount,
    ROUND(MAX(loan_amount), 2) AS maximum_loan_amount
FROM loan_applications
GROUP BY defaulted_status;

## Average loan amount on Defaulted by defaulted_status is $22,571, 
-- while average loan amount on Non-Defaulted by defaulted status is $22,013

# 6. How does Loan Characteristics by total loan based on loan purpose and loan terms?
-- Loan Purpose 

SELECT
    loan_purpose,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
    ROUND(AVG(monthly_payment), 2) AS avg_monthly_payment
FROM loan_applications
GROUP BY loan_purpose
ORDER BY total_loans DESC;

## The highest total loans by loan_purpose is Home Improvement with 70 total_loans, 
-- while the lowest total loans by loan purpose is Debt Consolidation with 51 total_loans.

-- Loan Term

SELECT
    term_months,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
    ROUND(AVG(monthly_payment), 2) AS avg_monthly_payment
FROM loan_applications
GROUP BY term_months
ORDER BY term_months;

## The highest total loans by term months is 48 Months with 137 total loans, 
-- while the lowest total loans by term months is 24 Months with 110 total loans


# -- Diagnostic Analytics -- 
# 1. What factors may explain higher default rates among certain loan purposes?

-- Identify the problem is
SELECT
    loan_purpose,
    COUNT(*) AS total_loans,
    SUM(defaulted) AS defaulted_loans,
    ROUND(
        SUM(defaulted) * 100.0 / COUNT(*),
        2
    ) AS default_rate
FROM loan_applications
GROUP BY loan_purpose
ORDER BY default_rate DESC;

## Wedding has the highest default rate with 32.14%,
-- while Medical Expenses has the lowest default rate with 20.59%

-- Compare characteristics in loan purpose
SELECT
    loan_purpose,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
    ROUND(AVG(term_months), 2) AS avg_term_months,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
    ROUND(AVG(monthly_payment), 2) AS avg_monthly_payment,
    ROUND(AVG(dti_ratio), 2) AS avg_dti,
    ROUND(SUM(defaulted) * 100.0 / COUNT(*), 2) AS default_rate
FROM loan_applications
GROUP BY loan_purpose
ORDER BY default_rate DESC;

## Wedding, Home Improvement, and Auto Loan have the highest observed default rates. 
-- These purposes generally show relatively high debt burden or repayment obligations, 
-- but the relationship is not consistent across all purposes. 
-- Therefore, loan-level characteristics such as DTI, loan amount, and monthly payment may contribute 
-- to differences in default rates, but no single factor clearly explains the variation.

-- But, lets take a look between defaulted vs non-defaulted by loan purpose

SELECT
    loan_purpose,
    CASE
        WHEN defaulted = 1 THEN 'Defaulted'
        ELSE 'Non-Defaulted'
    END AS default_status,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
    ROUND(AVG(term_months), 2) AS avg_term_months,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
    ROUND(AVG(monthly_payment), 2) AS avg_monthly_payment,
    ROUND(AVG(dti_ratio), 2) AS avg_dti
FROM loan_applications
GROUP BY
    loan_purpose,
    defaulted
ORDER BY
    loan_purpose,
    default_status;

## Higher default rates across certain loan purposes appear to be associated with 
-- higher borrower debt burden and repayment obligations. 
-- Defaulted loans generally show higher average DTI and, in several loan-purpose categories, 
-- higher interest rates and monthly payments than non-defaulted loans. 
-- However, loan amount and loan term do not show a consistent pattern across purposes.

-- Let's take a look from borrower_profiles datasets

SELECT
    l.loan_purpose,
    CASE
        WHEN l.defaulted = 1 THEN 'Defaulted'
        ELSE 'Non-Defaulted'
    END AS default_status,
    COUNT(*) AS total_loans,
    ROUND(AVG(b.years_employed), 2) AS avg_years_employed,
    ROUND(AVG(b.annual_income), 2) AS avg_annual_income,
    ROUND(AVG(b.credit_score), 2) AS avg_credit_score,
    ROUND(AVG(b.dependents), 2) AS avg_dependents,
    ROUND(AVG(b.existing_monthly_debt), 2) AS avg_existing_monthly_debt
FROM loan_applications l
JOIN borrower_profiles b
	ON l.borrower_id = b.borrower_id
GROUP BY
    l.loan_purpose,
    l.defaulted
ORDER BY
    l.loan_purpose,
    default_status;
    
## Borrower characteristics provide several potential explanations for higher default rates 
-- across loan purposes. Defaulted borrowers generally have lower credit scores and 
-- higher existing monthly debt than non-defaulted borrowers within the same loan purpose. 
-- Income also tends to be lower among defaulted borrowers in several categories, 
-- although the pattern is less consistent. Employment tenure shows mixed patterns across loan purposes, 
-- suggesting that its relationship with default risk requires further statistical testing.
    


# 2. What factors may explain higher default rates among borrowers with shorter employment tenure?

SELECT
    CASE
        WHEN b.years_employed < 2 THEN '<2 years'
        ELSE '2+ years'
    END AS employment_group,
    COUNT(*) AS total_loans,
    SUM(l.defaulted) AS defaulted_loans,
    ROUND(SUM(l.defaulted) * 100.0 / COUNT(*), 2) AS default_rate,
    ROUND(AVG(b.annual_income), 2) AS avg_annual_income,
    ROUND(AVG(b.credit_score), 2) AS avg_credit_score,
    ROUND(AVG(b.existing_monthly_debt), 2) AS avg_existing_debt,
    ROUND(AVG(l.loan_amount), 2) AS avg_loan_amount,
    ROUND(AVG(l.monthly_payment), 2) AS avg_monthly_payment,
    ROUND(AVG(l.dti_ratio), 2) AS avg_dti
FROM borrower_profiles b
JOIN loan_applications l
    ON b.borrower_id = l.borrower_id
GROUP BY employment_group;

## Borrowers with less than 2 years of employment have a higher observed default rate (34.52% vs 22.63%). 
-- This group also has higher average existing monthly debt and DTI, 
-- suggesting that greater debt burden may be one factor associated with the higher default rate. 
-- However, credit score and income do not show patterns that clearly explain the difference.

# -- Prescriptive Analytics -- 
# 1. What DTI threshold would you recommend as a cutoff for loan approval?

WITH thresholds AS (
    SELECT 40 AS dti_threshold
    UNION ALL SELECT 45
    UNION ALL SELECT 50
    UNION ALL SELECT 55
    UNION ALL SELECT 60
    UNION ALL SELECT 65
    UNION ALL SELECT 70
)
SELECT
    t.dti_threshold,
    COUNT(l.loan_id) AS total_loans_above_cutoff,
    SUM(l.defaulted) AS defaults_above_cutoff,
    ROUND(SUM(l.defaulted) * 100.0 / COUNT(l.loan_id), 2) AS default_rate_above_cutoff,
    ROUND(COUNT(l.loan_id) * 100.0 / (SELECT COUNT(*) FROM loan_applications), 2) AS loan_pct_above_cutoff,
    ROUND(SUM(l.defaulted) * 100.0 / (SELECT SUM(defaulted) FROM loan_applications), 2) AS default_capture_rate
FROM thresholds t
JOIN loan_applications l
    ON l.dti_ratio > t.dti_threshold
GROUP BY t.dti_threshold
ORDER BY t.dti_threshold;

## A 60% DTI threshold is recommended as an initial screening cutoff. 
-- Loans above 60% represent 28.45% of the portfolio and have a 35.67% observed default rate, 
-- while accounting for 41.78% of all observed defaults. 
-- This provides a practical balance between identifying higher-risk borrowers and 
-- maintaining reasonable loan approval coverage.

## The threshold should be used as a risk-screening criterion rather than an automatic rejection rule, 
-- and should be combined with other borrower characteristics such as credit score and existing debt.







