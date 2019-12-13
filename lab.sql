-- Setup the database
--DROP DATABASE lab1;
CREATE database lab1;
USE lab1;
--USE master;


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


-- Lab 3

-- Add column
CREATE OR ALTER PROCEDURE V1
AS
BEGIN
	ALTER TABLE dbo.dog
	ADD birthday DATE
END

EXEC V1;

CREATE OR ALTER PROCEDURE RV1
AS
BEGIN
	ALTER TABLE dbo.dog
	DROP COLUMN birthday
END

EXEC RV1;


-- Add pk constraint
CREATE OR ALTER PROCEDURE V2
AS
BEGIN
	ALTER TABLE dbo.street
	ADD CONSTRAINT name_pk PRIMARY KEY(name)
END

EXEC V2;

CREATE OR ALTER PROCEDURE RV2
AS
BEGIN
	ALTER TABLE dbo.street
	DROP CONSTRAINT name_pk
END

EXEC RV2;

-- -- WTF???
-- Add fk constraint

-- WTF:
--CREATE OR ALTER PROCEDURE V3
--AS
--BEGIN
--	ALTER TABLE dbo.house
--	ADD fk_house_id VARCHAR(100)
--	ALTER TABLE dbo.house
--	ADD CONSTRAINT house_id FOREIGN KEY(fk_house_id) REFERENCES house(pk_house_id)	
--END

CREATE OR ALTER PROCEDURE V3
AS
BEGIN
	ALTER TABLE dbo.street
	ADD fk_house_id VARCHAR(100)
	ALTER TABLE dbo.street
	ADD CONSTRAINT house_id FOREIGN KEY(fk_house_id) REFERENCES house(pk_house_id)	
END

ALTER TABLE dbo.street DROP house_id;
ALTER TABLE dbo.street DROP COLUMN fk_house_id;
EXEC V3;

CREATE OR ALTER PROCEDURE RV3
AS
BEGIN
	ALTER TABLE dbo.street
	DROP CONSTRAINT house_id
	ALTER TABLE dbo.street
	DROP COLUMN fk_house_id
END

EXEC RV3;


-- Add table
CREATE OR ALTER PROCEDURE V4
AS
BEGIN
	CREATE TABLE dbo.stray_cat (
		pk_stray_cat_id INT PRIMARY KEY,
	)
END

EXEC V4;


CREATE OR ALTER PROCEDURE RV4
AS
BEGIN
	DROP TABLE dbo.stray_cat
END

EXEC RV4;


CREATE TABLE dbo.versions(
	version_id INT PRIMARY KEY,
	version_number INT NOT NULL
)

INSERT INTO dbo.versions VALUES (0, 0)


CREATE OR ALTER PROCEDURE main
	@version INT 
AS 
BEGIN
	DECLARE @version_from INT = (SELECT V.version_number FROM dbo.versions V)
	DECLARE @executable_procedure VARCHAR(50)

	IF @version <= 4 AND @version >= 0
	BEGIN
		IF @version > @version_from -- move backwards in versions
		BEGIN
			WHILE @version > @version_from
			BEGIN
				SET @version_from = @version_from + 1
				SET @executable_procedure = 'V' + CAST(@version_from AS VARCHAR(2))
				EXEC @executable_procedure
			END
		END

		ELSE -- move forward in versions
			WHILE @version < @version_from
			BEGIN
				IF @version_from != 0
				BEGIN
					SET @executable_procedure = 'RV' + CAST(@version_from AS VARCHAR(2))
					EXEC @executable_procedure
				END
				SET @version_from = @version_from - 1
			END

		UPDATE versions
		SET version_number = @version
	END	
END;


EXEC main 0;

EXEC main 1; -- to check dog table should have birthday
SELECT column_name, data_type, character_maximum_length, is_nullable 
FROM information_schema.columns WHERE table_name = 'dog';

EXEC main 2; -- to check street name should be a primary key
SELECT column_name, data_type, character_maximum_length, is_nullable 
FROM information_schema.columns WHERE table_name = 'street';

EXEC main 3; -- to check street table should have a foreign key to house
SELECT column_name, data_type, character_maximum_length, is_nullable 
FROM information_schema.columns WHERE table_name = 'street';

EXEC main 4; -- to check there should be a stray_cat table
SELECT column_name, data_type, character_maximum_length, is_nullable 
FROM information_schema.columns WHERE table_name = 'stray_cat';

SELECT * FROM dbo.versions;


-- Lab 4
-- Procedures & functions

CREATE OR ALTER FUNCTION checkInt(@n INT)
RETURNS INT AS
BEGIN
	DECLARE @no INT
		IF @n>0 AND @n<=100
			SET @no=1
		ELSE
			SET @no=0
		RETURN @no
	END


