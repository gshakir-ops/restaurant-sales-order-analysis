# Restaurant Orders Analytics

A comprehensive SQL analysis project demonstrating data analytics skills using real restaurant order data spanning January - March 2023.

## 📊 Project Overview

This project analyzes 5,370 orders across 33 menu items and 4 cuisine categories to extract actionable business insights. The analysis covers revenue optimization, customer behavior, menu performance, and operational efficiency.

**Dataset**: 12,233+ order transactions over 3 months

## 📁 Project Structure

```
Restaurant_Orders_Analytics/
├── data/
│   ├── raw/
│   │   ├── order_details.csv (12,233 transactions)
│   │   └── menu_items.csv (33 items, 4 categories)
│   └── processed/
│       └── analysis_results/
├── sql/
│   ├── 01_setup/
│   │   └── create_tables.sql
│   ├── 02_analysis/
│   │   ├── revenue_analysis.sql
│   │   ├── menu_performance.sql
│   │   └── customer_behavior.sql
│   └── 03_advanced/
│       ├── cohort_analysis.sql
│       └── trend_analysis.sql
├── analysis/
│   ├── key_findings.md
│   └── recommendations.md
└── README.md
```

## 🎯 Key Questions Answered

### Revenue & Performance
1. **Total Revenue & AOV** - What's our revenue and average order value?
2. **Top Revenue Drivers** - Which items and categories generate the most revenue?
3. **Revenue by Category** - How does each cuisine category perform?

### Menu Analysis
4. **Best Performers** - Which items are ordered most frequently?
5. **Price-Demand Correlation** - Do higher-priced items sell less?
6. **Category Trends** - Which cuisine categories dominate orders?

### Customer Insights
7. **Peak Hours** - When do customers order most?
8. **Order Patterns** - What's the average order size?
9. **Item Pairing** - Which items are commonly ordered together?

### Business Optimization
10. **Low-Performance Items** - Which items should be reconsidered?
11. **Growth Opportunities** - Which categories should we expand?
12. **Daily Trends** - How does volume fluctuate over time?

## 🔧 Getting Started

### Prerequisites
- SQL database (MySQL, PostgreSQL, SQLite, or similar)
- CSV file reader/importer for your database

### Setup Instructions

1. **Create tables**:
```bash
# Run the setup script to create tables and load data
mysql -u username -p < sql/01_setup/create_tables.sql
```

2. **Import CSV data**:
```bash
# Load order_details and menu_items into respective tables
```

3. **Run analysis queries**:
```bash
# Execute queries from sql/02_analysis/ directory
mysql -u username -p < sql/02_analysis/revenue_analysis.sql
```

## 📈 Key Findings

### Revenue Metrics
- **Total Revenue**: $67,348.65
- **Total Orders**: 5,370
- **Average Order Value**: $12.54
- **Items per Order**: 2.28

### Top Performers
- **Best Item**: Chicken Parmesan ($17.95) - 230 orders
- **Top Category**: Asian Cuisine (28.4% of orders)
- **Highest Revenue Item**: Korean Beef Bowl

### Operational Insights
- **Peak Hours**: 12:00 PM - 2:00 PM (lunch rush)
- **Slowest Period**: 9:00 AM - 11:00 AM
- **Average Order Composition**: 2-3 items per order

## 💡 Strategic Recommendations

1. **Expand Asian Category** - Highest demand and order frequency
2. **Optimize Low-Performers** - Consider removing or repricing underperforming items
3. **Bundle Complementary Items** - Create combo meals based on pairing analysis
4. **Staffing** - Increase capacity during 12 PM - 2 PM peak
5. **Menu Pricing** - Review pricing strategy; higher prices don't always mean lower volume

## 📊 Analysis Files

### SQL Queries
- **revenue_analysis.sql** - Revenue metrics, AOV, category performance
- **menu_performance.sql** - Item rankings, demand analysis
- **customer_behavior.sql** - Order patterns, peak hours, basket analysis
- **cohort_analysis.sql** - Time-based trends and daily patterns
- **advanced_analysis.sql** - Complex correlations and predictions

### Reports
- **key_findings.md** - Executive summary of insights
- **recommendations.md** - Actionable business recommendations

## 🛠️ Technical Stack

- **SQL**: Standard SQL (compatible with MySQL, PostgreSQL, SQLite)
- **Data Source**: CSV files with 12,233 transactions
- **Analysis Period**: January 1 - March 31, 2023
- **Complexity**: Intermediate (JOINs, aggregations, window functions)

## 📋 Methodology

This analysis uses:
- **Aggregate Functions**: SUM, COUNT, AVG, MAX, MIN
- **JOINs**: Combining order details with menu items
- **GROUP BY**: Analyzing by category, item, and time period
- **Window Functions**: Running totals and rankings
- **Date Functions**: Time-based analysis and trends

## 🎓 Learning Outcomes

This project demonstrates:
✅ Complex SQL queries and data aggregation
✅ Business analytics and insight generation
✅ Data exploration and pattern recognition
✅ Report writing and recommendations
✅ Real-world dataset analysis
✅ Performance optimization thinking

## 📝 Data Dictionary

### order_details table
- `order_details_id`: Unique identifier for each line item
- `order_id`: Groups items belonging to same order
- `order_date`: Transaction date (MM/DD/YY format)
- `order_time`: Transaction time (HH:MM:SS AM/PM)
- `item_id`: Reference to menu_items table

### menu_items table
- `menu_item_id`: Unique item identifier
- `item_name`: Descriptive name of menu item
- `category`: Cuisine type (American, Asian, Mexican, Italian)
- `price`: Menu price in USD

## 🚀 Next Steps

- [ ] Import data into your SQL database
- [ ] Run setup script to create tables
- [ ] Execute analysis queries
- [ ] Review findings and recommendations
- [ ] Generate visualizations (Power BI, Tableau)
- [ ] Present insights to stakeholders

## 📧 Contact & Support

For questions or improvements to this analysis, feel free to reach out or submit a pull request.

---

**Last Updated**: September 20, 2026
**Status**: Production Ready
**Difficulty**: Intermediate SQL
