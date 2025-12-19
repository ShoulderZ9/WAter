WITH RankedTitles AS (
    SELECT 
        t.id AS title_id,
        t.title,
        t.production_year,
        ROW_NUMBER() OVER (PARTITION BY t.production_year ORDER BY t.production_year DESC) AS rn
    FROM 
        title t
    WHERE 
        t.production_year IS NOT NULL
),
MovieCompaniesInfo AS (
    SELECT 
        mc.movie_id,
        c.name AS company_name,
        ct.kind AS company_type,
        COUNT(DISTINCT mi.id) AS movie_info_count
    FROM 
        movie_companies mc
    JOIN 
        company_name c ON mc.company_id = c.id
    JOIN 
        company_type ct ON mc.company_type_id = ct.id
    LEFT JOIN 
        movie_info mi ON mc.movie_id = mi.movie_id
    GROUP BY 
        mc.movie_id, c.name, ct.kind
),
CastRoleCount AS (
    SELECT 
        ci.movie_id,
        ct.kind AS role_type,
        COUNT(ci.person_id) AS role_count
    FROM 
        cast_info ci
    JOIN 
        comp_cast_type ct ON ci.person_role_id = ct.id
    GROUP BY 
        ci.movie_id, ct.kind
)
SELECT 
    rt.title,
    rt.production_year,
    mc.company_name,
    mc.company_type,
    COALESCE(cr.role_count, 0) AS role_count
FROM 
    RankedTitles rt
LEFT JOIN 
    MovieCompaniesInfo mc ON rt.title_id = mc.movie_id
LEFT JOIN 
    CastRoleCount cr ON rt.title_id = cr.movie_id
WHERE 
    rt.rn <= 5
ORDER BY 
    rt.production_year DESC, mc.company_name, rt.title;
