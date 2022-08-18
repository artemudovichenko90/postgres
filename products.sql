DROP TABLE IF EXISTS deliveries_orders;
DROP TABLE IF EXISTS deliveries;
DROP TABLE IF EXISTS orders_products;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS contracts;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
-- товары
CREATE TABLE products(
  id BIGSERIAL PRIMARY KEY,
  code VARCHAR(12) NOT NULL UNIQUE CHECK(length(trim(code)) >= 1),
  name VARCHAR(100) NOT NULL CHECK(length(trim(name)) >= 1),
  price NUMERIC(14, 2) NOT NULL CHECK(price >= 1),--цена, которая может меняться
  gramm NUMERIC(10, 2) NOT NULL CHECK(gramm >= 1),
  UNIQUE(name, gramm),
  amount INT NOT NULL CHECK(amount > 0)--количество на складе
);
--заказчики
CREATE TABLE customers(
  id SERIAL PRIMARY KEY,
  phone VARCHAR(20) NOT NULL UNIQUE CHECK(length(trim(phone)) >= 3),
  name VARCHAR(150) NOT NULL CHECK(length(trim(name)) >= 2),
  city VARCHAR(20) NOT NULL CHECK(length(trim(city)) >= 2),
  street VARCHAR(20) NOT NULL CHECK(length(trim(street)) >= 2),
  house VARCHAR(10) NOT NULL CHECK(length(trim(house)) >= 2),
  room VARCHAR(10) DEFAULT NULL
);
--договоры
CREATE TABLE contracts(
  id BIGSERIAL PRIMARY KEY,
  number VARCHAR(20) NOT NULL UNIQUE CHECK(length(trim(number)) >= 1),
  description TEXT,
  date DATE NOT NULL CHECK(date <= CURRENT_DATE)
);
--заказы
CREATE TABLE orders(
  id BIGSERIAL PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE CHECK(length(trim(code)) >= 1),
  id_customer INT REFERENCES customers(id) NOT NULL,
  id_contract INT REFERENCES contracts(id) NOT NULL,
  date DATE NOT NULL CHECK(date <= CURRENT_DATE)
);
--список заказов
CREATE TABLE orders_products(
  id_order INT REFERENCES orders(id) NOT NULL,
  id_product INT REFERENCES products(id) NOT NULL,
  amount INT NOT NULL CHECK(amount > 0),
  price NUMERIC(14, 2) NOT NULL CHECK(price > 0),--цена, которая не может меняться
  PRIMARY KEY(id_order, id_product)
);
--отгрузки
CREATE TABLE deliveries(
  id BIGSERIAL PRIMARY KEY,
  code VARCHAR(20)  NOT NULL UNIQUE CHECK(length(trim(code)) >= 1),
  date DATE NOT NULL CHECK(date <= CURRENT_DATE)
);
--список отгрузок
CREATE TABLE deliveries_orders(
  id_deliverie INT REFERENCES deliveries(id) NOT NULL,
  id_order INT REFERENCES orders(id) NOT NULL,
  amount INT NOT NULL CHECK(amount > 0)
);
--добавляю 4 разных товара
INSERT INTO products(code, name, price, gramm, amount) VALUES 
('pr01', 'Snickers', 15.00, 50, 100),
('pr02', 'Snickers', 30.00, 12.5, 100),
('pr03', 'Bounty', 20.00, 57, 100),
('pr04', 'Bounty', 25.00, 85, 100);
--доабавляю 2 заказчика
INSERT INTO customers(phone, name, city, street, house, room) VALUES 
('+38-066-666-66-66', 'ПП Бандера', 'Запоріжжя', 'пр.Перемоги', '100', NULL),
('+38-097-777-77-77', 'ТОВ Байрактар', 'Запоріжжя', 'вул.Українська', '500', NULL);
--добавляю 2 договора(по одному на каждого заказчика)
INSERT INTO contracts(number, date) VALUES 
('contr01', '2022-01-01'),
('contr02', '2022-02-02');
--ПП Бандера заказал 5 больших и 5 маленьких сникерсов одним заказом
--ТОВ Байрактар заказал 15 больших и 15 маленьких баунти двумя заказами
INSERT INTO orders(code, id_customer, id_contract, date) VALUES 
('ord01', 1, 1, '2022-08-15'),
('ord02', 2, 2, '2022-08-15'),
('ord03', 2, 2, '2022-08-15');
INSERT INTO orders_products(id_order, id_product, amount, price) VALUES 
(1, 1, 5, 15.00),
(1, 2, 5, 30.00),
(2, 3, 15, 20.00),
(3, 4, 15, 25.00);
--16 числа отправили двумя отгрузками два заказа для ПП Бандера,
--в первой откгузке большие сникерсы 5шт, во второй маленькие 5шт
--17 числа отправили одной отгрузкой 7шт меленьких баунти и 7шт больших для ТОВ Байрактар,
--Должны отправить ещё 8 маленьких и 8 больших баунти для ТОВ Байрактар
INSERT INTO deliveries(code, date) VALUES 
('deliv01', '2022-08-16'),
('deliv02', '2022-08-16'),
('deliv03', '2022-08-17');
INSERT INTO deliveries_orders(id_deliverie, id_order, amount) VALUES
(1, 1, 5),
(2, 1, 5),
(3, 2, 7),
(3, 2, 7);
--Показать кто, какие заказы сделал, когда и номер договора
SELECT products.name, products.name, products.gramm, orders_products.amount, orders.date, contracts.number
FROM orders_products
JOIN orders ON orders.id = orders_products.id_order
JOIN products ON products.id = orders_products.id_product
JOIN customers ON customers.id = orders.id_customer
JOIN contracts ON contracts.id = orders.id_contract;
--Показать кому, какие товары отправлены, сколько, цена за единицу, общая цена позиции и когда
SELECT customers.name, products.name, products.gramm, deliveries_orders.amount, orders_products.price, (orders_products.price * deliveries_orders.amount) AS "total", deliveries.date
FROM orders
JOIN deliveries_orders ON deliveries_orders.id_order = orders.id
JOIN deliveries ON deliveries.id = deliveries_orders.id_deliverie
JOIN customers ON customers.id = orders.id_customer
JOIN products ON products.id = deliveries_orders.id_order
JOIN orders_products ON orders_products.id_product = products.id;