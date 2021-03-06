-- Q1. Airlines

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1 (
    pass_id INT,
    name VARCHAR(100),
    airlines INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS PassBooking CASCADE;
DROP VIEW IF EXISTS Airlines CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW PassBooking AS
SELECT passenger.id as pass_id, passenger.firstName||' '||passenger.surName as name, booking.flight_id as flight_id
FROM passenger join booking on passenger.id = booking.pass_id;

CREATE VIEW Airlines AS
SELECT pass_id, name, count(distinct flight.airline) as airlines
FROM PassBooking join flight on PassBooking.flight_id = flight.id
GROUP BY PassBooking.pass_id, PassBooking.name;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1 select * from Airlines;
