-- Represents the store's customers
CREATE TABLE "customers" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "email" TEXT NOT NULL UNIQUE CHECK("email" LIKE '%@%.%'),
    "telephone" TEXT NOT NULL CHECK(LENGTH("telephone") = 11),
    "address" TEXT NOT NULL,
    PRIMARY KEY("id")
);

-- Represents the store's products
CREATE TABLE "products" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "category" TEXT NOT NULL CHECK("category" IN ('bicycle', 'bicycle components', 'accessories')),
    "price" NUMERIC NOT NULL CHECK("price" > 0.0),
    "inventory" INTEGER NOT NULL CHECK("inventory" >= 0),
    PRIMARY KEY("id")
);

-- Represents the order made by the client
CREATE TABLE "orders" (
    "id" INTEGER,
    "customer_id" INTEGER,
    "order_number" TEXT NOT NULL UNIQUE,
    "total_amount" NUMERIC NOT NULL CHECK("total_amount" >= 0.0) DEFAULT 0.0,
    "status" TEXT NOT NULL CHECK("status" IN ('pending', 'paid', 'shipped', 'delivered', 'canceled')) DEFAULT 'pending',
    "datetime" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE
);

-- Represents the items requested by the customer and which make up the order
CREATE TABLE "order_products" (
    "id" INTEGER,
    "product_id" INTEGER,
    "order_id" INTEGER,
    "quantity" INTEGER NOT NULL CHECK("quantity" > 0),
    "unit_price" NUMERIC NOT NULL CHECK("unit_price" >= 0.0) DEFAULT 0.0,
    PRIMARY KEY("id"),
    FOREIGN KEY("product_id") REFERENCES "products"("id") ON DELETE CASCADE,
    FOREIGN KEY("order_id") REFERENCES "orders"("id") ON DELETE CASCADE
);

-- VIEWS

-- Presents the products available in stock
CREATE VIEW "products_available_in_stock" AS
SELECT "name", "description", "category", "price", "inventory"
FROM "products"
WHERE "inventory" > 0;

-- Presents the products that are out of stock
CREATE VIEW "out_of_stock_products" AS
SELECT "name","description", "category", "price", "inventory"
FROM "products"
WHERE "inventory" = 0;

-- Presents order information that will be consulted according to the status
CREATE VIEW "order_with_status" AS
SELECT "order_number", "status", "total_amount", "datetime", "first_name", "last_name", "telephone"
FROM "orders"
JOIN "customers" ON "customers"."id" = "orders"."customer_id";

-- Presents details of each order made
CREATE VIEW "order_details" AS
SELECT "order_number", "status", "datetime", "first_name", "last_name", "email", "telephone", "products"."name", "unit_price", "quantity"
FROM "orders"
JOIN "customers" ON "customers"."id" = "orders"."customer_id"
JOIN "order_products" ON "orders"."id" = "order_products"."order_id"
JOIN "products" ON "products"."id" = "order_products"."product_id";

-- Presents a summary of customer purchases (only orders that are not marked as pending or canceled are considered)
CREATE VIEW "customer_purchase_summary" AS
SELECT "first_name", "last_name","telephone", "email", COUNT(*) AS "total_orders", SUM("total_amount") AS "total_spent"
FROM "customers"
JOIN "orders" ON "customers"."id" = "orders"."customer_id"
WHERE "status" NOT IN ('pending', 'canceled')
GROUP BY "customers"."id"
ORDER BY "total_spent" DESC, "total_orders" DESC, "first_name";

-- Presents a list of the sales volume of each product (only orders that are not marked as pending or canceled are considered)
CREATE VIEW "products_by_sales_volume" AS
SELECT "name", "description", "category", SUM("quantity") AS "total_sold"
FROM "products"
JOIN "order_products" ON "products"."id" = "order_products"."product_id"
JOIN "orders" ON "order_products"."order_id" = "orders"."id"
WHERE "status" NOT IN ('pending', 'canceled')
GROUP BY "products"."id"
ORDER BY "total_sold" DESC;

-- Presents a summary of sales by date (we only include orders that are not marked as pending or canceled)
CREATE VIEW "sales_by_date" AS
SELECT DATE("datetime") AS "order_date", COUNT(*) AS "total_orders", SUM("total_amount") AS "total_revenue"
FROM "orders"
WHERE "status" NOT IN ('pending', 'canceled')
GROUP BY "datetime"
ORDER BY "order_date" DESC;


-- TRIGGERS

-- Triggered whenever an order item is inserted, calculating the total amount
CREATE TRIGGER "update_total_amount_after_insert"
AFTER INSERT ON "order_products"
FOR EACH ROW
BEGIN
    UPDATE "orders" SET "total_amount" = (
        SELECT SUM("quantity" * "unit_price")
        FROM "order_products"
        WHERE "order_id" = NEW."order_id"
    )
    WHERE "id" = NEW."order_id";
END;

-- Triggered whenever an order item is updated, calculating the total amount
CREATE TRIGGER "update_total_amount_after_update"
AFTER UPDATE ON "order_products"
FOR EACH ROW
BEGIN
    UPDATE "orders" SET "total_amount" = (
        SELECT SUM("quantity" * "unit_price")
        FROM "order_products"
        WHERE "order_id" = NEW."order_id"
    )
    WHERE "id" = NEW."order_id";
END;

