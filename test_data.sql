-- Adds test data to the database, pragma foreign_keys = 0 is needed to delete all relational data if you want to insert it again.
PRAGMA foreign_keys = 0;

DELETE FROM "issued_fines";
DELETE FROM "ongoing_mobile_parking";
DELETE FROM "parking_officers";
DELETE FROM "parking_permits";
DELETE FROM "car_data";
DELETE FROM "street_names";
DELETE FROM "zone_prices";
DELETE FROM "owners";


-- Owners
INSERT INTO "owners" (id, first_name, last_name, company_name, street, apartment_number, floor, door, phone, email) 
VALUES
(1, 'Gábor', 'Kiss', NULL, 'Petőfi utca', 10, 3, 12, '+06301234567', 'gabor.kiss@testmail.com'),
(2, 'Anna', 'Nagy', 'Best Corp Kft.', 'Kossuth tér', NULL, NULL, NULL, '36309876543', 'anna.nagy@testmail.com'),
(3, 'Robert', 'Károly', NULL, 'Kossuth tér', 3, 12, NULL, '06301112223', 'robert.karoly@testmail.com');

-- Car_data
INSERT INTO "car_data" (plate_number, owner_id, manufacturer, weight) 
VALUES
('ABC-123', 1, 'Toyota', 1300),
('XYZ-789', 2, 'Volkswagen', 1600),
('BOS-543', 3, 'Mercedes', 2100),
('ANA-001', 2, 'Opel', 1700);

-- Parking permits until next year first of februar
INSERT INTO "parking_permits" (id, plate_number, permit_type, zone_id, start_date, end_date) 
VALUES
(1, 'ABC-123', 'residental', 1, DATE('now'), DATE('now', '+1 year', 'start of year', '+1 month')),
(2, 'XYZ-789', 'business', 2, DATE('now'), DATE('now', '+1 year', 'start of year', '+1 month')),
(3, 'BOS-543', 'residental',2, DATE('now'), DATE('now', '+1 year', 'start of year', '+1 month')),
(4, 'ANA-001', 'residental', 2, DATE('now'), DATE('now', '+1 year', 'start of year', '+1 month'));

-- Street names and zone ids
INSERT INTO "street_names" (id, street, zone_id) 
VALUES
(1, 'Petőfi utca', 1),
(2, 'Kossuth tér', 2),
(3, 'Blaha Lujza tér', 2),
(4, 'Akácfa utca', 2),
(5, 'Bogdáni út', 1),
(6, 'Huszti út', 1),
(7, 'Föld utca', 1),
(8, 'Lajos utca', 2),
(9, 'Tulipán utca', 1),
(10, 'Alma utca', 1);

-- Zone prices
INSERT INTO "zone_prices" (zone_id, parking_price) 
VALUES
(1, 350.0),
(2, 500.0);

-- Parking officers
INSERT INTO parking_officers (id, first_name, last_name) 
VALUES
(1, 'László', 'Szabó'),
(2, 'Judit', 'Tóth'),
(3, 'Benedek', 'Pápa');

-- Ongoing mobile_parking
INSERT INTO ongoing_mobile_parking (id, plate_number, zone_id) 
VALUES
(1, 'DEF-456', 1),
(2, 'LOL-101', 2),
(3, 'PAX-823', 2);

-- Issued fines
INSERT INTO issued_fines (id, officer_id, plate_number, street_name) 
VALUES
(1, 1, 'SIN-816', 'Huszti út'),
(2, 1, 'EHH-433', 'Alma utca'),
(3, 3, 'RAW-999', 'Petőfi utca');


PRAGMA foreign_keys = 1;