WITH movie_roles AS (
    SELECT 
        c.movie_id,
        r.role,
        COUNT(c.id) AS role_count
    FROM 
        cast_info c
    JOIN 
        role_type r ON c.role_id = r.id
    GROUP BY 
        c.movie_id, r.role
),
movie_info_aggregated AS (
    SELECT 
        mi.movie_id,
        STRING_AGG(mi.info, ', ') AS info_details
    FROM 
        movie_info mi
    WHERE 
        mi.info_type_id IN (SELECT id FROM info_type WHERE info = 'summary')
    GROUP BY 
        mi.movie_id
),
title_details AS (
    SELECT 
        t.id AS title_id,
        t.title,
        t.production_year,
        CASE 
            WHEN t.production_year < 2000 THEN 'Classic'
            WHEN t.production_year BETWEEN 2000 AND 2010 THEN 'Modern'
            ELSE 'Recent'
        END AS era
    FROM 
        title t
)
SELECT 
    t.title AS movie_title,
    t.production_year,
    TRIM(a.name) AS actor_name,
    r.role AS actor_role,
    COALESCE(mia.info_details, 'No Information Available') AS movie_summary,
    md5sum AS movie_checksum
FROM 
    title_details t
LEFT JOIN 
    complete_cast cc ON t.title_id = cc.movie_id
LEFT JOIN 
    aka_name a ON cc.subject_id = a.person_id
LEFT JOIN 
    movie_roles r ON cc.movie_id = r.movie_id
LEFT JOIN 
    movie_info_aggregated mia ON t.title_id = mia.movie_id
WHERE 
    COALESCE(a.name, '') <> '' 
    AND t.production_year >= 1990
ORDER BY 
    t.production_year DESC, 
    a.name ASC
LIMIT 100;
