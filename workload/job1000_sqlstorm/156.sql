
WITH RankedMovies AS (
    SELECT 
        m.id AS movie_id,
        m.title,
        m.production_year,
        ROW_NUMBER() OVER (PARTITION BY m.production_year ORDER BY m.production_year DESC) AS year_rank
    FROM 
        aka_title m
    WHERE 
        m.kind_id IN (SELECT id FROM kind_type WHERE kind = 'movie')
),
ActorCounts AS (
    SELECT 
        c.movie_id,
        COUNT(DISTINCT c.person_id) AS actor_count
    FROM 
        cast_info c
    GROUP BY 
        c.movie_id
),
PopularKeywords AS (
    SELECT 
        mk.movie_id,
        k.keyword
    FROM 
        movie_keyword mk
    JOIN 
        keyword k ON mk.keyword_id = k.id
    WHERE 
        k.phonetic_code IS NOT NULL
),
MoviesWithKeywords AS (
    SELECT 
        rm.movie_id,
        rm.title,
        rm.production_year,
        COALESCE(ac.actor_count, 0) AS actor_count,
        STRING_AGG(DISTINCT pk.keyword, ', ') AS keywords,
        rm.year_rank
    FROM 
        RankedMovies rm
    LEFT JOIN 
        ActorCounts ac ON rm.movie_id = ac.movie_id
    LEFT JOIN 
        PopularKeywords pk ON rm.movie_id = pk.movie_id
    GROUP BY 
        rm.movie_id, rm.title, rm.production_year, ac.actor_count, rm.year_rank
)
SELECT 
    mwk.title,
    mwk.production_year,
    mwk.actor_count,
    CASE 
        WHEN mwk.actor_count > 5 THEN 'Featured'
        ELSE 'Less Featured'
    END AS feature_status,
    mwk.keywords
FROM 
    MoviesWithKeywords mwk
WHERE 
    mwk.year_rank <= 5
ORDER BY 
    mwk.production_year DESC, 
    mwk.actor_count DESC;
