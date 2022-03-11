-- Q4. Plane Capacity Histogram

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4 (
	airline CHAR(2),
	tail_number CHAR(5),
	very_low INT,
	low INT,
	fair INT,
	normal INT,
	high INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS BookedPlanes CASCADE;
DROP VIEW IF EXISTS PlaneFlightByCapacity CASCADE;
DROP VIEW IF EXISTS VeryLow CASCADE;
DROP VIEW IF EXISTS Low CASCADE;
DROP VIEW IF EXISTS Fair CASCADE;
DROP VIEW IF EXISTS Normal CASCADE;
DROP VIEW IF EXISTS High CASCADE;
DROP VIEW IF EXISTS AllFlightInfo CASCADE;
DROP VIEW IF EXISTS AllPlaneInfo CASCADE;
DROP VIEW IF EXISTS FinalRelation CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW BookedFlights AS
SELECT flight.id as flight_id, booking.id as booking_id, flight.plane as plane
FROM Flight LEFT OUTER JOIN Booking
On Flight.id = Booking.flight_id;

CREATE VIEW BookedPlanes AS
SELECT plane.tail_number as tail_number, plane.airline, capacity_economy + capacity_business + capacity_first as capacity,
       flight_id, booking_id
FROM plane, BookedFlights
WHERE plane.tail_number = BookedFlights.plane;

CREATE VIEW PlaneFlightByCapacity AS
SELECT tail_number, flight_id, airline, (case when count(booking_id) is null then 0 else count(booking_id) end)/avg(capacity) as flight_capacity
FROM BookedPlanes
GROUP BY tail_number, flight_id, airline;

CREATE VIEW VeryLow AS
SELECT tail_number, flight_id, airline, 1 as very_low, 0 as low, 0 as fair, 0 as normal, 0 as high
FROM PlaneFlightByCapacity
WHERE flight_capacity < 0.20;

CREATE VIEW Low AS
SELECT tail_number, flight_id, airline, 0 as very_low, 1 as low, 0 as fair, 0 as normal, 0 as high
FROM PlaneFlightByCapacity
WHERE flight_capacity >= 0.20
AND flight_capacity < 0.40;

CREATE VIEW Fair AS
SELECT tail_number, flight_id, airline, 0 as very_low, 0 as low, 1 as fair, 0 as normal, 0 as high
FROM PlaneFlightByCapacity
WHERE flight_capacity >= 0.40
AND flight_capacity < 0.60;

CREATE VIEW Normal AS
SELECT tail_number, flight_id, airline, 0 as very_low, 0 as low, 0 as fair, 1 as normal, 0 as high
FROM PlaneFlightByCapacity
WHERE flight_capacity >= 0.60
AND flight_capacity < 0.80;

CREATE VIEW High AS
SELECT tail_number, flight_id, airline, 0 as very_low, 0 as low, 0 as fair, 0 as normal, 1 as high
FROM PlaneFlightByCapacity
WHERE flight_capacity >= 0.80;

CREATE VIEW AllFlightInfo AS
(SELECT * FROM VeryLow)
UNION
(SELECT * FROM Low)
UNION
(SELECT * FROM Fair)
UNION
(SELECT * FROM Normal)
UNION
(SELECT * FROM High);

CREATE VIEW AllPlaneInfo AS
SELECT Plane.tail_number as tail_number, flight_id, plane.airline, very_low, low, fair, normal, high
FROM Plane left outer join AllFlightInfo
ON Plane.tail_number = AllFlightInfo.tail_number;

CREATE VIEW FinalRelation AS
SELECT airline, tail_number, sum(case when very_low is null then 0 else very_low end) as very_low, sum(case when low is null then 0 else low end) as low, sum(case when fair is null then 0 else fair end) as fair, sum(case when normal is null then 0 else normal end) as normal, sum(case when high is null then 0 else high end) as high
FROM AllPlaneInfo
GROUP BY airline, tail_number;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q4
SELECT *
FROM FinalRelation;

