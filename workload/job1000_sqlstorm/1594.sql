WITH movie_details AS (
    SELECT 
        a.title AS movie_title,
        a.production_year,
        ARRAY_AGG(DISTINCT k.keyword) AS keywords,
        COUNT(DISTINCT CASE WHEN c.person_role_id IS NOT NULL THEN c.person_id END) AS cast_count
    FROM 
        aka_title a
    LEFT JOIN 
        movie_keyword mk ON a.id = mk.movie_id
    LEFT JOIN 
        keyword k ON mk.keyword_id = k.id
    LEFT JOIN 
        complete_cast cc ON a.id = cc.movie_id
    LEFT JOIN 
        cast_info c ON cc.subject_id = c.id
    WHERE 
        a.production_year >= 2000 
        AND a.kind_id = (SELECT id FROM kind_type WHERE kind = 'movie')
    GROUP BY 
        a.id, a.title, a.production_year
),
ranked_movies AS (
    SELECT 
        md.movie_title,
        md.production_year,
        md.keywords,
        md.cast_count,
        ROW_NUMBER() OVER (PARTITION BY md.production_year ORDER BY md.cast_count DESC) AS rank
    FROM 
        movie_details md
)
SELECT 
    r.movie_title,
    r.production_year,
    r.keywords,
    r.cast_count
FROM 
    ranked_movies r
WHERE 
    r.rank <= 5 
    AND r.cast_count > (
        SELECT 
            AVG(cast_count) FROM ranked_movies WHERE production_year = r.production_year
    )
ORDER BY 
    r.production_year DESC, r.cast_count DESC;
