WITH RankedMovies AS (
    SELECT 
        t.title,
        t.production_year,
        COUNT(DISTINCT c.person_id) AS actor_count,
        ROW_NUMBER() OVER (PARTITION BY t.production_year ORDER BY COUNT(DISTINCT c.person_id) DESC) AS rank
    FROM 
        aka_title t
    JOIN 
        complete_cast cc ON t.id = cc.movie_id
    JOIN 
        cast_info c ON cc.subject_id = c.id
    WHERE 
        t.production_year IS NOT NULL
    GROUP BY 
        t.id, t.title, t.production_year
), MovieDetails AS (
    SELECT 
        t.title,
        t.production_year,
        COALESCE(COUNT(DISTINCT mc.company_id), 0) AS production_company_count
    FROM 
        aka_title t
    LEFT JOIN 
        movie_companies mc ON t.id = mc.movie_id
    GROUP BY 
        t.id, t.title, t.production_year
)
SELECT 
    rm.title,
    rm.production_year,
    rm.actor_count,
    md.production_company_count,
    CASE 
        WHEN rm.actor_count > 0 AND md.production_company_count > 0 THEN 'Active'
        ELSE 'Inactive'
    END AS status
FROM 
    RankedMovies rm
JOIN 
    MovieDetails md ON rm.title = md.title AND rm.production_year = md.production_year
WHERE 
    rm.rank <= 10
ORDER BY 
    rm.production_year DESC, rm.actor_count DESC;
