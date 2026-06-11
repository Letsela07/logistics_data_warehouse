# Logistics Data Warehouse

## Project Overview

This project demonstrates the design and implementation of an end-to-end Logistics Data Warehouse using dimensional modeling and data warehousing principles.

The objective is to integrate customer, shipment, and logistics performance data into a structured warehouse that supports reporting, analytics, and future automation.

---

## Business Objectives

The warehouse is designed to answer key business questions:

* How satisfied are customers with the logistics service?
* Which carriers perform best?
* Which products are shipped most frequently?
* What factors contribute to shipment delays?
* How do logistics operations perform across regions?

---

## Key Performance Indicators (KPIs)

* Customer Satisfaction Score
* Best Performing Carrier
* Most Ordered Product Category
* Average Delivery Lead Time
* Average Delay Hours
* Damage Claims Count

---

## Data Sources

### customer.csv

Contains customer acquisition, order, payment, and satisfaction information.

### shipment.csv

Contains shipment details, freight costs, delivery status, and product categories.

### logistics_performance.csv

Contains carrier performance metrics, delay statistics, warehouse utilization, and damage claims.

---

## Project Structure

```text
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
```

---

## Architecture

The project follows the Medallion Architecture approach:

### Bronze Layer

Stores raw source data without transformation.

### Silver Layer

Cleans, standardizes, and validates source data.

### Gold Layer

Creates business-ready dimensional models and analytics tables.

### Consumption Layer

Supports reporting, dashboards, and future machine learning use cases.

---

## Current Progress

### Completed

* Project planning and folder structure
* Business requirements analysis
* Warehouse architecture design
* Customer star schema design
* GitHub repository setup

### In Progress

* Shipment dimensional modeling
* Logistics performance dimensional modeling

### Planned

* Bronze layer implementation
* Silver layer transformations
* Gold layer dimensional models
* Power BI dashboards
* Pipeline automation

---

## Technologies

* PostgreSQL
* SQL
* Python
* VS Code
* Draw.io
* GitHub
* Power BI

---

## Author

Letsela Lebohang

BSc Informatics Student | Aspiring Data Engineer
