-- All data from owners who requested parking permit in their parking zone
CREATE TABLE "owners" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "company_name" TEXT DEFAULT NULL,
    "street" TEXT NOT NULL,
    "apartment_number" INTEGER DEFAULT NULL,
    "floor" INTEGER DEFAULT NULL,
    "door" INTEGER DEFAULT NULL,
    "phone" TEXT NOT NULL,
    "email" TEXT UNIQUE NOT NULL,
    PRIMARY KEY ("id")
);


-- Stores the data about permitted cars. It is easier to identify them in difficult cases
-- In MySQL plate_number should be in regex format.
CREATE TABLE "car_data" (
    "plate_number" TEXT,
    "owner_id" INTEGER NOT NULL, 
    "manufacturer" TEXT NOT NULL,
    "weight" INTEGER CHECK("weight" < 9999 AND WEIGHT > 0) NOT NULL,
    PRIMARY KEY ("plate_number"),
    FOREIGN KEY ("owner_id") REFERENCES "owners"("id") ON DELETE CASCADE
);
-- 

-- Zone permits for different plate numbers
CREATE TABLE "parking_permits" (
    "id" INTEGER,
    "plate_number" TEXT UNIQUE NOT NULL ,
    "permit_type" TEXT CHECK(permit_type IN ('residental', 'business')) NOT NULL,
    "zone_id" INTEGER NOT NULL,
    "start_date" DATE,
    "end_date" DATE,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("plate_number") REFERENCES "car_data"("plate_number") ON DELETE CASCADE
);


-- All streets inside the district and which zone those streets located
CREATE TABLE "street_names" (
    "id" INTEGER,
    "street" TEXT UNIQUE,
    "zone_id" INTEGER NOT NULL,     
    PRIMARY KEY ("id")
);

-- Parking prices for different zones
CREATE TABLE "zone_prices" (
    "zone_id" INTEGER,
    "parking_price" REAL NOT NULL,
    PRIMARY KEY ("zone_id"),
    FOREIGN KEY ("zone_id") REFERENCES "street_names"("zone_id")
);


-- Parking officers 
CREATE TABLE "parking_officers" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    PRIMARY KEY ("id")
);

-- Stores ongoing mobile parking cars
-- Plate number in this case not referencing the original database because this is  temporary state. Contains who bought it's ticket from mobile phone
CREATE TABLE "ongoing_mobile_parking" (
    "id" INTEGER,
    "plate_number" TEXT NOT NULL,
    "permit_type" TEXT,
    "zone_id" INTEGER NOT NULL,
    "hourly_price" REAL,
    "start_date" DATETIME,                  
    "end_date" DATETIME,                 
    PRIMARY KEY ("id"),
    FOREIGN KEY ("zone_id") REFERENCES "zone_prices"("zone_id")
);


-- Contains issued fines of which parking officer issued to which cars
CREATE TABLE "issued_fines" (
    "id" INTEGER,
    "officer_id" INTEGER NOT NULL,
    "plate_number" TEXT NOT NULL,
    "fine_date" DATETIME,
    "street_name" TEXT NOT NULL,
    "payment_deadline" DATETIME,
    "already_paid" TEXT NOT NULL CHECK(already_paid IN ('YES', 'NO')) DEFAULT 'NO',
    "payment_date" DATETIME DEFAULT NULL,
    "surcharge_rate" REAL, 
    PRIMARY KEY ("id"),
    FOREIGN KEY ("officer_id") REFERENCES "parking_officers"("id"),
    FOREIGN KEY ("street_name") REFERENCES "street_names"("street")
);



-- TRIGGERS -- 
-- Automatically add surcharge price, fine date and the payment's deadline to issued fines.
CREATE TRIGGER "calculate_surcharge_rate_and_fine_date_deadline"
AFTER INSERT ON "issued_fines"
FOR EACH ROW
BEGIN
    UPDATE "issued_fines"
    SET 
    "fine_date" = DATETIME('now'),
    "payment_deadline" = DATETIME('now', '+14 days'),
    "surcharge_rate" = (
        SELECT "parking_price" * 10 
        FROM "zone_prices"
        JOIN "street_names" ON "zone_prices"."zone_id" = "street_names"."zone_id"
        WHERE "street_names"."street" = NEW."street_name")
    WHERE "id" = NEW."id";
END;


-- Adds a start and end date to a started mobile parking
-- & automatic hourly price based on which zone the car in parks
CREATE TRIGGER "set_parking_dates_prices"
AFTER INSERT ON "ongoing_mobile_parking"
FOR EACH ROW
BEGIN
    UPDATE "ongoing_mobile_parking" 
    SET 
    "start_date" = DATETIME('now'),
    "end_date" = DATETIME('now', '+3 hours'),
    "permit_type" = 'mobile parking',
    "hourly_price" = (
        SELECT "parking_price"
        FROM "zone_prices" 
        WHERE "zone_prices"."zone_id" = NEW."zone_id")
    WHERE "id" = NEW."id";
END;


-- Optional 
-- After a new mobile parking has been started. It deletes the expired mobile parkings permits. Could be better with "EVENT" keyword in mysql.
CREATE TRIGGER "delete_expired_tickets"
AFTER INSERT ON "ongoing_mobile_parking"
BEGIN
  DELETE FROM "ongoing_mobile_parking" WHERE "end_date" < DATETIME('now');
END;



-- INDEXES -- 
CREATE INDEX "idx_parking_permits_plate_number" ON "parking_permits" ("plate_number");
CREATE INDEX "idx_street_names_street" ON "street_names" ("street");
CREATE INDEX "idx_ongoing_mobile_parking_plate_number" ON "ongoing_mobile_parking" ("plate_number");
CREATE INDEX "idx_issued_fines_plate_number" ON "issued_fines" ("plate_number");
CREATE INDEX "idx_issued_fines_officer_id" ON "issued_fines" ("officer_id");
CREATE INDEX "idx_issued_fines_fine_date" ON "issued_fines" ("fine_date");
CREATE INDEX "idx_issued_fines_payment_date" ON "issued_fines" ("payment_date");
CREATE INDEX "idx_issued_fines_car_data" ON "car_data" ("owner_id");
CREATE INDEX "idx_ongoing_mobile_parking_end_date" ON "ongoing_mobile_parking"("end_date");



-- VIEWS --
-- Number of unpaid parking issues for this month
CREATE VIEW "unpaid_parking_issues_this_month" AS
SELECT COUNT("already_paid") AS "Waiting for payment" FROM "issued_fines"
WHERE "already_paid" = 'NO'
AND "fine_date" BETWEEN DATETIME('now', 'start of month') AND DATETIME('now', 'start of month', '+1 month', '-1 second');

-- Total collected surcharge payment for the actual month
CREATE VIEW "parking_fines_sum_for_this_month" AS
SELECT SUM("surcharge_rate") AS "Total amount paid" FROM "issued_fines"
WHERE "already_paid" = 'YES' AND "payment_date" BETWEEN DATETIME('now', 'start of month')  AND DATETIME('now', 'start of month', '+1 month', '-1 second');

