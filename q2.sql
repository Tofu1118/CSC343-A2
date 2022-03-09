-- Q2. Refunds!

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2 (
    airline CHAR(2),
    name VARCHAR(50),
    year CHAR(4),
    seat_class seat_class,
    refund REAL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS RealTimes CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW FlightAirportInfo AS
SELECT flight.id as id, airline, flight_num, plane, outbound, a1.country as outCountry, inbound, a2.country as inCountry, scheduled_departure, scheduled_arrival
FROM flight, airport a1, airport a2
WHERE flight.outbound = a1.code and flight.inbound = a2.code;

CREATE VIEW RealTimes AS
SELECT departure.flight_id as flight_id, departure.timestamp as real_departure, arrival.timestamp as real_arrival
FROM departure join arrival on departure.flight_id = arrival.flight_id;

CREATE VIEW FlightInfo AS
SELECT FlightAirportInfo.id as flight_id, airline, flight_num, outCountry, inCountry, scheduled_departure, scheduled_arrival, pass_id, price, seat_class
FROM FlightAirportInfo join booking on FlightAirportInfo.id = booking.flight_id;

CREATE VIEW RealFlightInfo AS
SELECT FlightInfo.flight_id as flight_id, airline, flight_num, outCountry, inCountry, scheduled_departure, scheduled_arrival, pass_id, price, seat_class, real_departure, real_arrival
FROM RealTimes join FlightInfo on RealTimes.flight_id = FlightInfo.flight_id;

CREATE VIEW International AS
SELECT flight_id, airline, flight_num, scheduled_departure, scheduled_arrival, pass_id, price, seat_class, real_departure, real_arrival
FROM RealFlightInfo
WHERE outCountry <> inCountry;

CREATE VIEW Domestic AS
(SELECT * FROM RealFlightInfo)
EXCEPT
(SELECT * FROM International);

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2
