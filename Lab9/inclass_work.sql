-- Create categories table
CREATE TABLE categories (
 category_id SERIAL PRIMARY KEY,
 category_name VARCHAR(50),
 description TEXT
);
-- Insert sample data
INSERT INTO categories (category_name, description) VALUES
('Electronics', 'Computers, phones, and gadgets'),
('Clothing', 'Fashion and apparel'),
('Books', 'Physical and digital books'),
('Home & Kitchen', 'Household items and appliances'),
('Sports', 'Sports equipment and accessories');
-- Create products table
CREATE TABLE products (
 product_id SERIAL PRIMARY KEY,
 product_name VARCHAR(100),
 category_id INTEGER REFERENCES categories(category_id),
 price NUMERIC(10,2),
 stock_quantity INTEGER,
 rating NUMERIC(2,1),
 vendor VARCHAR(100)
);
-- Insert sample data
INSERT INTO products (product_name, category_id, price, stock_quantity, rating, vendor)
VALUES
('iPhone 15 Pro', 1, 599990, 25, 4.8, 'Apple Store KZ'),
('Samsung Galaxy S24', 1, 499990, 30, 4.7, 'Samsung Kazakhstan'),
('MacBook Air M2', 1, 899990, 15, 4.9, 'Apple Store KZ'),
('Wireless Mouse', 1, 12990, 100, 4.5, 'Logitech Kazakhstan'),
('Mechanical Keyboard', 1, 45990, 50, 4.6, 'Keychron Asia'),
('Winter Jacket', 2, 89990, 40, 4.4, 'Zara Kazakhstan'),
('Running Shoes', 2, 54990, 60, 4.7, 'Nike Almaty'),
('Cotton T-Shirt', 2, 8990, 150, 4.3, 'H&M Kazakhstan'),
('Database Systems Book', 3, 15990, 80, 4.9, 'Meloman Books'),
('Clean Code', 3, 18990, 45, 4.8, 'Meloman Books'),
('Coffee Maker', 4, 69990, 20, 4.5, 'Philips KZ'),
('Blender', 4, 34990, 35, 4.4, 'Bosch Kazakhstan'),
('Yoga Mat', 5, 12990, 70, 4.6, 'Decathlon Almaty'),
('Dumbbells Set', 5, 45990, 25, 4.7, 'Sportmaster KZ');
-- Create customers table
CREATE TABLE customers (
 customer_id SERIAL PRIMARY KEY,
 full_name VARCHAR(100),
 email VARCHAR(100),
 phone VARCHAR(20),
 city VARCHAR(50),
 loyalty_points INTEGER,
 registration_date DATE
);
-- Insert sample data
INSERT INTO customers (full_name, email, phone, city, loyalty_points, registration_date)
VALUES
('Әлішер Нұрғожин', 'alisher.n@mail.kz', '+77011234567', 'Almaty', 1250, '2023-01-15'),
('Балжан Сериккызы', 'balzhan.s@gmail.com', '+77012345678', 'Astana', 890, '2023-03-20'),
('Дамир Төлеуов', 'damir.t@inbox.kz', '+77023456789', 'Almaty', 2100, '2022-11-05'),
('Жанель Қайратқызы', 'zhanel.k@mail.kz', '+77034567890', 'Shymkent', 450, '2023-06-10'),
('Ернар Бекжанов', 'ernar.b@gmail.com', '+77045678901', 'Almaty', 3500, '2022-08-15'),
('Сандуғаш Амантай', 'sandugash.a@inbox.kz', '+77056789012', 'Karaganda', 670, '2023-04-22'),
('Нұрсұлтан Әлімов', 'nursultan.a@mail.kz', '+77067890123', 'Almaty', 1800, '2023-02-18'),
('Айым Жұмабекова', 'aiym.zh@gmail.com', '+77078901234', 'Astana', 950, '2023-05-30');
-- Create orders table
CREATE TABLE orders (
 order_id SERIAL PRIMARY KEY,
 customer_id INTEGER REFERENCES customers(customer_id),
 order_date TIMESTAMP,
 total_amount NUMERIC(12,2),
 discount_amount NUMERIC(10,2),
 status VARCHAR(20),
 payment_method VARCHAR(20),
 delivery_address TEXT
);
-- Insert sample data
INSERT INTO orders (customer_id, order_date, total_amount, discount_amount, status,
payment_method, delivery_address) VALUES
(1, '2024-11-01 10:30:00', 612980.00, 12990.00, 'delivered', 'card', 'Almaty, Dostyk Ave, 123'),
(1, '2024-11-15 14:20:00', 45990.00, 0.00, 'processing', 'card', 'Almaty, Dostyk Ave, 123'),
(2, '2024-11-02 09:15:00', 899990.00, 0.00, 'delivered', 'kaspi', 'Astana, Mangilik El, 55'),
(3, '2024-11-03 16:45:00', 138970.00, 8990.00, 'delivered', 'card', 'Almaty, Furmanov St, 88'),
(4, '2024-11-05 11:00:00', 54990.00, 0.00, 'shipped', 'cash', 'Shymkent, Baidibek Bi, 12'),
(5, '2024-11-06 13:30:00', 154980.00, 15990.00, 'delivered', 'kaspi', 'Almaty, Abai Ave, 45'),
(6, '2024-11-08 10:00:00', 69990.00, 0.00, 'delivered', 'card', 'Karaganda, Bukhar Zhyrau, 23'),
(7, '2024-11-10 15:45:00', 34990.00, 0.00, 'delivered', 'kaspi', 'Almaty, Satpaev St, 90'),
(8, '2024-11-12 12:20:00', 108980.00, 12990.00, 'processing', 'card', 'Astana, Kabanbay Batyr, 14'),
(3, '2024-11-14 09:30:00', 45990.00, 0.00, 'shipped', 'card', 'Almaty, Furmanov St, 88');
-- Create order_items table
CREATE TABLE order_items (
 item_id SERIAL PRIMARY KEY,
 order_id INTEGER REFERENCES orders(order_id),
 product_id INTEGER REFERENCES products(product_id),
 quantity INTEGER,
 price_at_purchase NUMERIC(10,2)
);
-- Insert sample data
INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase) VALUES
(1, 1, 1, 599990.00),
(1, 4, 1, 12990.00),
(2, 5, 1, 45990.00),
(3, 3, 1, 899990.00),
(4, 6, 1, 89990.00),
(4, 7, 1, 54990.00),
(5, 7, 1, 54990.00),
(6, 9, 1, 15990.00),
(6, 10, 1, 18990.00),
(6, 3, 1, 899990.00),
(7, 11, 1, 69990.00),
(8, 12, 1, 34990.00),
(9, 6, 1, 89990.00),
(9, 13, 1, 12990.00),
(10, 14, 1, 45990.00);
-- Create reviews table
CREATE TABLE reviews (
 review_id SERIAL PRIMARY KEY,
 product_id INTEGER REFERENCES products(product_id),
 customer_id INTEGER REFERENCES customers(customer_id),
 rating INTEGER,
 review_text TEXT,
 review_date DATE
);
-- Insert sample data
INSERT INTO reviews (product_id, customer_id, rating, review_text, review_date) VALUES
(1, 1, 5, 'Отличный телефон! Камера просто супер!', '2024-11-05'),
(3, 2, 5, 'Лучший ноутбук для работы и учебы', '2024-11-08'),
(7, 4, 5, 'Очень удобные кроссовки', '2024-11-12'),
(9, 5, 5, 'Must-have книга для всех программистов', '2024-11-15'),
(11, 6, 4, 'Хорошая кофеварка, но немного шумная', '2024-11-14'),
(6, 3, 4, 'Качественная куртка, но маломерит', '2024-11-10');




