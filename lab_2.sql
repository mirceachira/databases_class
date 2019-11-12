-- Setup the database
CREATE database lab1;
USE lab1;


---- Create the tables
CREATE TABLE dbo.house (
	pk_house_id VARCHAR(100) PRIMARY KEY
);


CREATE TABLE dbo.dog_house (
	pk_house_id INT PRIMARY KEY,
	material NVARCHAR(30) -- make this a choice? wood / metal / concrete / etc
);


CREATE TABLE dbo.person (
	pk_person_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	name NVARCHAR(255) NOT NULL,
	email NVARCHAR(255),
	-- Many persons can stay in one house
	fk_house VARCHAR(100) FOREIGN KEY REFERENCES house(pk_house_id)
);


CREATE TABLE dbo.dog (
	pk_dog_id INT PRIMARY KEY,
	name NVARCHAR(255) NOT NULL,
	birthday DATE,
	-- One dog has one house so we have a one to one relation!
	fk_dog_house INT UNIQUE FOREIGN KEY REFERENCES dog_house(pk_house_id),
	-- Many dogs can belong to one owner so one to many 
	fk_owner INT FOREIGN KEY REFERENCES person(pk_person_id),
	-- Many dogs can stay in one house
	fk_house VARCHAR(100) FOREIGN KEY REFERENCES house(pk_house_id)
);


CREATE TABLE dbo.cat (
	pk_cat_id INT IDENTITY(1,1) PRIMARY KEY,
	name NVARCHAR(100),
	-- Many cats can stay in one house
	fk_house VARCHAR(100) FOREIGN KEY REFERENCES house(pk_house_id),
);


CREATE TABLE dbo.dog_vs_cat (
	dog_id INT FOREIGN KEY REFERENCES dog(pk_dog_id),
	cat_id INT FOREIGN KEY REFERENCES cat(pk_cat_id),
	CONSTRAINT hate_relation PRIMARY KEY (dog_id,cat_id),
);


-- simple table, no relations, no pk
CREATE TABLE dbo.street (
	name VARCHAR(123) NOT NULL,
	len INT
);


-- Insert some data!
INSERT INTO dog_house VALUES (1, 'wood');
INSERT INTO dog_house VALUES (2, 'wood');
INSERT INTO dog_house VALUES (3, 'metal');
INSERT INTO dog_house VALUES (4, 'metal');
INSERT INTO dog_house VALUES (5, 'metal');
INSERT INTO dog_house VALUES (6, 'diamonds');
INSERT INTO dog_house VALUES (7, 'platinum');
INSERT INTO dog_house VALUES (8, 'red diamonds');
INSERT INTO dog_house VALUES (9, 'blue diamonds');

INSERT INTO house VALUES ('house 1');
INSERT INTO house VALUES ('house 2');
INSERT INTO house VALUES ('house 3');
INSERT INTO house VALUES ('house 4');
INSERT INTO house VALUES ('house 5');
INSERT INTO house VALUES ('house 6');

INSERT INTO person VALUES ('person 1', 'email_1@gmail.com', 'house 6');
INSERT INTO person VALUES ('person 2', 'email_2@gmail.com', 'house 5');
INSERT INTO person VALUES ('person 3', 'email_3@gmail.com', 'house 4');
INSERT INTO person VALUES ('person 4', 'email_4@gmail.com', 'house 3');
INSERT INTO person VALUES ('person 5', 'email_5@gmail.com', 'house 2');
INSERT INTO person VALUES ('person 6', 'email_6@gmail.com', 'house 1');

INSERT INTO dog VALUES (1, 'dog 1', '2001-01-01', 1, 3, 'house 1');
INSERT INTO dog VALUES (2, 'dog 2', '2001-01-01', 4, 3, 'house 1');
INSERT INTO dog VALUES (3, 'dog 3', '2001-01-01', 5, 3, 'house 3');
INSERT INTO dog VALUES (4, 'dog 4', '2001-01-01', 6, 4, NULL);
INSERT INTO dog VALUES (5, 'dog 5', '2001-01-01', 3, 5, NULL);
INSERT INTO dog VALUES (6, 'dog 6', '2001-01-01', 2, 6, NULL);

INSERT INTO cat VALUES ('black cat', 'house 1');
INSERT INTO cat VALUES ('white cat', 'house 4');
INSERT INTO cat VALUES ('red cat', 'house 4');
INSERT INTO cat (name) VALUES ('blue cat');

INSERT INTO dog_vs_cat VALUES (1,1);
INSERT INTO dog_vs_cat VALUES (2,3);
INSERT INTO dog_vs_cat VALUES (3,3);

INSERT INTO street VALUES ('happy street', 100);
INSERT INTO street VALUES ('error street', -100);
INSERT INTO street VALUES ('null street', NULL);
INSERT INTO street (name) VALUES ('clean code street');
INSERT INTO street (name, len) VALUES ('cool street', 10);

-- Updates
UPDATE dog_house SET material = 'precious metal' WHERE pk_house_id IN (6, 7);
UPDATE dog_house SET material = 'very precious metal' WHERE pk_house_id IS NULL;
UPDATE dog_house SET material = 'diamonds' WHERE material LIKE '%diamonds';

