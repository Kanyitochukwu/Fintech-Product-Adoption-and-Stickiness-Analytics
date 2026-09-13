# 📊 Fintech Product Adoption & Customer Lifetime Value Analytics

An end-to-end fintech business intelligence analytics and customer lifetime value (CLV) framework evaluating multi-product adoption, user engagement depth, operational friction, and merchant retention across **7,000 merchants** and **1.18M sessions** (2024–2025).

---

## 📌 Executive Summary

Fintech platforms often capture massive volumes of transaction data without understanding what actually drives sustained merchant loyalty. This project moves beyond surface-level volume to examine how product adoption directly shapes customer lifetime value and churn risk.

### Core Analytical Highlights:
* **The 4-Product Sweet Spot:** Merchant profitability peaks among businesses utilizing 4 integrated solutions, unlocking over **₦100M in cumulative profit**.
* **The Bookkeeping Anchor:** Merchants adopting Moniebook represent only **~17% of total churn**; over 80% of lost merchants never adopted bookkeeping. Integrating 7–8 tools eliminates churn entirely (**100% retention**).
* **The 220-Day Onboarding Gap:** Despite high feature adoption depth (89%), merchants wait an average of **220 days (~7.3 months)** before first using Moniebook.
* **Countertop Friction:** POS terminals account for over **53,000 failed transactions**, representing the single largest operational friction point and a primary trigger for merchant support tickets and silent churn.
* **Volume vs. Value Concentration:** Micro-merchants represent 81% of the user base (~3,418 sellers), but ~1,323 Medium and Enterprise businesses drive over **₦72B in gross transaction volume**.

---

## 🧱 Architecture & Data Engineering Workflow
[Raw Relational Datasets] (Customers, Products, Features, Transactions, Activity)
│
▼
[SQL Transformation & Aggregation Layer]
├── pbi_customer_360 (Customer-level grain: CLV, Profit, Churn Risk)
├── powerbi_product_summary (Product grain: Users, Sessions, Failures)
├── powerbi_moniebook_adoption_curve (Monthly cohort trends)
└── powerbi_churn_risk_table (Inactivity & operational alerts)
│
▼
[Power BI Analytical Star Schema]
├── Relational Modeling & Dimension Lookups
├── Complex DAX (Activity decay, cohort lags, dynamic flags)
└── Diagnostic Merchant 360 Drillthrough Interface

---

## 🛠️ Data Modeling & SQL Analytical Marts

To prevent measure duplication and optimize dashboard rendering, SQL was utilized to transform raw transaction logs into aggregated analytical tables at precise grains before ingestion into Power BI:

| Table Name | Grain | Key Metrics & Dimensions |
| :--- | :--- | :--- |
| `pbi_customer_360` | One row per merchant | Customer Segment, State, Acquisition Channel, Total Profit, CLV, Support Tickets, Login Cadence, Churn Status. |
| `powerbi_product_summary` | One row per product | Unique Users, Usage Events, Total Sessions, Adoption Rates, Failed Transactions. |
| `powerbi_moniebook_adoption_curve` | One row per month | Monthly New Adopters, Cumulative Adopters, Penetration Rate. |
| `powerbi_segment_summary` | One row per segment | Headcount, Volume Contribution (₦), Average CLV, Segment Churn Rates. |
| `powerbi_state_summary` | One row per state | Active Merchant Count, Regional Churn %, Moniebook Penetration %. |
| `powerbi_feature_summary` | One row per feature | Feature Sessions, Adoption Index, Error/Failure Counts. |

---

## 📈 Dashboard Canvas Breakdown

The Power BI workbook is structured across 8 operational and executive report canvases:

1. **Executive Overview:** High-level platform health, cumulative profit (₦296M), total CLV (₦661M), and adoption summaries.
2. **Product Utilization:** Reach and engagement across all 8 portfolio offerings (Payments, POS, Banking, Moniebook, Loans, Cards, Invoicing, Payroll).
3. **Moniebook Adoption (Hero Canvas):** Visualizing the 220-day adoption lag, sector-level penetration (Pharmacies leading at 35%), and monthly growth curves.
4. **Customer Segmentation:** The volume-to-value pyramid contrasting Micro-merchant scale against Medium/Enterprise capital volume.
5. **Retention & Churn:** Engagement thresholds, login decay cadences (averaging 25 days), and product-count retention curves.
6. **CLV & Revenue Impact:** Profitability thresholds identifying the 4-product sweet spot and profiling top platform champions (₦1.5M–₦3.39M profit).
7. **Regional Performance:** Geographic concentration along key commerce belts (Lagos, Oyo, Ogun, Kano, FCT) vs. high-churn frontier states (Delta at 20%, Anambra at 19%).
8. **Merchant 360 Diagnostic (Drillthrough):** Granular single-merchant diagnostic view featuring adoption checklists, inactivity warnings, and POS failure history.

---

## 💡 Key Business Insights

1. **Enterprise Financial Anchoring:** Large and medium businesses account for less than 20% of headcount but move over ₦72B of transaction volume, yielding average CLVs between ₦300k and ₦750k.
2. **Tool Depth Eliminates Churn:** Merchants utilizing 0–2 products show 64%–68% retention; adding 3–6 products elevates loyalty to ~79%; integrating 7–8 tools achieves 100% retention.
3. **Human Channels Out-Convert Digital:** In-person acquisition channels (**Field Sales at 34.5%** and **Partner Banks at 34%**) dramatically outperform impersonal digital channels (**Social Media at 27%**, **Trade Fairs at 23%**).
4. **Countertop Checkout Pain:** 53,531 failed POS transactions create daily counter friction, acting as the primary catalyst for merchant churn in retail and FMCG sectors.

---

## 🎯 Strategic Recommendations

* **Re-Engineer Onboarding for Day 1–30:** Eliminate the 220-day lag by integrating interactive bookkeeping setup flows into initial account activation.
* **Launch "Moniebook Lite" for Solo Vendors:** Introduce a simplified, single-tap cash-in/cash-out ledger to boost micro-merchant adoption beyond its current 17% baseline.
* **Automate Churn Interventions:** Trigger proactive customer success alerts when an account records >3 consecutive POS transaction drops or exceeds 25 days of inactivity.
* **Bundle Towards the 4-Product Tier:** Package Digital Payments + POS with Banking and Moniebook to systematically cross-sell merchants into the peak profitability tier.
* **Deploy Field Rescue Teams:** Focus field sales and regional support personnel in high-churn commercial markets (Delta, Anambra, and Osun) to resolve local network friction.

---

## ⚠️ Analytical Limitations

* **Synthetic Data Environment:** The data is synthetically modeled across 2024–2025 to simulate customer behaviors and cannot capture unmodeled macroeconomic shocks.
* **POS Failure Root Causes:** Datasets capture failure occurrences but omit hardware/telco/bank error codes to pinpoint exact hardware vs. network fault lines.
* **Churn Classification:** Inactivity metrics do not distinguish between voluntary competitive churn and small-business mortality.

---

## 💻 Tech Stack

* **SQL:** Advanced data transformation, relational grain consolidation, feature extraction.
* **Power BI Desktop:** Multi-page report architecture, custom UI layout, parameter controls, drillthrough actions.
* **DAX:** Inactivity lag modeling, dynamic conditional formatting, customer segmentation measures.
