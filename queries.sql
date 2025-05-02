-- SELECTS

-- Find all products available in stock
SELECT * FROM "products_available_in_stock";

-- Find all products out of stock
SELECT * FROM "out_of_stock_products";

-- Find information on orders related to a specific status('pending', 'paid', 'shipped', 'delivered', 'canceled')
SELECT * FROM "order_with_status" WHERE "status" = 'pending';

-- Find more details about the orders
SELECT * FROM "order_details";

-- Find a summary of purchases made by customers
SELECT * FROM "customer_purchase_summary";

-- Find a report of sales made each day
SELECT * FROM "sales_by_date";

-- INSERTS
-- Registering customers, products and some orders in our system

-- INSERT INTO customers
INSERT INTO "customers" ("id", "first_name", "last_name", "email", "telephone", "address") VALUES
(1, 'Pedro', 'Silva', 'pedro.silva@example.com', '62999900001', '123 Avenida Goiás, Setor Central, Goiânia, Goiás'),
(2, 'Ana', 'Oliveira', 'ana.oliveira@example.com', '62999900002', '456 Rua 10, Setor Oeste, Goiânia, Goiás'),
(3, 'Carlos', 'Santos', 'carlos.santos@example.com', '62999900003', '789 Avenida T-63, Setor Bueno, Goiânia, Goiás'),
(4, 'Mariana', 'Costa', 'mariana.costa@example.com', '62999900004', '101 Rua 5, Setor Sul, Goiânia, Goiás'),
(5, 'Rafael', 'Pereira', 'rafael.pereira@example.com', '62999900005', '202 Avenida Anhanguera, Setor Campinas, Goiânia, Goiás'),
(6, 'Juliana', 'Ferreira', 'juliana.ferreira@example.com', '62999900006', '303 Avenida Vera Cruz, Jardim Goiás, Goiânia, Goiás'),
(7, 'Lucas', 'Almeida', 'lucas.almeida@example.com', '62999900007', '404 Rua 20, Setor Marista, Goiânia, Goiás'),
(8, 'Fernanda', 'Rodrigues', 'fernanda.rodrigues@example.com', '62999900008', '505 Avenida Rio Verde, Cidade Jardim, Aparecida de Goiânia, Goiás'),
(9, 'Gustavo', 'Gomes', 'gustavo.gomes@example.com', '62999900009', '606 Rua Tapajós, Setor Vila Brasília, Aparecida de Goiânia, Goiás'),
(10, 'Patricia', 'Sousa', 'patricia.sousa@example.com', '62999900010', '707 Avenida São Paulo, Setor Garavelo, Aparecida de Goiânia, Goiás');

-- INSERT INTO products
INSERT INTO "products" ("id", "name", "description", "category", "price", "inventory") VALUES
(1, 'Mountain Pro Bike', 'Professional mountain bike with 21 gears and suspension', 'bicycle', 1299.99, 15),
(2, 'Urban Commuter Bike', 'Comfortable city bike for daily commuting', 'bicycle', 799.99, 20),
(3, 'Road Racing Bike', 'Lightweight racing bike with carbon frame', 'bicycle', 1899.99, 10),
(4, 'Kids Mountain Bike', 'Mountain bike designed for children ages 8-12', 'bicycle', 399.99, 25),
(5, 'Bike Helmet', 'Safety certified helmet with adjustable fit', 'accessories', 89.99, 50),
(6, 'LED Bike Light Set', 'Front and rear LED lights for night riding', 'accessories', 39.99, 45),
(7, 'Bicycle Chain', 'Durable replacement chain compatible with most bikes', 'bicycle components', 29.99, 60),
(8, 'Carbon Fiber Handlebar', 'Lightweight carbon fiber handlebar for racing bikes', 'bicycle components', 119.99, 30),
(9, 'Bicycle Saddle', 'Ergonomic cushioned saddle for comfortable riding', 'bicycle components', 49.99, 40),
(10, 'Cycling Gloves', 'Padded gloves for protection and grip', 'accessories', 24.99, 75);

-- INSERT INTO orders (without status or total_amount as they will be generated automatically)
INSERT INTO "orders" ("id", "customer_id", "order_number", "datetime") VALUES
(1, 3, 'ORD-2025-001', '2025-01-15 14:30:00'),
(2, 7, 'ORD-2025-002', '2025-02-03 09:45:00'),
(3, 2, 'ORD-2025-003', '2025-02-27 16:20:00'),
(4, 5, 'ORD-2025-004', '2025-03-10 11:15:00'),
(5, 9, 'ORD-2025-005', '2025-03-18 13:45:00'),
(6, 1, 'ORD-2025-006', '2025-03-25 10:30:00'),
(7, 10, 'ORD-2025-007', '2025-04-02 15:40:00'),
(8, 4, 'ORD-2025-008', '2025-04-10 09:20:00'),
(9, 6, 'ORD-2025-009', '2025-04-18 14:10:00'),
(10, 8, 'ORD-2025-010', '2025-04-22 16:50:00');

-- INSERT INTO order products (without unit_price as it will be generated automatically)
INSERT INTO "order_products" ("id", "product_id", "order_id", "quantity") VALUES
(1, 1, 1, 1),
(2, 5, 1, 1),
(3, 6, 1, 1),
(4, 2, 2, 1),
(5, 9, 2, 1),
(6, 3, 3, 1),
(7, 4, 4, 1),
(8, 5, 4, 1),
(9, 6, 4, 2),
(10, 1, 5, 1),
(11, 8, 5, 1),
(12, 5, 5, 1),
(13, 10, 5, 5),
(14, 5, 6, 1),
(15, 2, 7, 1),
(16, 9, 7, 1),
(17, 3, 7, 1),
(18, 5, 8, 2),
(19, 3, 9, 1),
(20, 8, 9, 1),
(21, 7, 9, 1),
(22, 10, 9, 3),
(23, 4, 10, 1);

-- UPDATE
-- System updates occur primarily to: change order status, modify products in orders, and adjust product quantities

-- Update an order status from 'pending' to 'canceled'
UPDATE "orders" SET "status" = 'canceled'
WHERE "id" = 1;

-- Replace a product in an order with a different product
UPDATE "order_products" SET "product_id" = (
    SELECT "id" FROM "products"
    WHERE "name" = 'Mountain Pro Bike'
)
WHERE "id" = 2;

-- Adjust the quantity of a product in an order
UPDATE "order_products" SET "quantity" = 2
WHERE "id" = 2;

-- DELETE

-- In addition to typical cases of deletion of customers, products and orders like
DELETE FROM "customers" WHERE "id" = 2;
DELETE FROM "products" WHERE "id" = 4;
DELETE FROM "orders" WHERE "id" = 5;

-- In the system it is very common to delete items from an order, which can remove an item from the order but not cancel the entire order
DELETE FROM "order_products" WHERE "id" = 1;

