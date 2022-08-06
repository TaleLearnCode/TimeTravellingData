-- 3B: Point in time queries

-- We can now query the contents of the inventory table at any point in time
SELECT * FROM Inventory

SELECT *, ValidFrom, ValidTo
  FROM Inventory
   FOR SYSTEM_TIME AS OF '2022-08-06 13:53:15.0522458';