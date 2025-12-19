
WITH RankedMovies AS (
    SELECT 
        t.id AS movie_id,
        t.title,
        t.production_year,
        ROW_NUMBER() OVER (PARTITION BY t.production_year ORDER BY t.id) AS year_rank,
        COUNT(cm.company_id) OVER (PARTITION BY t.id) AS company_count
    FROM 
        aka_title t
    LEFT JOIN 
        movie_companies cm ON t.id = cm.movie_id
    WHERE 
        t.production_year IS NOT NULL
),
FilteredMovies AS (
    SELECT 
        rm.movie_id,
        rm.title,
        rm.production_year,
        rm.year_rank,
        rm.company_count
    FROM 
        RankedMovies rm
    WHERE 
        rm.year_rank <= 5
)

SELECT 
    fm.title AS movie_title,
    fm.production_year,
    COALESCE(acc.name, 'Unknown Actor') AS actor_name,
    CASE 
        WHEN fm.company_count > 1 THEN 'Multiple Companies'
        ELSE 'Single Company'
    END AS company_status,
    COUNT(DISTINCT mkm.keyword_id) AS keyword_count
FROM 
    FilteredMovies fm
LEFT JOIN 
    cast_info ci ON fm.movie_id = ci.movie_id
LEFT JOIN 
    aka_name acc ON ci.person_id = acc.person_id
LEFT JOIN 
    movie_keyword mkm ON fm.movie_id = mkm.movie_id
WHERE 
    fm.company_count IS NOT NULL
GROUP BY 
    fm.movie_id, fm.title, fm.production_year, acc.name, fm.company_count
HAVING 
    COUNT(DISTINCT mkm.keyword_id) > 2
ORDER BY 
    fm.production_year DESC, fm.title;