-- Task 1.1
CREATE OR REPLACE FUNCTION calculate_dynamic_discount(order_total NUMERIC, loyalty_points INT)
RETURNS NUMERIC
AS $$
    DECLARE
        base_discount NUMERIC := 0;
        loyalty_discount NUMERIC := 0;
    BEGIN
        IF order_total > 500000 THEN
            base_discount := 10;
        ELSIF order_total > 100000 THEN
            base_discount := 5;
        END IF;

        loyalty_discount := LEAST(loyalty_points / 1000.0, 10);

        RETURN order_total * (base_discount + loyalty_discount) / 100;
    END;
$$ LANGUAGE plpgsql;


SELECT calculate_dynamic_discount(150000, 500); -- 5% + 0.5% = 5.5%
SELECT calculate_dynamic_discount(600000, 2500); -- 10% + 2.5% = 12.5%
SELECT calculate_dynamic_discount(80000, 1000); -- 0% + 1% = 1%


-- Task 1.2
CREATE OR REPLACE FUNCTION calculate_shipping_cost(order_total NUMERIC, city VARCHAR DEFAULT 'Almaty')
RETURNS NUMERIC
AS $$
    BEGIN
        IF order_total >= 50000 THEN
            RETURN 0;
        end if;

        IF city IN ('Almaty', 'Astana') THEN
            RETURN 2000;
        end if;

        RETURN 3500;
    END;

