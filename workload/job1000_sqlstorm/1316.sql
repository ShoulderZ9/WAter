WITH RankedMovies AS (
    SELECT 
        t.id AS movie_id,
        t.title,
        t.production_year,
        ROW_NUMBER() OVER (PARTITION BY t.production_year ORDER BY t.title) AS title_rank
    FROM 
        aka_title t
    WHERE 
        t.production_year IS NOT NULL
),
MovieCast AS (
    SELECT 
        mc.movie_id,
        c.person_id,
        a.name AS actor_name,
        ROW_NUMBER() OVER (PARTITION BY mc.movie_id ORDER BY c.nr_order) AS actor_order
    FROM 
        complete_cast mc
    JOIN 
        cast_info c ON mc.movie_id = c.movie_id
    JOIN 
        aka_name a ON c.person_id = a.person_id
    WHERE 
        a.name IS NOT NULL
),
MovieKeywords AS (
    SELECT 
        mk.movie_id,
        k.keyword,
        COUNT(*) AS keyword_count
    FROM 
        movie_keyword mk
    JOIN 
        keyword k ON mk.keyword_id = k.id
    GROUP BY 
        mk.movie_id, k.keyword
),
CombinedData AS (
    SELECT 
        rm.movie_id,
        rm.title,
        rm.production_year,
        mc.actor_name,
        mk.keyword,
        COALESCE(mk.keyword_count, 0) AS total_keywords
    FROM 
        RankedMovies rm
    LEFT JOIN 
        MovieCast mc ON rm.movie_id = mc.movie_id
    LEFT JOIN 
        MovieKeywords mk ON rm.movie_id = mk.movie_id
    WHERE 
        rm.title_rank <= 3
)
SELECT 
    movie_id,
    title,
    production_year,
    STRING_AGG(actor_name, ', ') AS actors,
    STRING_AGG(DISTINCT keyword, ', ') AS keywords,
    MAX(total_keywords) AS strongest_keyword_association
FROM 
    CombinedData
GROUP BY 
    movie_id, title, production_year
ORDER BY 
    production_year DESC, title;