CREATE OR ALTER FUNCTION checkVarchar(@v VARCHAR(255))
RETURNS bit AS
	BEGIN
		DECLARE @b bit
		IF LEN(@v) > 5
			SET @b=1
		ELSE
			SET @b=0
		RETURN @b
	END


CREATE OR ALTER PROCEDURE addPerson @hi VARCHAR(100), @n VARCHAR(255), @e VARCHAR(255)
AS
BEGIN
	-- validate the parameters @hi, @n, @e - at least 2 parameters
	IF dbo.checkVarchar(@hi)=1 AND dbo.checkVarchar(@n)=1
	BEGIN
		INSERT INTO person(name, email, fk_house) VALUES (@n, @e, @hi)
		PRINT 'Just added a new person!'
		SELECT * FROM person
	END
	ELSE
		BEGIN
		PRINT 'the parameters are not correct'
		SELECT * FROM person
	END
END
	
SELECT * FROM house

SELECT * FROM person

INSERT INTO house VALUES ('house 9');

EXEC addPerson 'house 9', 'Matei Stefan', 'person@email.com'

EXEC addPerson 'house 8', 'Mihai Viteazul', 'peepeerson@email.com'

print 'hello'

CREATE OR ALTER PROCEDURE addCat @hi VARCHAR(100), @n VARCHAR(255)
AS
BEGIN
	-- validate the parameters @hi, @n
	IF dbo.checkVarchar(@hi)=1 AND dbo.checkVarchar(@n)=1
		BEGIN
			INSERT INTO dbo.cat(name, fk_house) VALUES (@n, @hi)
			PRINT 'Just added a new cat!'
			SELECT * FROM cat
		END
	ELSE
		BEGIN
			PRINT 'the parameters are not correct'
			SELECT * FROM cat
		END
END

EXEC addCat 'house 6', 'Matei Stefan'

EXEC addCat 'house 6', 'Mihai Viteazul'

CREATE OR ALTER VIEW viewAllNames
AS
BEGIN
	SELECT p.name, d.name, c.name, s.name
	FROM person p FULL JOIN dog d ON p.name = d.name
			      FULL JOIN cat c ON p.name = c.name
			      FULL JOIN street s ON p.name = s.name
END

-- INSERT
-- create a copy for the table
CREATE TABLE dbo.cat_copy (
	pk_cat_id INT IDENTITY(1,1) PRIMARY KEY,
	name NVARCHAR(100),
	-- Many cats can stay in one house
	fk_house VARCHAR(100) FOREIGN KEY REFERENCES house(pk_house_id),
)

CREATE TABLE dbo.logs(
	TriggerDate DATE,
	TriggerType VARCHAR(20),
	NameAffectedTable VARCHAR(20),
	NoAMDRows INT
)



CREATE OR ALTER TRIGGER log_cat_insert ON cat FOR INSERT AS
BEGIN
	INSERT INTO cat_copy(name, fk_house) SELECT name, fk_house FROM inserted
    INSERT INTO logs(TriggerDate, TriggerType, NameAffectedTable, NoAMDRows) values (GETDATE(), 'INSERT', 'cat', @@ROWCOUNT)
END

CREATE OR ALTER TRIGGER log_cat_update ON cat FOR INSERT AS
BEGIN
	INSERT INTO cat_copy(name, fk_house) SELECT name, fk_house FROM inserted
    INSERT INTO logs(TriggerDate, TriggerType, NameAffectedTable, NoAMDRows) values (GETDATE(), 'UPDATE', 'cat', @@ROWCOUNT)
END

CREATE OR ALTER TRIGGER log_cat_update ON dog FOR INSERT AS
BEGIN
	INSERT INTO dog_copy(name, fk_house) SELECT name, fk_house FROM inserted
    INSERT INTO logs(TriggerDate, TriggerType, NameAffectedTable, NoAMDRows) values (GETDATE(), 'UPDATE', 'dog', @@ROWCOUNT)
END

CREATE OR ALTER TRIGGER log_delete ON dog FOR INSERT AS
BEGIN
	INSERT INTO dog_copy(name, fk_house) SELECT name, fk_house FROM inserted
    INSERT INTO logs(TriggerDate, TriggerType, NameAffectedTable, NoAMDRows) values (GETDATE(), 'delete', 'dog', @@ROWCOUNT)
END



SELECT * FROM dbo.cat

SELECT * FROM dbo.cat_copy

INSERT INTO cat (name, fk_house) VALUES ('procedure triggering cat', 'house 6')

SELECT * FROM dbo.cat

SELECT * FROM dbo.cat_copy

SELECT * FROM dbo.logs

DROP TRIGGER log_cat



---- To see what I just created
--SELECT column_name, data_type, character_maximum_length, is_nullable 
--FROM information_schema.columns WHERE table_name = 'movies';
