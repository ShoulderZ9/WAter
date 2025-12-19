WITH movie_details AS (
    SELECT 
        t.title AS movie_title,
        t.production_year,
        STRING_AGG(DISTINCT ak.name, ', ') AS actor_names,
        COUNT(DISTINCT mc.company_id) AS company_count,
        SUM(CASE WHEN mc.note IS NOT NULL THEN 1 ELSE 0 END) AS companies_with_notes
    FROM 
        aka_title t
    LEFT JOIN 
        complete_cast cc ON t.id = cc.movie_id
    LEFT JOIN 
        cast_info ci ON cc.subject_id = ci.person_id
    LEFT JOIN 
        aka_name ak ON ci.person_id = ak.person_id
    LEFT JOIN 
        movie_companies mc ON t.id = mc.movie_id
    WHERE 
        t.production_year >= 2000
    GROUP BY 
        t.id, t.title, t.production_year
),
ranked_movies AS (
    SELECT 
        movie_title,
        production_year,
        actor_names,
        company_count,
        companies_with_notes,
        RANK() OVER (PARTITION BY production_year ORDER BY company_count DESC) AS year_rank
    FROM 
        movie_details
)
SELECT 
    mv.movie_title,
    mv.production_year,
    mv.actor_names,
    mv.company_count,
    mv.companies_with_notes,
    COALESCE(rt.role, 'Unknown Role') AS role_type
FROM 
    ranked_movies mv
LEFT JOIN 
    role_type rt ON mv.company_count = rt.id
WHERE 
    mv.year_rank <= 5
ORDER BY 
    mv.production_year DESC, 
    mv.company_count DESC;
