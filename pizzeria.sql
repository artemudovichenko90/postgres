--Создайте таблицу “pizza” (“id”, “name”, “price”, “diameter”).
drop table "pizza";
CREATE TABLE "pizza"(
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR(30) NOT NULL check(length(trim("name")) BETWEEN 1 AND 15),
  "price" NUMERIC(5, 2) NOT NULL check("price" BETWEEN 20 AND 999.99),
  "diameter" SMALLINT NOT NULL check("diameter" BETWEEN 10 AND 100),
  UNIQUE("name", "diameter")
);

--Добавьте новую пиццу Маргарита, диаметр 18, цена 50,4грн.
INSERT INTO "pizza"("name", "diameter", "price")
VALUES ('Маргарита', 18, 50.4);

--Добавьте новую пиццу Карбонара, диаметр 28, цена 81грн.
INSERT INTO "pizza"("name", "diameter", "price")
VALUES ('Карбонара', 28, 81);

--Добавьте две новые пиццы одним запросом:
--Цезарь , диаметр 38, цена 149грн, Пепперони , диаметр 32, цена 116грн
INSERT INTO "pizza"("name", "diameter", "price") VALUES 
('Цезарь', 38, 149),
('Пепперони', 32, 116);

--Поставьте цену Маргарите 53грн.
UPDATE "pizza"
SET "price" = 53
WHERE "name" = 'Маргарита';

-- Пицце с id=4 поставьте диаметр 30.
UPDATE "pizza"
SET "diameter" = 30
WHERE "id" = 4;

-- Всем, чья цена больше 100грн сделайте ее 130грн, верните результат.
UPDATE "pizza"
SET "price" = 130
WHERE "price" > 100
RETURNING *;

-- Пиццам с id больше 2 и меньше 5 включительно поставьте диаметр 22, верните результат.
UPDATE "pizza"
SET "diameter" = 22
WHERE id > 2 AND id <= 5
RETURNING *;

-- Измените Цезарь на 4 сыра и поставьте цену 180.
UPDATE "pizza"
SET "name" = '4 сыра', "price" = 180
WHERE name = 'Цезарь';

-- Выбрать пиццу с id = 3.
SELECT *
FROM "pizza"
WHERE id = 3;

-- Выбрать пиццу с ценой менее 100грн.
SELECT *
FROM "pizza"
WHERE price < 100;

-- Выбрать пиццу с ценой НЕ равной 130грн.
SELECT *
FROM "pizza"
WHERE "price" != 130;

-- Узнайте цену и диаметр Пепперони.
SELECT "price", "diameter"
FROM "pizza"
WHERE "name" = 'Пепперони';

-- Выбрать пиццу с названием Маргарита.
SELECT *
FROM "pizza"
WHERE "name" = 'Маргарита';

-- Выбрать все пиццы, кроме той, которая называется Карбонара .
SELECT *
FROM "pizza"
WHERE "name" != 'Карбонара';

-- Выбрать все пиццы диаметром 22 и ценой меньше 150грн.
SELECT *
FROM "pizza"
WHERE "diameter" = 22 AND price < 150;

-- Выбрать пиццы с диаметром от 25 до 33 включительно.
SELECT *
FROM "pizza"
WHERE "diameter" BETWEEN 25 AND 33;

-- Выбрать пиццы с диаметром от 25 до 33  или с ценой от 100 до 200 грн..
SELECT *
FROM "pizza"
WHERE "diameter" BETWEEN 25 AND 33
OR "price"  BETWEEN 100 AND 200;

-- Выбрать все пиццы диаметром 22 или ценой 180грн.
SELECT *
FROM "pizza"
WHERE "diameter" = 22
OR "price" = 180;

-- Удалите пиццу с id=3, верните результат.
DELETE FROM "pizza"
WHERE "id" = 3
RETURNING *;

-- Удалите Пепперони.
DELETE FROM "pizza"
WHERE "name" = 'Пепперони';

-- Удалите все пиццы, у которых диаметр 18, верните результат.
DELETE FROM "pizza"
WHERE "diameter" = 18
RETURNING *;
