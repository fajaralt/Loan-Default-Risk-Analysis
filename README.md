# Loan Default Risk Analysis

An exploratory credit risk analysis project using Python and Pandas to identify borrower and loan characteristics associated with loan default risk.

## Business Problem

A consumer lending company wants to understand the key factors associated with loan defaults and use the findings to support credit risk assessment and underwriting decisions.

## Objectives

- Analyze default rates across different credit score ranges.
- Examine the relationship between DTI ratio and loan defaults.
- Identify loan purposes with higher default rates.
- Compare default risk across employment segments.
- Identify numeric variables most strongly associated with default.
- Develop data-driven recommendations for underwriting.

## Dataset

The project uses two datasets:

- `borrower_profiles.csv` — borrower demographics, employment, income, credit score, and existing debt.
- `loan_applications.csv` — loan applications, loan amount, term, interest rate, DTI ratio, and repayment status.

The datasets were joined using `borrower_id`, resulting in 601 loan records with borrower and loan attributes.

## Analysis Workflow

### 1. Data Exploration & Preparation

- Loaded and explored both datasets using Pandas.
- Checked data types, missing values, and descriptive statistics.
- Joined borrower and loan data using `borrower_id`.
- Created a binary `defaulted` variable where:
  - `1` = Default
  - `0` = Non-default

### 2. Segment Analysis

Analyzed default rates across:

- Credit score ranges
- DTI ratio ranges
- Employment status
- Loan purpose

Default rate was calculated as:

**Default Rate = Number of Defaults / Total Loans × 100**

### 3. Correlation Analysis

Used point-biserial correlation to examine the relationship between default status and:

- Credit Score
- DTI Ratio
- Annual Income
- Loan Amount
- Interest Rate

Statistical significance was evaluated using a p-value threshold of **0.05**.

### 4. Visualization

Created visualizations to communicate key findings, including:

- Default Rate by Credit Score Range
- DTI Ratio vs. Default Status
- Default Rate by Loan Purpose

## Key Findings

### Credit Score

Credit score showed the strongest relationship with default among the analyzed numeric variables.

Borrowers with credit scores of **520–599** had a **49.14% default rate**, compared with **11.69%** for borrowers with scores of **750+**.

The correlation between credit score and default was **-0.2864 (p < 0.05)**. :contentReference[oaicite:2]{index=2}

### DTI Ratio

Default rates increased across higher DTI ranges.

| DTI Range | Default Rate |
|---|---:|
| <20% | 16.67% |
| 20–35% | 10.61% |
| 35–50% | 20.67% |
| 50%+ | 34.32% |

The analysis indicates that borrowers with higher debt burdens tend to show higher default rates. :contentReference[oaicite:3]{index=3}

### Employment Status

Default rates varied across employment groups, with Part-Time borrowers showing the highest rate at **27.69%**, followed by Self-Employed borrowers at **24.76%**. :contentReference[oaicite:4]{index=4}

### Loan Purpose

Default rates were also compared across different loan purposes to identify purposes associated with relatively higher repayment risk. :contentReference[oaicite:5]{index=5}

### Correlation Results

| Variable | Correlation with Default | P-Value |
|---|---:|---:|
| Credit Score | -0.2864 | <0.001 |
| Interest Rate | 0.1989 | <0.001 |
| DTI Ratio | 0.1925 | <0.001 |
| Annual Income | -0.0815 | 0.0457 |
| Loan Amount | 0.0181 | 0.6576 |

Credit score, interest rate, DTI ratio, and annual income were statistically significant at the 5% level, while loan amount was not statistically significant in this analysis. :contentReference[oaicite:6]{index=6}

## Recommendations

Based on the analysis, the project proposes the following underwriting considerations:

1. **Credit Score ≥ 650**
   - Flag applicants below 650 for additional risk assessment.

2. **DTI Ratio ≤ 40%**
   - Applicants above 40% may require additional review or stricter loan conditions.

3. **Interest Rate ≤ 15%**
   - Loans requiring higher interest rates may require additional risk review.

These thresholds are exploratory recommendations based on the dataset and should not be treated as production lending policies without further validation. :contentReference[oaicite:7]{index=7}

## Tools

- Python
- Pandas
- NumPy
- Matplotlib
- Seaborn
- SciPy
- Jupyter Notebook
- Power BI

## Project Workflow

**Data Exploration → Data Preparation → Dataset Join → Segment Analysis → Correlation Analysis → Visualization → Risk Insights → Recommendations**
