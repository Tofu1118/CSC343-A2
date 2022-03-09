-- Q3. North and South Connections

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3 (
    outbound VARCHAR(30),
    inbound VARCHAR(30),
    direct INT,
    one_con INT,
    two_con INT,
    earliest timestamp
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS CanadianAirports CASCADE;
DROP VIEW IF EXISTS CanadianOut CASCADE;
DROP VIEW IF EXISTS CanadianIn CASCADE;
DROP VIEW IF EXISTS USAAirports CASCADE;
DROP VIEW IF EXISTS USAOut CASCADE;
DROP VIEW IF EXISTS USAIn CASCADE;
DROP VIEW IF EXISTS ConnectingAirports CASCADE;
DROP VIEW IF EXISTS CanToUSADirectFlights CASCADE;
DROP VIEW IF EXISTS USAToCanDirectFlights CASCADE;
DROP VIEW IF EXISTS CanToUSAOneCons CASCADE;
DROP VIEW IF EXISTS USAToCanOneCons CASCADE;
DROP VIEW IF EXISTS CanToUSATwoCons CASCADE;
DROP VIEW IF EXISTS USAToCanTwoCons CASCADE;
DROP VIEW IF EXISTS AllPossibleConnections CASCADE;
DROP VIEW IF EXISTS AllCityCombos CASCADE;
DROP VIEW IF EXISTS FinalRelation CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW CanadianAirports AS
SELECT *
FROM Airport
WHERE country = 'Canada';

CREATE VIEW CanadianOut AS
SELECT *
FROM CanadianAirports JOIN Flight ON CanadianAirports.code = Flight.outbound
WHERE DATE(Flight.s_dep) = date '2022-04-30';

CREATE VIEW CanadianIn AS
SELECT *
FROM CanadianAirports JOIN Flight ON CanadianAirports.code = Flight.inbound
WHERE DATE(Flight.s_arv) = date '2022-04-30';

CREATE VIEW USAAirports AS
SELECT *
FROM Airport
WHERE country = 'USA';

CREATE VIEW USAOut AS
SELECT *
FROM USAAirports JOIN Flight ON USAAirports.code = Flight.outbound
WHERE DATE(Flight.s_dep) = date '2022-04-30';

CREATE VIEW USAIn AS
SELECT *
FROM USAAirports JOIN Flight ON USAAirports.code = Flight.inbound
WHERE DATE(Flight.s_arv) = date '2022-04-30';

CREATE VIEW ConnectingAirports AS
SELECT code, name, city, country, f1.inbound as inbound, f1.id as inbound_id, f1.s_arv as inbound_time, f2.outbound as outbound, f2.id as outbound_id, f2.s_dep as outbound_time
FROM Airport, Flight f1, Flight f2
WHERE f1.inbound = airport.code
AND f2.outbound = airport.code
AND DATE(f1.s_arv) = date '2022-04-30'
AND DATE(f2.s_dep) = date '2022-04-30'
AND f1.s_arv + time '00:30:00' < f2.s_dep;

CREATE VIEW CanToUSADirectFlights AS
SELECT CanadianOut.city as outbound, USAIn.city as inbound, USAIn.s_arv as s_arv, 1 as direct, 0 as one_con, 0 as two_con
FROM CanadianOut, USAIn
WHERE CanadianOut.id = USAIn.id;

CREATE VIEW USAToCanDirectFlights AS
SELECT USAOut.city as outbound, CanadianIn.city as inbound, CanadianIn.s_arv as s_arv, 1 as direct, 0 as one_con, 0 as two_con
FROM USAOut, CanadianIn
WHERE USAOut.id = CanadianIn.id;

CREATE VIEW CanToUSAOneCons AS
SELECT CanadianOut.city as outbound, USAIn.city as inbound, USAIn.s_arv as s_arv, 0 as direct, 1 as one_con, 0 as two_con
FROM CanadianOut, ConnectingAirports, USAIn
WHERE CanadianOut.id = ConnectingAirports.inbound_id
AND ConnectingAirports.outbound_id = USAIn.id;

CREATE VIEW USAToCanOneCons AS
SELECT USAOut.city as outbound, CanadianIn.city as inbound, CanadianIn.s_arv as s_arv, 0 as direct, 1 as one_con, 0 as two_con
FROM USAOut, ConnectingAirports, CanadianIn
WHERE USAOut.id = ConnectingAirports.inbound_id
AND ConnectingAirports.outbound_id = CanadianIn.id;

CREATE VIEW CanToUSATwoCons AS
SELECT CanadianOut.city as outbound, USAIn.city as inbound, USAIn.s_arv as s_arv, 0 as direct, 0 as one_con, 1 as two_con
FROM CanadianOut, ConnectingAirports C1, ConnectingAirports C2, USAIn
WHERE CanadianOut.id = C1.inbound_id
AND C1.outbound_id = C2.inbound_id
AND C2.outbound_id = USAIn.id;

CREATE VIEW USAToCanTwoCons AS
SELECT USAOut.city as outbound, CanadianIn.city as inbound, CanadianIn.s_arv as s_arv, 0 as direct, 0 as one_con, 1 as two_con
FROM USAOut, ConnectingAirports C1, ConnectingAirports C2, CanadianIn
WHERE USAOut.id = C1.inbound_id
AND C1.outbound_id = C2.inbound_id
AND C2.outbound_id = CanadianIn.id;

CREATE VIEW AllPossibleConnections AS
(SELECT * FROM CanToUSADirectFlights)
UNION
(SELECT * FROM USAToCanDirectFlights)
UNION
(SELECT * FROM CanToUSAOneCons)
UNION
(SELECT * FROM USAToCanOneCons)
UNION
(SELECT * FROM CanToUSATwoCons)
UNION
(SELECT * FROM USAToCanTwoCons);

CREATE VIEW AllCityCombos AS
SELECT a1.city as outbound, a2.city as inbound
FROM Airport a1, Airport a2
WHERE (a1.country = 'Canada' AND a2.country = 'USA')
OR (a1.country = 'USA' AND a2.country = 'Canada');

CREATE VIEW FinalRelation AS
SELECT AllCityCombos.outbound as outbound, AllCityCombos.inbound as inbound, s_arv, direct, one_con, two_con
FROM AllCityCombos left outer join AllPossibleConnections
ON (AllCityCombos.outbound = AllPossibleConnections.outbound
AND AllCityCombos.inbound = AllPossibleConnections.inbound);

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3
SELECT outbound, inbound, sum(direct) as direct, sum(one_con) as one_con, sum(two_con) as two_con, min(s_arv) as earliest
FROM FinalRelation
GROUP BY outbound, inbound;
