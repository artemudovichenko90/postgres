
DROP TABLE IF EXISTS deliveries_orders;
DROP TABLE IF EXISTS deliveries;
DROP TABLE IF EXISTS orders_products;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS contracts;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
-- товары
CREATE TABLE products(
  id BIGINT IDENTITY PRIMARY KEY,
  code VARCHAR(12) NOT NULL UNIQUE CHECK(len(trim(code)) >= 1),
  name VARCHAR(100) NOT NULL CHECK(len(trim(name)) >= 1),
  price NUMERIC(14, 2) NOT NULL CHECK(price >= 1),
  gramm NUMERIC(10, 2) NOT NULL CHECK(gramm >= 1),
  UNIQUE(name, gramm),
  amount INT NOT NULL CHECK(amount > 0)--количество на складе
);
--заказчики
CREATE TABLE customers(
  id INT IDENTITY PRIMARY KEY,
  phone VARCHAR(20) NOT NULL UNIQUE CHECK(len(trim(phone)) >= 3),
  name NVARCHAR(150) NOT NULL CHECK(len(trim(name)) >= 2),
  city NVARCHAR(20) NOT NULL CHECK(len(trim(city)) >= 2),
  street NVARCHAR(20) NOT NULL CHECK(len(trim(street)) >= 2),
  house NVARCHAR(10) NOT NULL CHECK(len(trim(house)) >= 2),
  room NVARCHAR(10) DEFAULT NULL
);
--договоры
CREATE TABLE contracts(
  id INT IDENTITY PRIMARY KEY,
  number VARCHAR(20) NOT NULL UNIQUE CHECK(len(trim(number)) >= 1),
  description TEXT,
  date DATE NOT NULL CHECK(date <= getdate())
);
--заказы
CREATE TABLE orders(
  id BIGINT IDENTITY PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE CHECK(len(trim(code)) >= 1),
  id_customer INT REFERENCES customers(id) NOT NULL,
  id_contract INT REFERENCES contracts(id) NOT NULL,
  date DATE NOT NULL CHECK(date <= getdate())
);
--список заказов
CREATE TABLE orders_products(
  id_order BIGINT REFERENCES orders(id) NOT NULL,
  id_product BIGINT REFERENCES products(id) NOT NULL,
  amount INT NOT NULL CHECK(amount > 0),
  PRIMARY KEY(id_order, id_product)
);
--отгрузки
CREATE TABLE deliveries(
  id BIGINT IDENTITY PRIMARY KEY,
  code VARCHAR(20)  NOT NULL UNIQUE CHECK(len(trim(code)) >= 1),
  date DATE NOT NULL CHECK(date <= getdate())
);
--список отгрузок
CREATE TABLE deliveries_orders(
  id_deliverie BIGINT REFERENCES deliveries(id) NOT NULL,
  id_order BIGINT REFERENCES orders(id) NOT NULL,
  id_product BIGINT REFERENCES products(id) NOT NULL,
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
('+38-066-666-66-66', N'ПП Бандера', N'Запоріжжя', N'пр.Перемоги', N'100', NULL),
('+38-097-777-77-77', N'ТОВ Байрактар', N'Запоріжжя', N'вул.Українська', N'500', NULL);
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
INSERT INTO orders_products(id_order, id_product, amount) VALUES 
(1, 1, 5),
(1, 2, 5),
(2, 3, 15),
(3, 4, 15);
--16 числа отправили двумя отгрузками два заказа для ПП Бандера,
--в первой откгузке большие сникерсы 5шт, во второй маленькие 5шт
--17 числа отправили одной отгрузкой 7шт меленьких баунти и 7шт больших для ТОВ Байрактар,
--Должны отправить ещё 8 маленьких и 8 больших баунти для ТОВ Байрактар
INSERT INTO deliveries(code, date) VALUES 
('deliv01', '2022-08-16'),
('deliv02', '2022-08-16'),
('deliv03', '2022-08-17');
INSERT INTO deliveries_orders(id_deliverie, id_order, id_product, amount) VALUES
(1, 1, 1, 5),
(2, 1, 2, 5),
(3, 2, 3, 7),
(3, 3, 4, 7);
--Показать кто, какие заказы сделал, когда и номер договора и номер заказа
SELECT customers.name, products.name, products.gramm, orders_products.amount, orders.date, contracts.number, orders.code
FROM orders_products
JOIN orders ON orders.id = orders_products.id_order
JOIN products ON products.id = orders_products.id_product
JOIN customers ON customers.id = orders.id_customer
JOIN contracts ON contracts.id = orders.id_contract;
--Показать кому, какие товары отправлены, сколько, цена за единицу, общая цена позиции, когда, контракт, номер заказа, номер отгрузки
SELECT customers.name, products.name, products.gramm, deliveries_orders.amount, products.price, deliveries_orders.amount * products.price as 'total', deliveries.date, contracts.number, orders.code, deliveries.code
FROM orders
JOIN deliveries_orders ON deliveries_orders.id_order = orders.id
JOIN deliveries ON deliveries.id = deliveries_orders.id_deliverie
JOIN customers ON customers.id = orders.id_customer
JOIN products ON products.id =	deliveries_orders.id_product
JOIN contracts ON contracts.id = orders.id_contract

--показать сколько кому ещё должны
SELECT customers.name, products.name, products.gramm, orders_products.amount - deliveries_orders.amount as 'amount', orders.code
FROM orders
JOIN deliveries_orders ON deliveries_orders.id_order = orders.id
JOIN deliveries ON deliveries.id = deliveries_orders.id_deliverie
JOIN customers ON customers.id = orders.id_customer
JOIN products ON products.id =	deliveries_orders.id_product
JOIN orders_products ON products.id = orders_products.id_product
