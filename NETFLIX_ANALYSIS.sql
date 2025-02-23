create database netflix;
use netflix;

Select * from netflix_titles;

-- 1. Count the number of Movies vs TV Shows
select 
   count(if(type = 'TV Show',1,null)) as tv_show_count,
   count(if(type = 'Movie',1,null)) as movie_count
from netflix_titles;   

select type, count(*) as total_count from netflix_titles 
group by type;

-- 2. Find the most common rating for movies and TV shows
select * from netflix_titles;

select type, rating from
(  select type, rating, count(*) as total_rating,
   rank() over (partition by type order by count(*) desc) as ranking
   from netflix_titles
   group by type, rating order by type, total_rating desc) as t1
where ranking = 1;   

-- 3. List all movies released in a specific year (e.g., 2020)
select * from netflix_titles;

select * from netflix_titles
where type = 'Movie' and release_year = '2020';

-- 4. Find the top 5 countries with the most content on Netflix
select * from netflix_titles;

select country, count(show_id) as total_content from netflix_titles
group by country order by total_content desc limit 5;

SELECT 
    country,
    COUNT(*) as total_content
FROM (
    SELECT 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(B.country, ',', NS.n), ',', -1)) AS country
    FROM (
        SELECT 1 AS n UNION ALL 
        SELECT 2 UNION ALL 
        SELECT 3 UNION ALL 
        SELECT 4 UNION ALL 
        SELECT 5 UNION ALL 
        SELECT 6 -- Add more numbers based on the maximum number of items expected.
    ) NS
    INNER JOIN netflix_titles B ON NS.n <= CHAR_LENGTH(B.country) - CHAR_LENGTH(REPLACE(B.country, ',', '')) + 1
) AS t1
WHERE TRIM(country) != ''
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie
select * from netflix_titles;

SELECT *
FROM netflix_titles
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;


select * from netflix_titles
where type = 'movie' and duration = (select max(duration) from netflix_titles);

-- 6. Find content added in the last 5 years
select * from netflix_titles;

SELECT STR_TO_DATE('01-May-18', '%d-%b-%y');

select STR_TO_DATE(date_added, '%d-%b-%y') as new_date from netflix_titles;

select * from netflix_titles
where STR_TO_DATE(date_added, '%d-%b-%y') >= current_date - interval 5 year;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from netflix_titles;

select * from netflix_titles 
where director = 'rajiv chilaka';

SELECT * 
FROM (
    SELECT 
        -- country,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(B.director, ',', NS.n), ',', -1)) AS director_name,
        B.*
    FROM (
        SELECT 1 AS n UNION ALL 
        SELECT 2 UNION ALL 
        SELECT 3 UNION ALL 
        SELECT 4 UNION ALL 
        SELECT 5 UNION ALL 
        SELECT 6  
        -- Add more numbers based on the maximum number of items expected.
    ) NS
    INNER JOIN netflix_titles B ON NS.n <= CHAR_LENGTH(B.director) - CHAR_LENGTH(REPLACE(B.director, ',', '')) + 1
) AS t1_alias -- Assign an alias here
WHERE TRIM(director_name) = 'Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons
select * from netflix_titles;

select * 
from netflix_titles
where type = 'TV Show'
and CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;


-- 9. Count the number of content items in each genre
select * from netflix_titles;

SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(B.listed_in, ',', NS.n), ',', -1)) AS genre,
    COUNT(*) as total_content
FROM (
    SELECT 1 AS n UNION ALL 
        SELECT 2 UNION ALL 
        SELECT 3 UNION ALL 
        SELECT 4 UNION ALL 
        SELECT 5 UNION ALL 
        SELECT 6   
    -- Add more numbers based on the maximum number of items expected.
) NS
INNER JOIN netflix_titles B ON NS.n <= CHAR_LENGTH(B.listed_in) - CHAR_LENGTH(REPLACE(B.listed_in, ',', '')) + 1
GROUP BY genre
ORDER BY total_content DESC;


-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
select * from netflix_titles;

SELECT 
    country,
    release_year,
    COUNT(show_id) as total_release,
    ROUND(
        CAST(COUNT(show_id) AS DECIMAL(10, 2)) /
        (SELECT CAST(COUNT(show_id) AS DECIMAL(10, 2)) FROM netflix_titles WHERE country = 'India') * 100
        ,2
    ) as avg_release
FROM netflix_titles
WHERE country = 'India'
GROUP BY country, release_year -- Corrected grouping clause.
ORDER BY avg_release DESC 
LIMIT 5;


-- 11. List all movies that are documentaries
select * from netflix_titles;

SELECT * FROM netflix_titles
WHERE listed_in LIKE '%Documentaries';


-- 12. Find all content without a director
select * from netflix_titles;

select * from netflix_titles where director is null;


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from netflix_titles;

SELECT * FROM netflix_titles
WHERE 
	cast LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select * from netflix_titles;

WITH RECURSIVE split_string AS (
    SELECT 
        SUBSTRING_INDEX(cast, ',', 1) AS actor,
        SUBSTRING(cast, LENGTH(SUBSTRING_INDEX(cast, ',', 1)) + 2) AS rest
    FROM netflix_titles
    WHERE country = 'India'
    
    UNION ALL
    
    SELECT 
        SUBSTRING_INDEX(rest, ',', 1),
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
    FROM split_string
    WHERE  actor IS NOT NULL AND actor != ''
)
SELECT actor FROM split_string limit 10;


-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--    the description field. Label content containing these keywords as 'Bad' and all other 
--    content as 'Good'. Count how many items fall into each category.
select * from netflix_titles;

SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description like '%kill%' OR description like '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix_titles
) AS categorized_content
GROUP BY 1,2
ORDER BY 2;

