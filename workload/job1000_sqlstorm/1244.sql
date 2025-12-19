WITH RankedMovies AS (
    SELECT 
        t.id AS movie_id,
        t.title,
        t.production_year,
        ROW_NUMBER() OVER (PARTITION BY t.production_year ORDER BY t.title ASC) AS title_rank
    FROM 
        aka_title t
    WHERE 
        t.production_year IS NOT NULL
),

MovieKeywords AS (
    SELECT 
        mk.movie_id,
        k.keyword,
        COUNT(mk.keyword_id) AS keyword_count
    FROM 
        movie_keyword mk
    JOIN 
        keyword k ON mk.keyword_id = k.id
    GROUP BY 
        mk.movie_id, k.keyword
),

TopMovies AS (
    SELECT 
        rm.movie_id,
        rm.title,
        rm.production_year,
        CASE 
            WHEN mk.keyword_count IS NULL THEN 'No Keywords'
            ELSE 'Has Keywords'
        END AS keyword_status
    FROM 
        RankedMovies rm
    LEFT JOIN 
        MovieKeywords mk ON rm.movie_id = mk.movie_id
    WHERE 
        rm.title_rank = 1
)

SELECT 
    tm.title,
    tm.production_year,
    tm.keyword_status,
    COALESCE(mci.movie_count, 0) AS movie_company_count,
    COALESCE(aka.name, 'Unknown') AS actor_name,
    ARRAY_AGG(DISTINCT k.keyword) AS associated_keywords
FROM 
    TopMovies tm
LEFT JOIN 
    (SELECT 
        movie_id, 
        COUNT(DISTINCT company_id) AS movie_count 
     FROM 
        movie_companies 
     GROUP BY 
        movie_id) mci ON tm.movie_id = mci.movie_id
LEFT JOIN 
    cast_info ci ON ci.movie_id = tm.movie_id
LEFT JOIN 
    aka_name aka ON aka.person_id = ci.person_id
LEFT JOIN 
    movie_keyword mk ON tm.movie_id = mk.movie_id
LEFT JOIN 
    keyword k ON mk.keyword_id = k.id
GROUP BY 
    tm.title, tm.production_year, tm.keyword_status, mci.movie_count, aka.name
ORDER BY 
    tm.production_year DESC, tm.title ASC
LIMIT 50;
