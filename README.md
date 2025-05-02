# Ciclo Universo - Bicycle Store Database

**CS50 SQL Final Project**

This project implements a comprehensive database system for "Ciclo Universo," a bicycle store that needs to manage orders and inventory. The database tracks orders placed, updates stock levels, and stores customer information for support and service.

## Project Overview

The Ciclo Universo database is designed to:

* Track customer data (contact info, order history)
* Manage product catalog (prices, stock levels)
* Process orders (with item details)
* Update stock automatically when orders occur

## Database Structure

### Main Entities

* **Customers:** Stores customer information including contact details.
* **Products:** Contains product details, categorization, pricing, and inventory levels.
* **Orders:** Tracks order information, status, and associated customer.
* **Order\_Products:** Links products to orders with quantity and price-at-time information.

### Optimizations

* **Views:** Several views are implemented to simplify common queries:
    * Products in/out of stock
    * Orders filtered by status
    * Order details
    * Customer purchase summaries
    * Product sales volumes
    * Daily sales metrics

* **Indexes:** Strategic indexes improve query performance for:
    * Inventory checks
    * Order status filtering
    * Date-based sales reporting

### Files in this Repository

* `schema.sql`: Database schema with all tables, views, and indexes.
* `design.md`: Detailed design document explaining database architecture.
* `queries.sql`: Sample queries demonstrating database functionality.
* `assets/diagram.png`: Entity relationship diagram showing database structure.

## How to Use

1.  Clone this repository.
2.  Import the schema into SQLite:
    ```bash
    sqlite3 bike.db < schema.sql
    ```
3.  Explore the database using the sample queries in `queries.sql`.

## Limitations

The current version has some limitations:

* No supplier management
* No employee management
* No discount or promotion system
* Manual order status updates (no automation)
* No payment system implementation

## Future Improvements

Future iterations could include:

* Supplier management system
* Employee tracking
* Discount and promotion functionality
* Automated order status progression
* Payment processing integration

## Author

[Matheus Teles Marques](https://github.com/matheusmarqs1)

## Acknowledgements

This project was completed as part of the CS50 SQL course by Harvard University.

