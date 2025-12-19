WITH RankedTitles AS (
    SELECT 
        at.id AS title_id,
        at.title,
        at.production_year,
        RANK() OVER (PARTITION BY at.production_year ORDER BY a.name) AS title_rank
    FROM 
        aka_title at
    JOIN 
        movie_keyword mk ON at.movie_id = mk.movie_id
    JOIN 
        keyword k ON mk.keyword_id = k.id
    JOIN 
        cast_info ci ON at.movie_id = ci.movie_id
    JOIN 
        aka_name a ON ci.person_id = a.person_id
    WHERE 
        k.keyword LIKE '%action%' 
        AND at.production_year IS NOT NULL
),
ActionTitles AS (
    SELECT 
        rt.title_id,
        rt.title,
        rt.production_year
    FROM 
        RankedTitles rt
    WHERE 
        rt.title_rank <= 3
),
CompanyDetails AS (
    SELECT 
        mc.movie_id,
        c.name AS company_name,
        ct.kind AS company_type
    FROM 
        movie_companies mc
    JOIN 
        company_name c ON mc.company_id = c.id
    JOIN 
        company_type ct ON mc.company_type_id = ct.id
    WHERE 
        c.country_code IS NOT NULL
)
SELECT 
    at.title AS action_movie_title,
    at.production_year,
    COALESCE(cd.company_name, 'N/A') AS production_company,
    COUNT(DISTINCT ci.person_id) AS cast_count,
    STRING_AGG(DISTINCT a.name, ', ') AS cast_members
FROM 
    ActionTitles at
LEFT JOIN 
    complete_cast cc ON at.title_id = cc.movie_id
LEFT JOIN 
    cast_info ci ON cc.subject_id = ci.person_id
LEFT JOIN 
    CompanyDetails cd ON at.title_id = cd.movie_id
LEFT JOIN 
    aka_name a ON ci.person_id = a.person_id
WHERE 
    at.production_year >= 2000
GROUP BY 
    at.title_id, at.title, at.production_year, cd.company_name
HAVING 
    COUNT(DISTINCT ci.person_id) > 2
ORDER BY 
    at.production_year DESC, action_movie_title;
