-- Add new parking permit
-- last_insert_rowid() function gives back the last inserted id value
BEGIN TRANSACTION;
INSERT INTO "owners" 
("first_name", "last_name", "company_name", "street", "apartment_number", "floor", "door", "phone", "email") 
VALUES ('Adam', 'Tornyai', NULL, 'Tulipán utca', 4, NULL, NULL, '06701234567', 'adam.tornyai@testmail.com');


INSERT INTO "car_data" ("plate_number", "owner_id", "manufacturer", "weight") 
VALUES ('ADA-111', (SELECT last_insert_rowid()), 'Peugeot', 1150);

INSERT INTO "parking_permits" ("plate_number", "permit_type", "zone_id", "start_date", "end_date") 
VALUES ('ADA-111', 'residental', 2, DATE('now'), DATE('now', '+1 year', 'start of year', '+1 month')); 
COMMIT;
---- You can vary the end dates for example if you would like to add a parking permit for the whole year of 2025 but the current date is 2024 december you can change the end_date to "DATETIME('now', '+2 year'))


-- Add new parking permit to an existing user
-- You can refine your SELECT user method with street datas, email and with phone number
BEGIN TRANSACTION;
INSERT INTO "car_data" ("plate_number", "owner_id", "manufacturer", "weight") 
VALUES ('ANN-002', (SELECT "id" FROM "owners" 
                    WHERE "first_name" = 'Anna' AND "last_name" = 'Nagy'
                    ), 'Peugeot', 1150);

INSERT INTO "parking_permits" ("plate_number", "permit_type", "zone_id", "start_date", "end_date") 
VALUES ('ANN-002', 'residental', 2, DATE('now'), DATE('now', '+1 year', 'start of year', '+1 month')); 
COMMIT;


--  You can delete owner based on plate number
-- ❗PRAGMA foreign_keys = 1;❗ needed at every sqlite3 database start to enable foreign keys constraints to maintain data integrity
-- ❗When you want full delete first you have to run this
DELETE FROM "owners"
WHERE "id" = (
SELECT "owner_id" FROM "car_data"
WHERE "plate_number" = 'ADA-111');
--OR
-- You can delete user based on personal data
DELETE FROM "owners" 
WHERE "first_name" = 'Adam' AND "last_name" = 'Tornyai' AND "street" = 'Tulipán utca';


--  You can delete parking permit based on their plate number in "parking_permits" 
-- ❗It deletes only the permit & car data. The owner still remain❗
-- ❗PRAGMA foreign_keys = 1;❗ needed at every sqlite3 database start to enable foreign keys constraints to maintain data integrity
DELETE FROM "car_data"
WHERE "plate_number" = 'ADA-111';


-- Queries all permit data for a specific plate number. .mode box
SELECT * FROM "owners"
JOIN "car_data" ON "owners"."id" = "car_data"."owner_id"
JOIN "parking_permits" ON "car_data"."plate_number" = "parking_permits"."plate_number"
WHERE "car_data"."plate_number" = 'ADA-111';


-- When the parking officer checks the car's plate, it queries if there is a parking permit or ticket to a specified zone
SELECT "plate_number", "permit_type" AS "status", "zone_id", "start_date", "end_date"
FROM "parking_permits"
WHERE "plate_number" = 'LOL-101' AND zone_id = (
    SELECT "zone_id" FROM street_names
    WHERE street = 'Kossuth tér')

UNION

SELECT "plate_number", "permit_type", "zone_id", "start_date", "end_date"
FROM "ongoing_mobile_parking"
WHERE "plate_number" = 'LOL-101' AND zone_id = (
    SELECT "zone_id" FROM street_names
    WHERE street = 'Kossuth tér');


-- Checks if a car already has an issued ticket for today
SELECT * FROM "issued_fines"
WHERE "plate_number" = 'SIN-816'
AND DATE("fine_date") = DATE('now');


-- You can issue a parking ticket to car, the fine_date and payment deadline is automatic.
INSERT INTO "issued_fines" ("officer_id", "plate_number", "street_name")
VALUES (1, 'ABC-123', 'Blaha Lujza tér');


--- Checks expired payments in "issued_fines"
SELECT * FROM "issued_fines"
WHERE "payment_deadline" < DATE('now')
AND "already_paid" = 'NO';


-- Parking fines between a time range
SELECT * FROM "issued_fines"
WHERE "fine_date" 
BETWEEN 'YYYY-MM-DD' AND 'YYYY-MM-DD';


-- Fines from specific parking inspectors
SELECT * FROM "issued_fines"
WHERE "officer_id" = 1;


-- Start mobile parking
-- Price automatically calculated by zone price
INSERT INTO "ongoing_mobile_parking" ("plate_number", "zone_id")
VALUES ('ABC-123', (SELECT "zone_id" FROM "zone_prices"
    WHERE "zone_id" = (
        SELECT "zone_id" FROM "street_names"
        WHERE "street" = 'Petőfi utca')));


-- Checks if you have active parking in progress to a specific car's plate - index ok
SELECT * FROM "ongoing_mobile_parking"
WHERE "plate_number" = 'ABC-123';


-- Stop mobile parking
DELETE FROM "ongoing_mobile_parking"
WHERE "plate_number" = 'ABC-123';


-- Paying parking fine
UPDATE "issued_fines"
SET 
"already_paid" = 'YES',
"payment_date" = DATETIME('now')
WHERE "plate_number" = 'SIN-816'
AND "id" = 1;


-- Count all issued parking permits group by zones
SELECT COUNT("id") AS "number of permits", zone_id FROM "parking_permits"
GROUP BY "zone_id";