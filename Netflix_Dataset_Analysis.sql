---- NETFLIX DATASET ANALYSIS ----


CREATE TABLE IF NOT EXISTS netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);


SELECT * FROM netflix;

-- SQL Queries

-- 1. Write a query to count the number of Movies vs TV Shows.

CREATE VIEW count_of_content AS
SELECT 
	DISTINCT type, 
	COUNT(show_id) AS total_count
FROM netflix
GROUP BY 1;

SELECT * FROM count_of_content;


-- 2. Write a query to find the most common rating for movies and TV shows.

CREATE VIEW common_rating AS
SELECT 
	type,
	rating
FROM (
	SELECT 
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix
	GROUP BY 1,2
	) AS t1
WHERE ranking = 1;

SELECT * FROM common_rating;


-- 3. Write a query to list all movies released in a specific year (e.g. 2020).

CREATE VIEW released_in_2020 AS
SELECT * FROM netflix
WHERE 
	release_year = 2020
	AND
	type = 'Movie';

SELECT * FROM released_in_2020;


-- 4. Write a query to find the top 5 countries with the most content on Netflix.

CREATE VIEW top_5_country AS
SELECT * FROM 
(
SELECT
	country,
	UNNEST(STRING_TO_ARRAY(country,',')) AS new_country,
	COUNT(*) AS total_content
FROM netflix
GROUP BY 1
) AS t1
WHERE 
	country IS NOT NULL
	AND
	new_country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;
	
SELECT * FROM top_5_country;


-- 5. Write a query to identify the longest movie.

CREATE VIEW longest_movies AS
SELECT 
	*
FROM netflix
WHERE 
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix);

SELECT * FROM longest_movies;


-- 6. Write a query to find content added in the last 5 years.

CREATE VIEW content_in_last_5_years AS
SELECT 
	* 
FROM netflix
WHERE TO_DATE(date_added , 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 YEARS'
ORDER BY date_added;

SELECT * FROM content_in_last_5_years;


-- 7. Write a query to find all the movies/TV shows by director 'Rajiv Chilaka'.

CREATE VIEW rajiv_chilaka_movies_tv_shows AS
SELECT * FROM
(
SELECT 
	*,
	UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
FROM netflix
) AS t2
WHERE director_name = 'Rajiv Chilaka';

SELECT * FROM rajiv_chilaka_movies_tv_shows;


-- 8. Write a query to list all TV shows with more than 5 seasons.

CREATE VIEW tv_show_with_more_than_5_seasons AS
SELECT 
	*
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1):: NUMERIC > 5
ORDER BY duration DESC;

SELECT * FROM tv_show_with_more_than_5_seasons;


-- 9. Write a query to count the number of content items in each genre.

CREATE VIEW count_of_content_in_genre AS
SELECT
	--listed_in,
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS listed_in_sp,
	COUNT(*) AS num_of_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;

SELECT * FROM count_of_content_in_genre;


-- 10. Write a query to find each year and the average numbers of content release in India on netflix and 
--     return top 5 year with highest avg content release 

CREATE VIEW content_release_in_india AS
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
	COUNT(*),
	ROUND
	(COUNT(*) :: NUMERIC/(SELECT COUNT(*) FROM netflix WHERE country = 'India') :: NUMERIC * 100, 2) 
	 AS avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 3 DESC
LIMIT 5;

SELECT * FROM content_release_in_india;


-- 11.  Write a query to list all movies that are documentaries.

CREATE VIEW documentary_movies AS
SELECT * FROM
(
SELECT
	*,
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS listed_in_sp
FROM netflix
WHERE type = 'Movie'
) AS t3
WHERE listed_in_sp = 'Documentaries'
ORDER BY show_id;

SELECT * FROM documentary_movies;


-- 12. Write a query to find all content without a director.

CREATE VIEW no_director AS
SELECT * FROM netflix
WHERE director IS NULL;

SELECT * FROM no_director;


-- 13. Write a query to find how many movies actor 'Salman Khan' appeared in last 10 years.

CREATE VIEW salman_khan_movies AS
SELECT * FROM netflix
WHERE 
	casts ILIKE '%Salman khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

SELECT * FROM salman_khan_movies;


-- 14. Write a query to find the top 10 actors who have appeared in the highest number of 
--     movies produced in India.

CREATE VIEW top_10_actors_with_highest_movies AS
SELECT
	UNNEST(STRING_TO_ARRAY(casts, ',')) AS casts_sp,
	COUNT(*)
FROM netflix
WHERE 
	country = 'India'
	AND
	type = 'Movie'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

SELECT * FROM top_10_actors_with_highest_movies;


-- 15. Categorize the content based on the presence of the keyword 'violence' in 
--     the description field. Label content containing the keyword as 'Bad' and all other 
--     content as 'Good'. Count how many items fall into each category.

CREATE VIEW content_classification AS
SELECT 
	type,
	catagory,
	COUNT(*) AS content_count
FROM
(
SELECT
	*,
	CASE 
	WHEN description ILIKE '%violence%' THEN 'Bad Content'
	ELSE 'Good Content'
	END AS catagory
FROM netflix
) AS t5
GROUP BY 1,2
ORDER BY 1;

SELECT * FROM content_classification;

-- END OF QUERIES --