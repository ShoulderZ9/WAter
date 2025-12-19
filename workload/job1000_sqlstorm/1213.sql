
WITH ranked_movies AS (
    SELECT 
        t.id AS movie_id,
        t.title,
        t.production_year,
        COUNT(DISTINCT c.person_id) AS cast_count,
        ROW_NUMBER() OVER (PARTITION BY t.production_year ORDER BY COUNT(DISTINCT c.person_id) DESC) AS rn
    FROM 
        aka_title t
    LEFT JOIN 
        complete_cast cc ON t.id = cc.movie_id
    LEFT JOIN 
        cast_info c ON cc.subject_id = c.id
    WHERE 
        t.production_year IS NOT NULL
    GROUP BY 
        t.id, t.title, t.production_year
),
top_cast_movies AS (
    SELECT 
        movie_id,
        title,
        production_year,
        cast_count
    FROM 
        ranked_movies
    WHERE 
        rn <= 5
),
movie_keywords AS (
    SELECT 
        mk.movie_id,
        STRING_AGG(k.keyword, ', ') AS keywords
    FROM 
        movie_keyword mk
    JOIN 
        keyword k ON mk.keyword_id = k.id
    GROUP BY 
        mk.movie_id
),
movie_details AS (
    SELECT 
        tm.movie_id,
        tm.title,
        tm.production_year,
        tm.cast_count,
        COALESCE(mk.keywords, 'No keywords') AS keywords
    FROM 
        top_cast_movies tm
    LEFT JOIN 
        movie_keywords mk ON tm.movie_id = mk.movie_id
)
SELECT 
    md.title,
    md.production_year,
    md.cast_count,
    md.keywords,
    (SELECT COUNT(*) FROM aka_name an WHERE an.person_id IN (SELECT DISTINCT c.person_id FROM cast_info c WHERE c.movie_id = md.movie_id)) AS unique_actors
FROM 
    movie_details md
WHERE 
    md.production_year = (SELECT MAX(production_year) FROM top_cast_movies)
ORDER BY 
    md.cast_count DESC;
