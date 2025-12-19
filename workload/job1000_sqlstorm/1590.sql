
WITH ranked_movies AS (
    SELECT 
        t.title,
        t.production_year,
        COUNT(ci.person_id) AS cast_count,
        RANK() OVER (PARTITION BY t.production_year ORDER BY COUNT(ci.person_id) DESC) AS year_rank
    FROM 
        aka_title t
    LEFT JOIN 
        complete_cast cc ON t.id = cc.movie_id
    LEFT JOIN 
        cast_info ci ON cc.subject_id = ci.id
    WHERE 
        t.production_year IS NOT NULL
    GROUP BY 
        t.title, t.production_year
),
top_movies AS (
    SELECT 
        title,
        production_year,
        cast_count
    FROM 
        ranked_movies
    WHERE 
        year_rank <= 5
),
movie_keywords AS (
    SELECT 
        t.title,
        STRING_AGG(k.keyword, ', ') AS keywords
    FROM 
        top_movies t
    LEFT JOIN 
        movie_keyword mk ON mk.movie_id IN (SELECT id FROM aka_title WHERE title = t.title)
    LEFT JOIN 
        keyword k ON mk.keyword_id = k.id
    GROUP BY 
        t.title
),
final_output AS (
    SELECT 
        mv.title,
        mv.production_year,
        mv.cast_count,
        COALESCE(mk.keywords, 'No keywords') AS keywords,
        CASE 
            WHEN mv.production_year < 2000 THEN 'Classic'
            WHEN mv.production_year BETWEEN 2000 AND 2010 THEN 'Modern'
            ELSE 'Recent'
        END AS era
    FROM 
        top_movies mv
    LEFT JOIN 
        movie_keywords mk ON mv.title = mk.title
)
SELECT 
    f.title,
    f.production_year,
    f.cast_count,
    f.keywords,
    f.era
FROM 
    final_output f
WHERE 
    f.cast_count > 10
ORDER BY 
    f.production_year DESC, f.cast_count DESC;
