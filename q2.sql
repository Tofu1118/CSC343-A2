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
DROP VIEW IF EXISTS FlightAirlineInfo CASCADE;
DROP VIEW IF EXISTS FlightAirportInfo CASCADE;
DROP VIEW IF EXISTS RealTimes CASCADE;
DROP VIEW IF EXISTS FlightInfo CASCADE;
DROP VIEW IF EXISTS RealFlightInfo CASCADE;
DROP VIEW IF EXISTS International CASCADE;
DROP VIEW IF EXISTS InternationalLate CASCADE;
DROP VIEW IF EXISTS InternationalVeryLate CASCADE;
DROP VIEW IF EXISTS InternationalLittleLate CASCADE;
DROP VIEW IF EXISTS ILLInfo CASCADE;
DROP VIEW IF EXISTS IVLInfo CASCADE;
DROP VIEW IF EXISTS Domestic CASCADE;
DROP VIEW IF EXISTS DomesticLate CASCADE;
DROP VIEW IF EXISTS DomesticVeryLate CASCADE;
DROP VIEW IF EXISTS DomesticLittleLate CASCADE;
DROP VIEW IF EXISTS DLLInfo CASCADE;
DROP VIEW IF EXISTS DVLInfo CASCADE;
DROP VIEW IF EXISTS AllRefundInfo CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW FlightAirlineInfo AS
SELECT id, airline, name as airline_name, flight_num, plane, outbound, inbound, s_dep as scheduled_departure, s_arv as scheduled_arrival
FROM flight join airline on flight.airline = airline.code;

CREATE VIEW FlightAirportInfo AS
SELECT FlightAirlineInfo.id as id, airline, airline_name, flight_num, plane, outbound, a1.country as outCountry, inbound, a2.country as inCountry, scheduled_departure, scheduled_arrival
FROM FlightAirlineInfo, airport a1, airport a2
WHERE FlightAirlineInfo.outbound = a1.code and FlightAirlineInfo.inbound = a2.code;

CREATE VIEW RealTimes AS
SELECT departure.flight_id as flight_id, departure.datetime as real_departure, arrival.datetime as real_arrival
FROM departure join arrival on departure.flight_id = arrival.flight_id;

CREATE VIEW FlightInfo AS
SELECT FlightAirportInfo.id as flight_id, airline, airline_name, flight_num, outCountry, inCountry, scheduled_departure, scheduled_arrival, pass_id, price, seat_class
FROM FlightAirportInfo join booking on FlightAirportInfo.id = booking.flight_id;

CREATE VIEW RealFlightInfo AS
SELECT FlightInfo.flight_id as flight_id, airline, airline_name, flight_num, outCountry, inCountry, scheduled_departure, scheduled_arrival, pass_id, price, seat_class, real_departure, real_arrival
FROM RealTimes join FlightInfo on RealTimes.flight_id = FlightInfo.flight_id;

CREATE VIEW International AS
SELECT *
FROM RealFlightInfo
WHERE outCountry <> inCountry;

CREATE VIEW InternationalLate AS
SELECT *
FROM International
WHERE (scheduled_departure + interval '8 hours' < real_departure)
AND ((real_arrival - scheduled_arrival) > (real_departure - scheduled_departure)/ double precision '2.0');

CREATE VIEW InternationalVeryLate AS
SELECT *
FROM InternationalLate
WHERE (scheduled_departure + interval '12 hours' < real_departure);

CREATE VIEW InternationalLittleLate AS
(SELECT * FROM InternationalLate)
EXCEPT
(SELECT * FROM InternationalVeryLate);

CREATE VIEW ILLInfo AS
SELECT airline, airline_name as name, extract(year from real_departure) as year, seat_class, price*0.35 as refund
FROM InternationalLittleLate;

CREATE VIEW IVLInfo AS
SELECT airline, airline_name as name, extract(year from real_departure) as year, seat_class, price*0.5 as refund
FROM InternationalVeryLate;

CREATE VIEW Domestic AS
(SELECT * FROM RealFlightInfo)
EXCEPT
(SELECT * FROM International);

CREATE VIEW DomesticLate AS
SELECT *
FROM Domestic
WHERE (scheduled_departure + interval '5 hours' < real_departure)
AND ((real_arrival - scheduled_arrival) > (real_departure - scheduled_departure)/ double precision '2.0');

CREATE VIEW DomesticVeryLate AS
SELECT *
FROM DomesticLate
WHERE (scheduled_departure + interval '10 hours' < real_departure);

CREATE VIEW DomesticLittleLate AS
(SELECT * FROM DomesticLate)
EXCEPT
(SELECT * FROM DomesticVeryLate);

CREATE VIEW DLLInfo AS
SELECT airline, airline_name as name, extract(year from real_departure) as year, seat_class, price*0.35 as refund
FROM DomesticLittleLate;

CREATE VIEW DVLInfo AS
SELECT airline, airline_name as name, extract(year from real_departure) as year, seat_class, price*0.5 as refund
FROM DomesticVeryLate;

CREATE VIEW AllRefundInfo AS
(SELECT * FROM ILLInfo)
UNION
(SELECT * FROM IVLInfo)
UNION
(SELECT * FROM DLLInfo)
UNION
(SELECT * FROM DVLInfo);

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2
SELECT airline, name, year, seat_class, sum(refund) as refund
FROM AllRefundInfo
GROUP BY airline, name, year, seat_class;
