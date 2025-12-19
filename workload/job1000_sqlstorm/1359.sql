
WITH RankedTitles AS (
    SELECT 
        t.title,
        t.production_year,
        ROW_NUMBER() OVER(PARTITION BY t.production_year ORDER BY t.production_year DESC) AS year_rank
    FROM 
        aka_title t
    WHERE 
        t.kind_id IN (SELECT id FROM kind_type WHERE kind LIKE 'feature%')
),
MostRecentMovies AS (
    SELECT 
        rt.title,
        rt.production_year
    FROM 
        RankedTitles rt
    WHERE 
        rt.year_rank = 1
),
ActorsInRecentMovies AS (
    SELECT 
        a.name AS actor_name,
        m.production_year,
        COUNT(DISTINCT c.movie_id) AS movie_count
    FROM 
        aka_name a
    JOIN 
        cast_info c ON a.person_id = c.person_id
    JOIN 
        aka_title m ON c.movie_id = m.id
    WHERE 
        m.production_year IN (SELECT production_year FROM MostRecentMovies)
    GROUP BY 
        a.name, m.production_year
)
SELECT 
    a.actor_name,
    COALESCE(SUM(ac.movie_count), 0) AS total_movies,
    STRING_AGG(DISTINCT m.title, ', ') AS movie_titles
FROM 
    ActorsInRecentMovies a
LEFT JOIN 
    (SELECT actor_name, production_year, COUNT(*) AS movie_count
     FROM ActorsInRecentMovies
     GROUP BY actor_name, production_year) ac ON a.actor_name = ac.actor_name AND a.production_year = ac.production_year
LEFT JOIN 
    MostRecentMovies m ON a.production_year = m.production_year
GROUP BY 
    a.actor_name
ORDER BY 
    total_movies DESC
LIMIT 10;
