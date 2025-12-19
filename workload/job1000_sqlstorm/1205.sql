
WITH TitleCast AS (
    SELECT 
        t.id AS title_id,
        t.title,
        t.production_year,
        a.name AS actor_name,
        rc.role AS role_name,
        ROW_NUMBER() OVER (PARTITION BY t.id ORDER BY c.nr_order) AS actor_order
    FROM 
        aka_title t
    JOIN 
        cast_info c ON t.id = c.movie_id
    JOIN 
        aka_name a ON c.person_id = a.person_id
    JOIN 
        role_type rc ON c.role_id = rc.id
    WHERE 
        t.production_year BETWEEN 2000 AND 2023
),
CompanyInfo AS (
    SELECT 
        t.id AS title_id,
        MIN(c.name) AS company_name,
        STRING_AGG(DISTINCT ct.kind, ', ') AS company_types
    FROM 
        movie_companies mc
    JOIN 
        company_name c ON mc.company_id = c.id
    JOIN 
        company_type ct ON mc.company_type_id = ct.id
    JOIN 
        aka_title t ON mc.movie_id = t.id
    GROUP BY 
        t.id
),
FilteredTitles AS (
    SELECT 
        tc.title_id,
        tc.title,
        tc.production_year,
        tc.actor_name,
        tc.role_name,
        ci.company_name,
        ci.company_types
    FROM 
        TitleCast tc
    LEFT JOIN 
        CompanyInfo ci ON tc.title_id = ci.title_id
    WHERE 
        tc.actor_name IS NOT NULL
)
SELECT 
    title_id,
    title,
    production_year,
    actor_name,
    role_name,
    company_name,
    company_types,
    COUNT(*) OVER (PARTITION BY production_year) AS total_titles_per_year,
    ROW_NUMBER() OVER (PARTITION BY title_id ORDER BY production_year DESC) AS actor_order
FROM 
    FilteredTitles
WHERE 
    company_name IS NOT NULL
ORDER BY 
    production_year DESC, total_titles_per_year DESC
LIMIT 100;
