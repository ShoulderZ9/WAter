WITH movie_with_keywords AS (
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
movie_info_details AS (
    SELECT 
        mi.movie_id, 
        MAX(CASE WHEN it.info = 'rating' THEN mi.info END) AS rating,
        MAX(CASE WHEN it.info = 'description' THEN mi.info END) AS description
    FROM 
        movie_info mi
    JOIN 
        info_type it ON mi.info_type_id = it.id
    GROUP BY 
        mi.movie_id
), 
cast_details AS (
    SELECT 
        ci.movie_id,
        COUNT(*) AS total_cast,
        MAX(CASE WHEN rt.role = 'lead' THEN ci.person_id END) AS lead_actor
    FROM 
        cast_info ci
    JOIN 
        role_type rt ON ci.role_id = rt.id
    GROUP BY 
        ci.movie_id
)
SELECT 
    t.title, 
    t.production_year, 
    mwk.keywords, 
    mid.rating, 
    mid.description, 
    cd.total_cast, 
    (SELECT ak.name FROM aka_name ak WHERE ak.person_id = cd.lead_actor) AS lead_actor_name
FROM 
    title t
LEFT JOIN 
    movie_with_keywords mwk ON t.id = mwk.movie_id
LEFT JOIN 
    movie_info_details mid ON t.id = mid.movie_id
LEFT JOIN 
    cast_details cd ON t.id = cd.movie_id
WHERE 
    t.production_year >= 2000 AND 
    (mid.rating IS NOT NULL OR mid.description IS NOT NULL)
ORDER BY 
    cd.total_cast DESC, 
    t.production_year DESC
LIMIT 100;