-- Triggered whenever an order item is deleted, calculating the total value
CREATE TRIGGER "update_total_amount_after_delete"
AFTER DELETE ON "order_products"
FOR EACH ROW
BEGIN
    UPDATE "orders" SET "total_amount" = (
         SELECT SUM("quantity" * "unit_price")
         FROM "order_products"
         WHERE "order_id" = OLD."order_id"
    )
    WHERE "id" = OLD."order_id";
END;

-- Triggered whenever an order item is updated, validating whether the quantity informed is available in stock
CREATE TRIGGER "prevent_insufficient_stock_before_update"
BEFORE UPDATE ON "order_products"
FOR EACH ROW
WHEN (SELECT "inventory" FROM "products" WHERE "id" = NEW."product_id") < NEW."quantity"
BEGIN
    SELECT RAISE(ROLLBACK, 'Insufficient stock to update the order item');
END;

-- Triggered whenever an order item is inserted, validating whether the quantity informed is available in stock
CREATE TRIGGER "prevent_insufficient_stock_before_insert"
BEFORE INSERT ON "order_products"
FOR EACH ROW
WHEN (SELECT "inventory" FROM "products" WHERE "id" = NEW."product_id") < NEW."quantity"
BEGIN
    SELECT RAISE(ROLLBACK, 'Insufficient stock to add the item to the order');
END;

-- Triggered whenever an attempt is made to insert items into an order that is not pending
CREATE TRIGGER "prevent_modifications_to_non_pending_orders_before_insert"
BEFORE INSERT ON "order_products"
FOR EACH ROW
WHEN(SELECT "status" FROM "orders" WHERE "id" = NEW."order_id") != 'pending'
BEGIN
    SELECT RAISE(ROLLBACK, 'Cannot insert products into an order that is not pending');
END;

-- Triggered whenever there is an attempt to update items on an order that is not pending
CREATE TRIGGER "prevent_modifications_to_non_pending_orders_before_update"
BEFORE UPDATE ON "order_products"
FOR EACH ROW
WHEN(SELECT "status" FROM "orders" WHERE "id" = NEW."order_id") != 'pending'
BEGIN
    SELECT RAISE(ROLLBACK, 'Cannot update products unless order is pending');
END;

-- Triggered whenever there is an attempt to delete items on an order that is not pending
CREATE TRIGGER "prevent_modifications_to_non_pending_orders_before_delete"
BEFORE DELETE ON "order_products"
FOR EACH ROW
WHEN(SELECT "status" FROM "orders" WHERE "id" = OLD."order_id") != 'pending'
BEGIN
    SELECT RAISE(ROLLBACK, 'It is not possible to delete products from a non-pending order');
END;

-- Triggered whenever an item in the order is inserted, calculating the unit price based on the price column in the products table
CREATE TRIGGER "set_unit_price_before_insert"
AFTER INSERT ON "order_products"
FOR EACH ROW
BEGIN
    UPDATE "order_products"
    SET "unit_price" = (SELECT "price" FROM "products" WHERE "id" = NEW."product_id")
    WHERE "id" = NEW."id";
END;

-- Triggered whenever an item in the order is updated, calculating the unit price based on the price column in the product table
CREATE TRIGGER "set_unit_price_before_update"
BEFORE UPDATE OF "product_id" ON "order_products"
FOR EACH ROW
BEGIN
    UPDATE "order_products"
    SET "unit_price" = (SELECT "price" FROM "products" WHERE "id" = NEW."product_id")
    WHERE "id" = NEW."id";
END;

-- Triggered whenever an order is marked as paid, deducting the quantity of items from stock
CREATE TRIGGER "update_inventory_after_order_paid"
AFTER UPDATE ON "orders"
FOR EACH ROW
WHEN NEW."status" = 'paid' AND OLD."status" != 'paid'
BEGIN
    UPDATE "products" SET "inventory" = "inventory" - (
        SELECT SUM("quantity") FROM "order_products"
        WHERE "product_id" = "products"."id"
        AND "order_id" = NEW."id"
    )
    WHERE "id" IN (
        SELECT "product_id" FROM "order_products"
        WHERE "order_id" = NEW."id"
    );
END;

--Triggered whenever an order is marked as canceled, restoring the quantity of items in stock
CREATE TRIGGER "restore_inventory_after_order_canceled"
AFTER UPDATE ON "orders"
FOR EACH ROW
WHEN NEW."status" = 'canceled' AND OLD."status" != 'canceled'
BEGIN
    UPDATE "products" SET "inventory" = "inventory" + (
        SELECT SUM("quantity") FROM "order_products"
        WHERE "product_id" = "products"."id"
        AND "order_id" = NEW."id"
    )
    WHERE "id" IN (
        SELECT "product_id" FROM "order_products"
        WHERE "order_id" = NEW."id"
    );
END;

-- Triggered whenever an attempt is made to create an order that is not pending
-- (by default, all orders in the system must be registered as pending and then updated)

CREATE TRIGGER "enforce_pending_status_before_order_creation"
BEFORE INSERT ON "orders"
FOR EACH ROW
WHEN NEW."status" != 'pending'
BEGIN
    SELECT RAISE(ROLLBACK, 'Orders can only be created with pending status');
END;

-- INDEXES

CREATE INDEX "product_inventory_search" ON "products"("inventory");
CREATE INDEX "order_status_search" ON "orders"("status");
CREATE INDEX "order_datetime_search" ON "orders"("datetime");

