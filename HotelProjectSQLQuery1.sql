SELECT *
FROM dbo.['2018$']

SELECT *
FROM dbo.['2019$']

SELECT *
FROM dbo.['2020$']

--Unify tables
WITH hotels AS (
SELECT *
FROM dbo.['2018$']
UNION
SELECT *
FROM dbo.['2019$']
UNION
SELECT *
FROM dbo.['2020$'])

--SELECT *
--FROM hotels

--Is the hotel revenue growing (by year and by hotel type)?
--No revenue column but we have the ADR and total days so create a new column 
--SELECT 
--arrival_date_year,
--hotel,
--ROUND(SUM((stays_in_week_nights+stays_in_weekend_nights)*adr),2) AS Revenue
--FROM hotels
--GROUP BY arrival_date_year,hotel

--From output we have we can say the revenue is growing by year as well as by hotel. Also, 2020 looks like the data is incomplete so we can discard that.


SELECT *
FROM hotels
LEFT JOIN dbo.market_segment$
ON hotels.market_segment = market_segment$.market_segment 
LEFT JOIN dbo.meal_cost$
ON meal_cost$.meal = hotels.meal
