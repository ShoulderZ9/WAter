WITH ranked_movies AS (
    SELECT 
        t.id AS movie_id,
        t.title,
        t.production_year,
        ROW_NUMBER() OVER (PARTITION BY t.production_year ORDER BY COUNT(DISTINCT c.person_id) DESC) AS rank
    FROM 
        aka_title t
    JOIN 
        cast_info c ON t.id = c.movie_id
    GROUP BY 
        t.id, t.title, t.production_year
),
corporate_movies AS (
    SELECT 
        DISTINCT m.movie_id,
        m.company_id,
        c.name AS company_name,
        co.kind AS company_type
    FROM 
        movie_companies m
    JOIN 
        company_name c ON m.company_id = c.id
    JOIN 
        company_type co ON m.company_type_id = co.id
    WHERE 
        c.country_code IS NOT NULL
),
filtered_movies AS (
    SELECT 
        rm.movie_id,
        rm.title,
        rm.production_year,
        cm.company_name,
        cm.company_type
    FROM 
        ranked_movies rm
    LEFT JOIN 
        corporate_movies cm ON rm.movie_id = cm.movie_id
    WHERE 
        rm.rank <= 5
)
SELECT 
    f.title,
    f.production_year,
    f.company_name,
    f.company_type,
    CASE 
        WHEN f.company_type IS NULL THEN 'Independent'
        ELSE f.company_type 
    END AS final_company_type
FROM 
    filtered_movies f
ORDER BY 
    f.production_year DESC, 
    f.title ASC
LIMIT 20;
