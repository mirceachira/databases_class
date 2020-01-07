-- Setup the database
CREATE DATABASE exam;
USE exam;

CREATE TABLE dbo.chef (
	pk_chef_id INT PRIMARY KEY,
	name NVARCHAR(255),
	gender VARCHAR(1),
	birthday DATE,	
);


CREATE TABLE dbo.cakeType (
	pk_type_id INT PRIMARY KEY,
	name NVARCHAR(255) UNIQUE,
	description NVARCHAR(255),
)

CREATE TABLE dbo.cake (
	pk_cake_id INT PRIMARY KEY,
	name NVARCHAR(255),
	shape NVARCHAR(255),
	weight INT,	
	price INT,
	
	-- Many cakes can belong to one cake type so one to many 
	fk_type INT FOREIGN KEY REFERENCES cakeType(pk_type_id),
);


-- many chefs can specialise in multiple cakes so many to many
CREATE TABLE dbo.specialisations (
	chef_id INT FOREIGN KEY REFERENCES chef(pk_chef_id),
	cake_id INT FOREIGN KEY REFERENCES cake(pk_cake_id),
	CONSTRAINT specialisation_relation PRIMARY KEY (chef_id, cake_id),
);


CREATE TABLE dbo.cakeOrder (
	pk_order_id INT PRIMARY KEY,
	orderDate date,
)


-- many chefs can specialise in multiple cakes so many to many
CREATE TABLE dbo.cakeOrders (
	order_id INT FOREIGN KEY REFERENCES cakeOrder(pk_order_id),
	cake_id INT FOREIGN KEY REFERENCES cake(pk_cake_id),
	numberOfCakes INT,
	CONSTRAINT cakeOrder_relation PRIMARY KEY (order_id, cake_id),
);


CREATE OR ALTER PROCEDURE addCakeToOrder
	@orderId INT , @cakeName VARCHAR (255), @p INT
AS 
BEGIN
	DECLARE @cakeId INT = (SELECT pk_cake_id FROM cake WHERE name=@cakeName)	

	IF EXISTS (SELECT * FROM cakeOrders WHERE order_id=@orderId AND cake_id=@cakeId)
	BEGIN
		UPDATE cakeOrders SET numberOfCakes = @p WHERE order_id=@orderId AND cake_id=@cakeId;
	END
	ELSE
	BEGIN
		INSERT INTO cakeOrders VALUES (@orderId, @cakeId, @p)
	END
END



CREATE OR ALTER FUNCTION dbo.getGordonRamsays() RETURNS TABLE AS RETURN (
	SELECT c.name FROM chef c WHERE 
		(SELECT COUNT(pk_cake_id) FROM cake) = 
		(SELECT COUNT(cake_id) FROM specialisations s WHERE s.chef_id=c.pk_chef_id)
	)


-- Testing stuff

-- reset 
DROP TABLE chef;
DROP TABLE cakeType;
DROP TABLE cake;
DROP TABLE specialisations;
DROP TABLE cakeOrder;
DROP TABLE cakeOrders;
	
-- 1
INSERT INTO chef VALUES (1, 'Chef 1', 'm', '1991-01-01')
INSERT INTO chef VALUES (2, 'Chef 2', 'm', '1992-02-02')
INSERT INTO chef VALUES (3, 'Chef 3', 'f', '1993-03-03')
SELECT * FROM chef


INSERT INTO cakeType VALUES (1, 'Cake type 1', 'cu mere')
INSERT INTO cakeType VALUES (2, 'Cake type 2', 'cu pere')
INSERT INTO cakeType VALUES (3, 'Cake type 3', 'fara restante')
SELECT * FROM cakeType


INSERT INTO cake VALUES (1, 'Cake 1', 'square', 10, 100, 1)
INSERT INTO cake VALUES (2, 'Cake 2', 'square', 20, 200, 1)
INSERT INTO cake VALUES (3, 'Cake 3', 'square', 30, 300, 2)
INSERT INTO cake VALUES (4, 'Cake 4', 'square', 40, 400, 3)
SELECT * FROM cake

INSERT INTO specialisations VALUES (1, 1)
INSERT INTO specialisations VALUES (2, 1)
INSERT INTO specialisations VALUES (2, 2)
INSERT INTO specialisations VALUES (3, 1)
INSERT INTO specialisations VALUES (3, 2)
INSERT INTO specialisations VALUES (3, 3)
INSERT INTO specialisations VALUES (3, 4)-- Only chef 3 is a Ramsay
SELECT * FROM specialisations

INSERT INTO cakeOrder VALUES (1, '2020-01-01')
INSERT INTO cakeOrder VALUES (2, '2020-02-01')
INSERT INTO cakeOrder VALUES (3, '2020-03-01')
INSERT INTO cakeOrder VALUES (4, '2020-04-01')
SELECT * FROM cakeOrder


INSERT INTO cakeOrders VALUES (1, 1, 10)
INSERT INTO cakeOrders VALUES (2, 2, 20)
INSERT INTO cakeOrders VALUES (3, 3, 30)
INSERT INTO cakeOrders VALUES (4, 1, 30)
INSERT INTO cakeOrders VALUES (4, 2, 20)
INSERT INTO cakeOrders VALUES (4, 3, 10)
SELECT * FROM cakeOrders

-- 2
SELECT * FROM cakeOrders

EXEC addCakeToOrder 1, 'Cake 2', 66;

-- 3
SELECT * FROM dbo.getGordonRamsays();


	
	
