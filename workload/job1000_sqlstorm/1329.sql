WITH RankedTitles AS (
    SELECT 
        t.title,
        t.production_year,
        ROW_NUMBER() OVER (PARTITION BY t.production_year ORDER BY t.production_year DESC) AS year_rank
    FROM 
        aka_title t
    WHERE 
        t.production_year IS NOT NULL
),
TopRankedTitles AS (
    SELECT 
        title, 
        production_year 
    FROM 
        RankedTitles 
    WHERE 
        year_rank <= 5
),
 casts AS (
    SELECT 
        c.movie_id,
        COUNT(DISTINCT ci.person_id) AS actor_count
    FROM 
        cast_info ci
    JOIN 
        complete_cast c ON ci.movie_id = c.movie_id
    GROUP BY 
        c.movie_id
)
SELECT 
    t.title,
    t.production_year,
    COALESCE(c.actor_count, 0) AS actor_count,
    CASE 
        WHEN c.actor_count IS NULL THEN 'No Actors'
        ELSE 'Has Actors'
    END AS actor_status
FROM 
    TopRankedTitles t
LEFT JOIN 
    casts c ON t.title = (SELECT title FROM aka_title WHERE movie_id = c.movie_id LIMIT 1);
