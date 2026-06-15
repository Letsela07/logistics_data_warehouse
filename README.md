# Logistics Data Warehouse

## Project Overview
This project demonstrates the design and implementation 
of an end-to-end Logistics Data Warehouse using the 
Medallion Architecture (Bronze → Silver → Gold).

## Business Objectives
- How satisfied are customers with logistics service?
- Which carriers perform best?
- Which products are shipped most frequently?
- What factors contribute to shipment delays?
- How do logistics operations perform across regions?

## KPIs
- Customer Satisfaction Score
- Best Performing Carrier
- Most Ordered Product Category
- Average Delivery Lead Time
- Average Delay Hours
- Damage Claims Count

## Data Sources
- customer.csv — 750 records
- shipment.csv — 704 records
- logistics_performance.csv — 100 records

## Architecture
Follows Medallion Architecture:
- Bronze → Raw data as-is
- Silver → Cleaned and standardized
- Gold → Business ready Star Schema
- Consumption → Power BI dashboards

## Project Structure
logistics_data_warehouse/
├── datasets/
├── docs/
│   ├── architecture/
│   └── screenshots/
├── drawio/
├── sql/
│   ├── bronze/
│   ├── silver/
│   └── gold/
├── python/
├── powerbi/
└── README.md

## Current Progress

### Completed ✅
- Project planning and folder structure
- Business requirements analysis
- Warehouse architecture design
- Star schema designs (customer, shipment, logistics)
- GitHub repository setup
- Bronze layer — all 3 tables loaded
  - 750 customer records
  - 704 shipment records
  - 100 logistics performance records
- Silver layer — all 3 tables cleaned and loaded
  - Proper data types applied
  - Columns renamed for clarity
  - Data quality issues identified and handled

### In Progress 🔄
- Gold layer dimensional models

### Planned 📋
- Power BI dashboards
- Stored procedures for automation
- Python ETL scripts

## Data Quality Issues Found
- Leading spaces in country columns → fixed with TRIM()
- Mixed data in customs_clearance_time_days → fixed with CASE WHEN
- Malformed rows every 9th/10th record → handled with TRY_CAST and LEFT()
- Root cause: Suspected source system export bug

## Technologies
- SQL Server & SSMS
- PostgreSQL & DBeaver
- VS Code
- Draw.io
- Notion
- GitHub
- Power BI (coming soon)
- Python (coming soon)

## Author
Letsela Lebohang
BSc Informatics Student | Aspiring Data Engineer
BrightLearn Data Engineering Bootcamp 2026
Cape Town, South Africa