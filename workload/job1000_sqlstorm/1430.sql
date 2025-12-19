WITH RankedMovies AS (
    SELECT 
        at.title, 
        at.production_year, 
        at.kind_id, 
        ROW_NUMBER() OVER (PARTITION BY at.kind_id ORDER BY at.production_year DESC) AS rank
    FROM 
        aka_title at
    WHERE 
        at.production_year IS NOT NULL
),
TopMovies AS (
    SELECT 
        rm.title,
        rm.production_year,
        kt.kind
    FROM 
        RankedMovies rm
    JOIN 
        kind_type kt ON rm.kind_id = kt.id
    WHERE 
        rm.rank <= 5
),
Actors AS (
    SELECT 
        an.name AS actor_name,
        COUNT(DISTINCT ci.movie_id) AS movie_count
    FROM 
        aka_name an
    JOIN 
        cast_info ci ON an.person_id = ci.person_id
    GROUP BY 
        an.name
    HAVING 
        COUNT(DISTINCT ci.movie_id) > 5
)
SELECT 
    tm.title,
    tm.production_year,
    tm.kind,
    a.actor_name,
    a.movie_count
FROM 
    TopMovies tm
LEFT JOIN 
    movie_companies mc ON mc.movie_id = (SELECT id FROM aka_title WHERE title = tm.title LIMIT 1)
LEFT JOIN 
    Actors a ON a.movie_count > 0
WHERE 
    mc.company_type_id IN (SELECT id FROM company_type WHERE kind = 'Production')
ORDER BY 
    tm.production_year DESC, 
    a.movie_count DESC
LIMIT 50;

