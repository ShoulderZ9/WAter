
WITH RankedTitles AS (
    SELECT 
        t.id AS title_id,
        t.title,
        t.production_year,
        ROW_NUMBER() OVER (PARTITION BY t.production_year ORDER BY t.id) AS title_rank
    FROM 
        aka_title t
    WHERE 
        t.production_year IS NOT NULL
),
ActorMovies AS (
    SELECT 
        c.movie_id,
        COUNT(*) AS actor_count
    FROM 
        cast_info c
    GROUP BY 
        c.movie_id
),
CompanyMovies AS (
    SELECT 
        mc.movie_id,
        COUNT(DISTINCT cn.id) AS company_count
    FROM 
        movie_companies mc
    JOIN 
        company_name cn ON mc.company_id = cn.id
    WHERE 
        cn.country_code IS NOT NULL
    GROUP BY 
        mc.movie_id
)
SELECT 
    rt.title,
    rt.production_year,
    am.actor_count,
    cm.company_count,
    (CASE 
        WHEN am.actor_count IS NULL THEN 'No Actors'
        ELSE CAST(am.actor_count AS VARCHAR) || ' Actors' 
    END) AS actor_info,
    (CASE 
        WHEN cm.company_count IS NULL THEN 'No Companies'
        ELSE CAST(cm.company_count AS VARCHAR) || ' Companies' 
    END) AS company_info
FROM 
    RankedTitles rt
LEFT JOIN 
    ActorMovies am ON rt.title_id = am.movie_id
LEFT JOIN 
    CompanyMovies cm ON rt.title_id = cm.movie_id
WHERE 
    rt.title_rank <= 5
ORDER BY 
    rt.production_year DESC, rt.title;