$$ LANGUAGE plpgsql;

SELECT calculate_shipping_cost(30000, 'Almaty'); -- 2000
SELECT calculate_shipping_cost(60000, 'Shymkent'); -- 0 (free)
SELECT calculate_shipping_cost(25000, 'Karaganda'); -- 3500







-- Task 2.1
CREATE OR REPLACE FUNCTION customer_purchase_stats(p_customer_id INT,
    OUT total_orders INT,
    OUT total_spent NUMERIC,
    OUT avg_order_value NUMERIC,
    OUT loyalty_tier VARCHAR)
AS $$
BEGIN
    SELECT
        COUNT(*),
        SUM(total_amount - discount_amount),
        AVG(total_amount - discount_amount)
    INTO total_orders, total_spent, avg_order_value
    FROM orders
    WHERE customer_id = p_customer_id;

    IF total_spent < 500000 THEN loyalty_tier := 'Bronze';
    ELSIF total_spent < 1000000 THEN loyalty_tier := 'Silver';
    ELSIF total_spent < 2000000 THEN loyalty_tier := 'Gold';
    ELSE loyalty_tier := 'Platinum';
    END IF;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM customer_purchase_stats(1);
SELECT * FROM customer_purchase_stats(5);





-- Task 2.2
CREATE OR REPLACE FUNCTION product_performance(p_product_id INT,
    OUT total_sold INT,
    OUT revenue NUMERIC,
    OUT avg_rating NUMERIC,
    OUT review_count INT,
    OUT current_stock INT)
AS $$
BEGIN
    SELECT COALESCE(SUM(quantity),0),
           COALESCE(SUM(quantity * price_at_purchase),0)
    INTO total_sold, revenue
    FROM order_items
    WHERE product_id = p_product_id;

    SELECT AVG(rating), COUNT(*)
    INTO avg_rating, review_count
    FROM reviews
    WHERE product_id = p_product_id;

    SELECT stock_quantity INTO current_stock
    FROM products
    WHERE product_id = p_product_id;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM product_performance(1);
SELECT * FROM product_performance(7);





-- Task 3.1
CREATE OR REPLACE FUNCTION apply_loyalty_discount(
    INOUT order_amount NUMERIC,
    loyalty_points INT,
    points_to_use INT)
AS $$
DECLARE
    discount_kzt NUMERIC;
BEGIN
    discount_kzt := (points_to_use / 100.0) * 1000;

    order_amount := GREATEST(order_amount - discount_kzt, 0);
END;
$$ LANGUAGE plpgsql;



-- Task 3.2
CREATE OR REPLACE FUNCTION apply_category_multiplier(
    INOUT base_discount NUMERIC,
    p_category_id INT)
AS $$
BEGIN
    CASE p_category_id
        WHEN 1 THEN base_discount := base_discount * 1.2;
        WHEN 2 THEN base_discount := base_discount * 1.5;
        WHEN 3 THEN base_discount := base_discount * 1.1;
        WHEN 4 THEN base_discount := base_discount * 1.3;
        WHEN 5 THEN base_discount := base_discount * 1.4;
    END CASE;
END;
$$ LANGUAGE plpgsql;




-- Task 4.1
CREATE OR REPLACE FUNCTION get_customer_orders(
    p_customer_id INT,
    p_status VARCHAR DEFAULT NULL)
RETURNS TABLE(
    order_id INT,
    order_date TIMESTAMP,
    total_amount NUMERIC,
    discount_amount NUMERIC,
    status VARCHAR,
    payment_method VARCHAR)
AS $$
BEGIN
    IF p_status IS NULL THEN
        RETURN QUERY
        SELECT order_id, order_date, total_amount, discount_amount, status, payment_method
        FROM orders
        WHERE customer_id = p_customer_id;
    ELSE
        RETURN QUERY
        SELECT order_id, order_date, total_amount, discount_amount, status, payment_method
        FROM orders
        WHERE customer_id = p_customer_id AND status = p_status;
    END IF;
END;
$$ LANGUAGE plpgsql;
