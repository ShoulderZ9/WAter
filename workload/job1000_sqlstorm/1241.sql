
WITH RankedMovies AS (
    SELECT 
        mt.id AS movie_id,
        mt.title,
        mt.production_year,
        ROW_NUMBER() OVER (PARTITION BY mt.production_year ORDER BY mt.id) AS ranking
    FROM 
        aka_title mt
    WHERE 
        mt.kind_id = (SELECT id FROM kind_type WHERE kind = 'movie') 
        AND mt.production_year IS NOT NULL
),
ActorMovies AS (
    SELECT 
        ci.movie_id,
        COUNT(DISTINCT ci.person_id) AS actor_count
    FROM 
        cast_info ci
    INNER JOIN 
        RankedMovies rm ON ci.movie_id = rm.movie_id
    GROUP BY 
        ci.movie_id
),
MoviesWithCompany AS (
    SELECT 
        rm.movie_id,
        rm.title,
        am.actor_count,
        STRING_AGG(DISTINCT cn.name, ', ') AS companies
    FROM 
        RankedMovies rm
    LEFT JOIN 
        ActorMovies am ON rm.movie_id = am.movie_id
    LEFT JOIN 
        movie_companies mc ON rm.movie_id = mc.movie_id
    LEFT JOIN 
        company_name cn ON mc.company_id = cn.id
    GROUP BY 
        rm.movie_id, rm.title, am.actor_count
)
SELECT 
    mw.title,
    rm.production_year,
    mw.actor_count,
    CASE 
        WHEN mw.actor_count IS NULL OR mw.actor_count = 0 THEN 'No Actors'
        ELSE 'Actors Present'
    END AS actor_status,
    COALESCE(mw.companies, 'No Companies') AS companies
FROM 
    MoviesWithCompany mw
JOIN 
    RankedMovies rm ON mw.movie_id = rm.movie_id
WHERE 
    mw.actor_count > 5 OR mw.actor_count IS NULL
ORDER BY 
    rm.production_year DESC, mw.actor_count DESC;
