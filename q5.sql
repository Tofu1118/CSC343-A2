-- Q5. Flight Hopping

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5 (
	destination CHAR(3),
	num_flights INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS day CASCADE;
DROP VIEW IF EXISTS n CASCADE;

CREATE VIEW day AS
SELECT day::date as day FROM q5_parameters;
-- can get the given date using: (SELECT day from day)

CREATE VIEW n AS
SELECT n FROM q5_parameters;
-- can get the given number of flights using: (SELECT n from n)

-- HINT: You can answer the question by writing one recursive query below, without any more views.
-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q5
WITH RECURSIVE Hopping AS (
    (SELECT Flight.inbound AS destination, 1 AS num_flights, Flight.s_arv AS arrival_time FROM Flight WHERE Flight.outbound = 'YYZ' AND DATE(Flight.s_dep) = (SELECT day from day))
    UNION ALL
    (SELECT Flight.inbound as destination, num_flights + 1 as num_flights, Flight.s_arv AS arrival_time FROM Flight, Hopping WHERE (Flight.outbound = Hopping.destination) AND (Flight.s_dep > Hopping.arrival_time) AND (Flight.s_dep < Hopping.arrival_time + interval '24 hours') AND (num_flights < (select n from n)))
)
SELECT destination, num_flights FROM Hopping;















