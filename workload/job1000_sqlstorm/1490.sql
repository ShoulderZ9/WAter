
WITH RankedTitles AS (
    SELECT 
        at.title, 
        at.production_year, 
        ROW_NUMBER() OVER (PARTITION BY at.production_year ORDER BY at.production_year DESC) AS title_rank
    FROM 
        aka_title at
    WHERE 
        at.kind_id IN (SELECT id FROM kind_type WHERE kind IN ('movie', 'tv_series'))
),
ActorNames AS (
    SELECT 
        an.name, 
        an.person_id,
        COUNT(ci.movie_id) AS movie_count
    FROM 
        aka_name an
    JOIN 
        cast_info ci ON an.person_id = ci.person_id
    GROUP BY 
        an.name, an.person_id
    HAVING 
        COUNT(ci.movie_id) > 5
),
CompanyCounts AS (
    SELECT 
        mc.movie_id, 
        COUNT(DISTINCT mc.company_id) AS company_count
    FROM 
        movie_companies mc
    GROUP BY 
        mc.movie_id
)
SELECT 
    rt.title, 
    rt.production_year, 
    an.name AS actor_name, 
    cc.company_count,
    CASE 
        WHEN cc.company_count > 3 THEN 'Multiple Companies'
        ELSE 'Single Company'
    END AS company_status
FROM 
    RankedTitles rt
LEFT JOIN 
    CompanyCounts cc ON rt.production_year = cc.movie_id
JOIN 
    complete_cast c ON rt.production_year = c.movie_id
JOIN 
    ActorNames an ON c.subject_id = an.person_id
WHERE 
    rt.title_rank <= 10
    AND rt.production_year >= 2000
ORDER BY 
    rt.production_year DESC, company_status;
