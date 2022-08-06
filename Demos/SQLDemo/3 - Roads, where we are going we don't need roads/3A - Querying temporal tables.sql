-- Querying temporal tables (setup)

-- First, let's create an inventory table that we can use for demo purposes

CREATE TABLE Inventory
(
	ProductId        NVARCHAR(20)                                   NOT NULL,
	QuantityInStock  INT                                            NOT NULL,
	QuantityReserved INT                                            NOT NULL,
	ValidFrom        DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
	ValidTo          DATETIME2 GENERATED ALWAYS AS ROW END   HIDDEN NOT NULL,
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
	CONSTRAINT pkcInventory PRIMARY KEY CLUSTERED (ProductId)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Inventory_History))
GO


-- Now we will add some data to our inventory table
INSERT INTO Inventory (ProductId, QuantityInStock, QuantityReserved)
VALUES ('OilFilter1',   59,  5),
       ('OilFilter2',   23,  2),
	   ('FuelFilter1', 120,  0),
	   ('FuelFilter2',  35,  5),
	   ('FuelFilter3',  10, 10);

WAITFOR DELAY '00:00:02';

UPDATE Inventory
   SET QuantityInStock = 54,
	     QuantityReserved = 0
 WHERE ProductId = 'OilFilter1';

UPDATE Inventory
   SET QuantityInStock = 21,
	     QuantityReserved = 0
 WHERE ProductId = 'OilFilter2';

WAITFOR DELAY '00:00:02';

DELETE FROM Inventory WHERE ProductId LIKE 'FuelFilter%';


-- Finally, let's check the contents of the Inventory and Inventory_History tables
--SELECT * FROM Inventory
SELECT *, ValidFrom, ValidTo FROM Inventory;
SELECT * FROM Inventory_History;