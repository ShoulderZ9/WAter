WITH movie_summary AS (
    SELECT 
        mt.title AS movie_title, 
        ct.kind AS company_type, 
        COUNT(DISTINCT c.person_id) AS cast_count,
        ARRAY_AGG(DISTINCT ak.name) AS actor_names,
        AVG(COALESCE(mv.production_year, 0)) AS avg_production_year
    FROM 
        aka_title mt
    LEFT JOIN 
        movie_companies mc ON mt.id = mc.movie_id
    LEFT JOIN 
        company_name cn ON mc.company_id = cn.id
    LEFT JOIN 
        company_type ct ON mc.company_type_id = ct.id
    LEFT JOIN 
        complete_cast cc ON mt.id = cc.movie_id
    LEFT JOIN 
        cast_info c ON cc.subject_id = c.id
    LEFT JOIN 
        aka_name ak ON c.person_id = ak.person_id
    LEFT JOIN 
        title mv ON mc.movie_id = mv.id
    GROUP BY 
        mt.title, ct.kind
),
ranked_movies AS (
    SELECT 
        movie_title,
        company_type,
        cast_count,
        actor_names,
        avg_production_year,
        ROW_NUMBER() OVER (PARTITION BY company_type ORDER BY avg_production_year DESC) AS rank
    FROM 
        movie_summary
)
SELECT 
    a.movie_title, 
    a.company_type,
    a.cast_count,
    a.actor_names,
    a.avg_production_year
FROM 
    ranked_movies a
WHERE 
    a.rank <= 5
ORDER BY 
    a.company_type, a.avg_production_year DESC;
