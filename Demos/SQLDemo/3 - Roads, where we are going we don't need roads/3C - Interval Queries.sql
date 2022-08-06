-- 3C: Interval Queries

/*

Interval queries are useful for auditing and tracking changes.  There are three options:

* FROM..TO
* BETWEEN..AND
* CONTAINED IN ()

*/

-- FROM..TO and BETWEEN..AND are very similar.  They include rows that were
-- active during the time interval.  The difference is the border case for 
-- the upper bound.

SELECT *, ValidFrom, ValidTo
  FROM Inventory
   FOR SYSTEM_TIME FROM '2022-08-06 13:53:15.0522458' TO '2022-08-06 13:54:38.3584053';

SELECT *, ValidFrom, ValidTo
  FROM Inventory
   FOR SYSTEM_TIME BETWEEN '2022-08-06 13:53:15.0522458' AND '2022-08-06 13:54:38.3584053';

/*

The CONTAINED IN will look only at historical record and only include those
that completely occurred within the time window.

*/

SELECT *, ValidFrom, ValidTo
  FROM Inventory
   FOR SYSTEM_TIME CONTAINED IN ('2022-08-06 13:53:15.0522458', '2022-08-06 13:54:38.3584053')
















/*

Finally, we have the ALL option - this will give you a union of all current
and historical rows.
*/

SELECT *, ValidFrom, ValidTo
  FROM Inventory
   FOR SYSTEM_TIME ALL;