# Loan Default Risk Analysis

## Project Overview

This project analyzes borrower and loan data to identify key characteristics associated with loan default risk. The analysis focuses on credit score, DTI ratio, income, loan amount, interest rate, employment status, and loan purpose.

## Business Questions

- What is the overall loan default rate?
- How does default risk vary across different credit score ranges?
- Is DTI ratio associated with loan default risk?
- Which loan purposes have higher default rates?
- How do loan amounts differ between defaulted and non-defaulted borrowers?
- How do employment status and years employed relate to default risk?
- Which numerical variables show the strongest relationship with default?

## Dataset

The project uses two datasets:

- `borrower_profiles.csv` — borrower demographics, employment, income, credit score, and existing debt information.
- `loan_applications.csv` — loan amount, term, interest rate, DTI ratio, loan purpose, and repayment status.

The datasets were joined using `borrower_id`, resulting in 601 loan records for analysis.

## Workflow

### 1. Data Exploration & Preparation

- Loaded and explored borrower and loan datasets using Python and Pandas.
- Checked data types, missing values, and descriptive statistics.
- Joined the datasets using `borrower_id`.
- Created a binary `defaulted` variable to represent loan default status.

### 2. Segment Analysis

Analyzed default rates across:

- Credit score ranges
- DTI ratio ranges
- Employment status
- Loan purpose

Default rate was calculated as:

**Default Rate = Number of Defaults / Total Loans × 100**

### 3. Correlation Analysis

Used point-biserial correlation to examine the relationship between default status and numerical variables:

- Credit Score
- DTI Ratio
- Annual Income
- Loan Amount
- Interest Rate

Statistical significance was evaluated using a p-value threshold of 0.05.

### 4. Visualization

Created visualizations to communicate:

- Default rate by credit score range
- DTI ratio and default status
- Default rate by loan purpose
- Differences across borrower and loan segments

## Key Insights

- **Credit Score:** Credit score shows the strongest relationship with default among the numerical variables analyzed (r = -0.2864, p < 0.001). Borrowers with credit scores of 520–599 have a 49.14% default rate, compared with 11.69% for borrowers with scores of 750+.

- **DTI Ratio:** Default rates increase at higher DTI levels. Borrowers with DTI above 50% have a 34.32% default rate, while the 20–35% group has a 10.61% rate. DTI is also positively associated with default (r = 0.1925, p < 0.001).

- **Interest Rate:** Interest rate shows a positive and statistically significant relationship with default (r = 0.1989, p < 0.001).

- **Loan Amount:** Loan amount is not statistically significant in this analysis (r = 0.0181, p = 0.6576).

- **Employment:** Part-time borrowers have the highest observed default rate at 27.69%, followed by self-employed borrowers at 24.76%.

## Recommendations

- **Credit Risk Assessment:** Use credit score as a key component of borrower risk assessment, with 650 as an exploratory screening threshold for additional review.

- **DTI Monitoring:** Apply additional risk assessment to borrowers with high DTI, particularly those above 40–50%.

- **Interest Rate Monitoring:** Consider relatively high interest rates as an additional risk indicator during underwriting.

- **Loan Amount:** Do not use loan amount as a primary standalone rejection criterion based on this analysis.

- **Multi-Factor Assessment:** Combine credit score, DTI, interest rate, and borrower characteristics rather than relying on a single risk factor.

> **Note:** These findings are exploratory and based on the available dataset. The proposed thresholds should be validated on larger and more representative data before being used as production underwriting policies.

## Tools

- Python
- Pandas
- NumPy
- Matplotlib
- Seaborn
- SciPy
- Power BI

## Project Outcome

The analysis identifies borrower and loan characteristics associated with default risk and translates the findings into data-driven recommendations that can support credit risk assessment and underwriting decisions.
