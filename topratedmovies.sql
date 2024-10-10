-- Create table 

CREATE TABLE topratedmovies (
popularity FLOAT,
release_date DATE, 
title VARCHAR, 
vote_average FLOAT
);

-- DATA CLEANING

-- Cheking for duplicate values

-- Let's check for duplicate titles

SELECT title, COUNT(*) 
FROM topratedmovies
GROUP BY title
HAVING COUNT(*) > 1;

--  Let's investigate further.. 

-- Adding release date in the equation

SELECT title, release_date, COUNT(*) 
FROM topratedmovies
GROUP BY title, release_date
HAVING COUNT(*) > 1;

-- Adding all columns in the equation

SELECT *, COUNT(*) 
FROM topratedmovies
GROUP BY popularity, title, release_date, vote_average
HAVING COUNT(*) > 1;

-- Deleting the duplicates

WITH CTE AS (
    SELECT 
        ctid, 
        ROW_NUMBER() OVER (
            PARTITION BY popularity, release_date, title, vote_average 
            ORDER BY ctid
        ) AS row_num
    FROM 
        topratedmovies
)

DELETE FROM topratedmovies
WHERE ctid IN (
    SELECT ctid FROM CTE WHERE row_num > 1
);

-- ANALYSIS

-- Final total movies count

SELECT COUNT(*) AS total_movies
FROM topratedmovies;

-- Create new column for month, day, and year

ALTER TABLE topratedmovies
ADD COLUMN month TEXT,
ADD COLUMN day TEXT,
ADD COLUMN year INTEGER;

-- Updating the column

UPDATE topratedmovies
SET month = TO_CHAR(release_date, 'Month'),
	day = TO_CHAR(release_date, 'Day'),
	year = EXTRACT(YEAR FROM release_date);

-- What year were most top rated movies released

SELECT year, COUNT(*) AS num_of_movies
FROM topratedmovies
GROUP BY year
ORDER BY num_of_movies DESC
LIMIT 10;

-- What month most top rated movies released

SELECT month, COUNT(*) AS num_of_movies
FROM topratedmovies
GROUP BY month
ORDER BY num_of_movies DESC;

--  What day most top rated movies released

SELECT day, COUNT(*) num_of_movies
FROM topratedmovies
GROUP BY day
ORDER BY num_of_movies DESC;

-- Top 10 movies based on popularity and year released

SELECT title, popularity, year
FROM topratedmovies
ORDER BY popularity DESC
LIMIT 10;

-- Top 10 movies based on vote average and year released

SELECT title, vote_average, year
FROM topratedmovies
ORDER BY vote_average DESC
LIMIT 10;

-- What are the MAX value for popularity and vote average

SELECT MAX(popularity) AS max_popularity,
MAX(vote_average) AS max_vote_average
FROM topratedmovies;

-- Correlation between popularity and vote average

SELECT popularity, vote_average
FROM topratedmovies
ORDER BY popularity DESC
LIMIT 10;

-- Correlation between popularity and year

SELECT popularity, year
FROM topratedmovies
ORDER BY popularity DESC
LIMIT 10;

