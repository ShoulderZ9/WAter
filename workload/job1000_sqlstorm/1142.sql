WITH movie_details AS (
    SELECT 
        t.id AS movie_id,
        t.title,
        t.production_year,
        COALESCE(k.keyword, 'No Keyword') AS keyword,
        COUNT(DISTINCT ci.person_id) AS cast_count,
        AVG(CASE WHEN ci.nr_order IS NULL THEN 0 ELSE ci.nr_order END) AS avg_order
    FROM 
        aka_title t
    LEFT JOIN 
        movie_keyword mk ON t.id = mk.movie_id
    LEFT JOIN 
        keyword k ON mk.keyword_id = k.id
    LEFT JOIN 
        complete_cast cc ON t.id = cc.movie_id
    LEFT JOIN 
        cast_info ci ON cc.subject_id = ci.id
    GROUP BY 
        t.id, t.title, t.production_year, k.keyword
), ranked_movies AS (
    SELECT 
        movie_id, 
        title, 
        production_year, 
        keyword, 
        cast_count, 
        avg_order,
        ROW_NUMBER() OVER (PARTITION BY production_year ORDER BY cast_count DESC) AS rank
    FROM 
        movie_details
)
SELECT 
    r.movie_id,
    r.title,
    r.production_year,
    r.keyword,
    r.cast_count,
    r.avg_order,
    CASE 
        WHEN r.rank <= 5 THEN 'Top 5'
        ELSE 'Other'
    END AS ranking_category
FROM 
    ranked_movies r
WHERE 
    r.production_year BETWEEN 2000 AND 2023
ORDER BY 
    r.production_year, r.cast_count DESC;
