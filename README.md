# Design Document

By Matheus Teles Marques

Video overview: <URL HERE>

## Scope

The database developed for the `Ciclo Universo` bicycle store is designed to manage orders and inventory, updating stock levels, and storing customer information for support and service. To meet these objectives, the database includes the following entities:

* Customers, including basic information for registration and identification
* Products, including basic product information, in particular product category as the Ciclo Universo store does not only sell bicycles
* Orders, including the number to identify the order, the date and time it was made,
* Items ordered, including the quantity of the item and the price per unit at the time the item was ordered

Out of the scope are elements like employees, suppliers, that were not considered for this initial version of the system that focuses exclusively on orders and inventory.

## Functional Requirements

This database will be able to support:

* Track customer data (contact info, order history)

* Manage product catalog (prices, categories, stock levels)

* Process orders (with item details and historical pricing)

* Update stock automatically when order occur

The system as it was developed is not yet capable of managing employees, maintaining a list of suppliers and apply discounts following some certain logic that should be developed for this.

## Representation

### Entities
The database includes the following entities:

#### Customers

The `customers` table includes:

* `id`, which specifies the unique ID for the customer as an `INTEGER`. This column has the `PRIMARY KEY` constraint applied.
* `first_name`, which specifies the customer's first name as `TEXT`, given `TEXT` is appropriate for name fields.
* `last_name`, which specifies the customer's last name. `TEXT` is used for the same reason as `first_name`.
* `email`, which specifies the customer's email. `TEXT` is used for the same reason as `first_name`. A `UNIQUE` constraint is applied to ensure that two customers cannot have the same email and a `CHECK` constraint validates the email provided.
* `telephone`, which specifies the customer's telephone. `TEXT` is used here because it supports special characters and if we want to improve by implementing some more sophisticated validation logic for pattern or size, so `TEXT` is the appropriate type. A `CHECK` constraint is applied to ensure that the telephone number provided has 11 digits, which is standard in Brazil.
* `address`, which specifies the customer's address. `TEXT` is used for the same reason as `first_name`.

#### Products

The `products` table includes:

* `id`, which specifies the unique ID for the product as an `INTEGER`. This column has the `PRIMARY KEY` constraint applied.
* `name`, which specifies the product's name as `TEXT`.
* `description`, which specifies the product's description as `TEXT`.
* `category`, which specifies the product's category as `TEXT`. A `CHECK` constraint is applied to ensure that the category entered is always among one of the listed options.
* `price`, which specifies the product's price as `NUMERIC`, given `NUMERIC` is appropriate for columns that store floating point numbers by maintaining precision. A `CHECK` constraint is applied to ensure that price values ​​are always greater than 0.
* `inventory`, which specifies the quantity of the product in question in inventory as `INTEGER`. A `CHECK` constraint is applied to ensure the quantity in stock is at least 0.

#### ORDERS

The `orders` table includes:

* `id`, which specifies the unique ID for the order as an `INTEGER`. This column has the `PRIMARY KEY` constraint applied.
* `customer_id`, which is the ID of the customer who made the order as an `INTEGER`. This column has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `customers` table to ensure data integrity.
* `order_number`, which specifies the order number. `TEXT` is used here because it supports special characters and if we want to improve by implementing some more sophisticated validation logic for pattern or size, `TEXT` is the appropriate type. A `UNIQUE` constraint is applied because there cannot be two orders with the same number.
* `total_amount`, which specifies the total value of the order as `NUMERIC`. A `CHECK` constraint is applied to ensure that the amount to be paid is always greater or equal 0. A `DEFAULT` constraint sets 0 as the default value of the column, since the real value will be calculated dynamically according to the quantity of items ordered and their price per unit.
* `status`, which specifies the order status as `TEXT`. A `CHECK` constraint is used to ensure that the order status is always among one of the listed options and a `DEFAULT` constraint sets `pending` as default value when nothing is informed.
* `datetime`, which specifies the the date and time of the order. The `datetime` field is stored as `NUMERIC`, which is a common practice in SQLite for representing timestamps. The default value for the `datetime` attribute is the current timestamp, as denoted by `DEFAULT CURRENT_TIMESTAMP`.

#### ORDER_PRODUCTS

The `order_products` table includes:

* `id`, which specifies the unique ID for the order and product relationship as an `INTEGER`. This column has the `PRIMARY KEY` constraint applied.
* `product_id`, which is the ID of the product contained in the order as an `INTEGER`. This column has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `products` table to ensure data integrity.
* `order_id`, which is the ID of the order as an `INTEGER`. This column has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `orders` table to ensure data integrity.
* `quantity`, which specifies the quantity of items ordered as an `INTEGER`. A `CHECK` constraint is applied to ensure that quantity ordered is always greater than 0.
`unit_price`, which specifies the price per unit of the item ordered as an `NUMERIC`. A `CHECK` constraint is applied for the same reason as in the `quantity` column. A `DEFAULT` constraint sets 0 as the default value of the column, since the real value is obtained directly from the price column of the products table.

### Relationships

The entity relationship diagram below describes the relationships between database entities.

![ER Diagram](.assets/diagram.png)

As shown in the diagram:

* A customer can place zero or more orders. Zero, if he has registered but has not yet placed an order in the store. While an order is made by one customer and only one customer.
* An order can contain one or more products. While the same product can belong to one or more orders.In this case we consider that for an order to be placed at least one product must be included.


## Optimizations

To encapsulate common database queries and simplify them, several views were created, all documented in the `schema.sql`. The views created were for:

* Products in stock or out of stock
* Orders filtered by status
* Order details
* Purchase summaries for store customers
* Products ranked by sales volume
* Daily sales totals and revenue

To optimize frequent queries, indexes were implemented:

* An index on the `inventory` column to accelerate stock status checks
* An index on the `status` column to speed up order filtering
* An index on the `datetime` column to enhance daily sales reporting


## Limitations

The database for `Ciclo Universo` has several important limitations that need addressing in future versions:

* The biggest issue is the absence of `supplier management`, which makes it difficult to track product origins or manage the restocking process efficiently.

* The system also lacks `employee management features`, preventing the tracking of which staff members handle specific orders or any analysis of their performance.

* Another limitation is the absence of a `discount or promotion system`, which significantly restricts marketing options.

* A frustrating operational challenge is the requirement for `manual order status updates`. Attempts to implement triggers to automate this process were unsuccessful. This manual updating is time-consuming and prone to errors, as staff must remember to change each status throughout the order lifecycle instead of having the system handle those transitions automatically. One option to deal with this limitation would be to delegate this responsibility outside of the database, to the application layer. This approach would allow for the implementation of more complex business logic and rules for status transitions, rather than trying to handle this process within the database itself.

* Another related limitation is the lack of `transaction integrity between orders and order products`. When a rollback occurs due to failures in the `order_products table`, the corresponding order in the `orders` table isn't automatically marked as canceled. This disconnect can lead to inconsistent order records, creating potential data integrity issues. This limitation further emphasizes the need for application-level management of the order process to ensure proper coordination between related tables and appropriate status updates when transactions fail.