UPDATE dog SET birthday='2010-09-09' WHERE fk_dog_house BETWEEN 4 AND 7;

UPDATE cat SET name = 'Horatiu' WHERE pk_cat_id = 'house 10'; -- this query does not match any cat! 

-- Deletes
DELETE FROM dog WHERE fk_house IS NULL;

-- Selecting stuff
SELECT name FROM cat 
UNION
SELECT name FROM dog; -- all pet names ids 

SELECT dog_id FROM dog_vs_cat 
UNION
SELECT pk_dog_id FROM dog; -- all dog ids 

SELECT dog_id FROM dog_vs_cat 
INTERSECT
SELECT pk_dog_id FROM dog; -- dogs that have a relation to cats

SELECT dog_id FROM dog_vs_cat 
EXCEPT
SELECT pk_dog_id FROM dog; -- dogs that do NOT have a relation to cats

-- Joined stuff

SELECT d.name, c.name
FROM
	dog d
	INNER JOIN dog_vs_cat dc ON d.pk_dog_id = dc.dog_id
	INNER JOIN cat c ON c.pk_cat_id = dc.cat_id;
	

SELECT dog.name, dog_vs_cat.cat_id
FROM (dog
LEFT JOIN dog_vs_cat ON dog.pk_dog_id = dog_vs_cat.dog_id)
ORDER BY dog.name;

SELECT cat.name, dog_vs_cat.cat_id
FROM (dog_vs_cat
RIGHT JOIN cat ON cat.pk_cat_id = dog_vs_cat.cat_id)
ORDER BY cat.name;

SELECT TOP 10 d.name, c.name
FROM dog d
	FULL JOIN dog_vs_cat dc ON d.pk_dog_id = dc.dog_id
	FULL JOIN cat c ON c.pk_cat_id = dc.cat_id;
ORDER BY d.name;


-- Subqueries
SELECT name
FROM dog
WHERE pk_dog_id IN (SELECT dog_id FROM dog_vs_cat);

SELECT name
FROM dog
WHERE pk_dog_id NOT IN (SELECT dog_id FROM dog_vs_cat);

SELECT DISTINCT name
FROM cat
WHERE EXISTS (SELECT cat_id FROM dog_vs_cat WHERE cat.pk_cat_id = dog_vs_cat.cat_id);

SELECT DISTINCT name
FROM cat
WHERE NOT EXISTS (SELECT cat_id FROM dog_vs_cat WHERE cat.pk_cat_id = dog_vs_cat.cat_id);

-- Subquery in FROM clause

SELECT custom_table_name.name
FROM (
	SELECT * FROM dog WHERE pk_dog_id IN (
		SELECT dog_id FROM dog_vs_cat
	)
) AS custom_table_name;


-- Group by stuff

SELECT 
    d.name
FROM 
    dog d
	FULL OUTER JOIN dog_vs_cat dc ON d.pk_dog_id = dc.dog_id 
	FULL OUTER JOIN cat c ON c.pk_cat_id = dc.cat_id
GROUP BY d.name;

SELECT c.name, c.pk_cat_id, COUNT(c.name)
FROM 
	cat c
	FULL JOIN dog_vs_cat dc ON c.pk_cat_id = dc.cat_id  
GROUP BY c.name, c.pk_cat_id
HAVING c.pk_cat_id > (SELECT MIN(pk_cat_id) FROM cat);

SELECT d.name, d.pk_dog_id, c.name, c.pk_cat_id
FROM 
	dog d
	FULL JOIN dog_vs_cat dc ON d.pk_dog_id = dc.dog_id
	FULL JOIN cat c ON c.pk_cat_id = dc.cat_id
GROUP BY d.pk_dog_id, c.name, d.name, c.pk_cat_id
HAVING d.pk_dog_id < (SELECT AVG(pk_dog_id) FROM dog)
--GROUP BY d.name
ORDER BY d.name ASC;


---- To see what I just created
SELECT column_name, data_type, character_maximum_length, is_nullable 
FROM information_schema.columns;-- WHERE table_name = 'movies';



SELECT dog.name, cat.name
FROM (dog
FULL JOIN dog_vs_cat
FULL JOIN cat ON dog.pk_dog_id = dog_vs_cat.dog_id AND cat.pk_cat_id = dog_vs_cat.cat_id)
GROUP BY cat.name;

GROUP BY COUNT (cat.name) DESC
HAVING dog.pk_dog_id > (SELECT MIN(pk_cat_id) FROM cat);

SELECT dog.name, cat.name
FROM (dog
FULL JOIN dog_vs_cat
FULL JOIN cat ON dog.pk_dog_id = dog_vs_cat.dog_id AND cat.pk_cat_id = dog_vs_cat.cat_id)
GROUP BY dog.name

SELECT dog.name, cat.name
FROM (dog
FULL JOIN dog_vs_cat
FULL JOIN cat ON dog.pk_dog_id = dog_vs_cat.dog_id AND cat.pk_cat_id = dog_vs_cat.cat_id)
GROUP BY cat.name
GROUP BY COUNT (dog.name) ASC
HAVING dog.pk_dog_id < (SELECT AVG(pk_dog_id) FROM dog);
