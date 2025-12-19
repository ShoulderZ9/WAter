WITH movie_details AS (
    SELECT 
        t.id AS title_id,
        t.title,
        t.production_year,
        COUNT(DISTINCT c.person_id) AS actor_count,
        STRING_AGG(DISTINCT a.name, ', ') AS actors
    FROM 
        title t
    LEFT JOIN 
        complete_cast cc ON t.id = cc.movie_id
    LEFT JOIN 
        cast_info c ON cc.subject_id = c.id
    LEFT JOIN 
        aka_name a ON c.person_id = a.person_id
    WHERE 
        t.production_year BETWEEN 1990 AND 2020
    GROUP BY 
        t.id, t.title, t.production_year
),
rating_info AS (
    SELECT 
        mi.movie_id,
        COUNT(CASE WHEN it.info = 'rating' THEN 1 END) AS rating_count,
        AVG(CASE WHEN it.info = 'rating' THEN CAST(mi.info AS FLOAT) END) AS avg_rating
    FROM 
        movie_info mi
    JOIN 
        info_type it ON mi.info_type_id = it.id
    GROUP BY 
        mi.movie_id
)
SELECT 
    md.title_id,
    md.title,
    md.production_year,
    md.actor_count,
    md.actors,
    COALESCE(ri.rating_count, 0) AS rating_count,
    COALESCE(ri.avg_rating, 0) AS avg_rating
FROM 
    movie_details md
LEFT JOIN 
    rating_info ri ON md.title_id = ri.movie_id
WHERE 
    md.actor_count > 5
ORDER BY 
    md.production_year DESC, md.actor_count DESC
LIMIT 10;
