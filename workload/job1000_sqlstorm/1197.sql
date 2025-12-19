
WITH RankedMovies AS (
    SELECT 
        m.id AS movie_id,
        m.title,
        m.production_year,
        ROW_NUMBER() OVER (PARTITION BY m.production_year ORDER BY m.title) AS ranked_title,
        COUNT(DISTINCT c.person_id) AS cast_count
    FROM 
        aka_title m
    LEFT JOIN 
        complete_cast cc ON m.id = cc.movie_id
    LEFT JOIN 
        cast_info c ON cc.subject_id = c.id
    WHERE 
        m.production_year IS NOT NULL
    GROUP BY 
        m.id, m.title, m.production_year
),
ActorDetails AS (
    SELECT 
        ci.person_id AS person_id,
        ak.name AS actor_name,
        COUNT(DISTINCT mk.keyword_id) AS keyword_count
    FROM 
        aka_name ak
    JOIN 
        cast_info ci ON ak.person_id = ci.person_id
    LEFT JOIN 
        movie_keyword mk ON ci.movie_id = mk.movie_id
    WHERE 
        ak.name IS NOT NULL
    GROUP BY 
        ci.person_id, ak.name
),
CompanyMovieStats AS (
    SELECT 
        mc.movie_id,
        STRING_AGG(DISTINCT cn.name, ', ') AS companies,
        COUNT(DISTINCT mc.company_id) AS company_count
    FROM 
        movie_companies mc
    JOIN 
        company_name cn ON mc.company_id = cn.id
    GROUP BY 
        mc.movie_id
)
SELECT 
    rm.movie_id,
    rm.title,
    rm.production_year,
    rm.ranked_title,
    rm.cast_count,
    ad.actor_name,
    ad.keyword_count,
    cms.companies,
    cms.company_count
FROM 
    RankedMovies rm
LEFT JOIN 
    ActorDetails ad ON rm.movie_id = ad.person_id
LEFT JOIN 
    CompanyMovieStats cms ON rm.movie_id = cms.movie_id
WHERE 
    rm.cast_count > 5
ORDER BY 
    rm.production_year DESC, rm.title ASC
LIMIT 50;
