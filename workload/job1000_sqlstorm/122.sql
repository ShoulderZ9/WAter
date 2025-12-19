WITH RankedMovies AS (
    SELECT 
        t.id AS movie_id,
        t.title,
        t.production_year,
        COUNT(c.id) AS cast_count,
        ROW_NUMBER() OVER (PARTITION BY t.production_year ORDER BY COUNT(c.id) DESC) AS rank
    FROM 
        aka_title t
    LEFT JOIN 
        cast_info c ON t.id = c.movie_id
    WHERE 
        t.production_year IS NOT NULL
    GROUP BY 
        t.id, t.title, t.production_year
),
PopularMovies AS (
    SELECT 
        rm.movie_id,
        rm.title,
        rm.production_year,
        rm.cast_count
    FROM 
        RankedMovies rm
    WHERE 
        rm.rank <= 5
),
MovieCompanies AS (
    SELECT 
        m.movie_id,
        COUNT(mc.id) as company_count
    FROM 
        PopularMovies m
    LEFT JOIN 
        movie_companies mc ON m.movie_id = mc.movie_id
    GROUP BY 
        m.movie_id
)
SELECT 
    pm.title,
    pm.production_year,
    COALESCE(mc.company_count, 0) AS associated_companies,
    pm.cast_count || ' cast members' AS cast_info
FROM 
    PopularMovies pm
LEFT JOIN 
    MovieCompanies mc ON pm.movie_id = mc.movie_id
WHERE 
    pm.cast_count > 10
ORDER BY 
    pm.production_year DESC, pm.cast_count DESC;
