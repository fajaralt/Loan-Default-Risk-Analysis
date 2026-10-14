# Loan Default Risk Analysis

## Project Overview
An end-to-end data analytics project analyzing borrower and loan characteristics associated with default risk. The goal is to identify risk patterns and provide data-driven recommendations to support credit risk assessment.

## Business Questions
- What is the overall loan default rate?
- How does default risk vary by credit score and DTI ratio?
- Which loan purposes and borrower characteristics show higher default rates?
- Which numerical variables are associated with loan default?

## Dataset
The analysis combines two datasets using `borrower_id`, resulting in **601 loan records**.

- `borrower_profiles.csv` — borrower income, employment, credit score, and existing debt.
- `loan_applications.csv` — loan amount, interest rate, DTI ratio, loan purpose, and repayment status.

## Workflow
1. **Data Preparation:** Explored, cleaned, and joined datasets using Python and Pandas.
2. **Exploratory Analysis:** Examined default rates across borrower and loan segments.
3. **Statistical Analysis:** Used point-biserial correlation and p-values to assess relationships with default.
4. **Visualization:** Presented findings through charts and a Power BI dashboard.

## Key Insights
- **Credit Score:** Strongest relationship with default among the numerical variables analyzed (r = -0.2864, p < 0.001). The 520–599 credit score group had a 49.14% default rate, compared with 11.69% for scores of 750+.
- **DTI Ratio:** Positively associated with default (r = 0.1925, p < 0.001). Borrowers with DTI above 50% had a 34.32% default rate.
- **Interest Rate:** Positively associated with default (r = 0.1989, p < 0.001).
- **Loan Amount:** No statistically significant relationship was found (r = 0.0181, p = 0.6576).
- **Employment:** Part-time borrowers had the highest observed default rate at 27.69%, followed by self-employed borrowers at 24.76%.

## Recommendations
- Prioritize credit score and DTI ratio in risk assessment.
- Use high interest rates and borrower characteristics as additional review indicators.
- Avoid using loan amount as a standalone rejection criterion.
- Combine multiple risk indicators rather than relying on a single variable.

> **Note:** Findings are exploratory and do not establish causation. Proposed screening thresholds require further validation before being applied to real underwriting decisions.

## Tools
- Python
- Pandas, NumPy
- Matplotlib, Seaborn
- SciPy
- Power BI

## Project Outcome
Identified key borrower and loan characteristics associated with default risk and translated the findings into practical recommendations for credit risk assessment.

## Author
**Fajar Surya Aji**  
Aspiring Data Analyst | BI Analyst

GitHub: https://github.com/fajaralt/Loan_Default_Risk_Analysis
