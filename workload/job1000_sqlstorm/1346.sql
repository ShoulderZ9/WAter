WITH RankedMovies AS (
    SELECT 
        t.id AS movie_id,
        t.title,
        t.production_year,
        ROW_NUMBER() OVER (PARTITION BY t.production_year ORDER BY t.production_year DESC) AS year_rank
    FROM 
        aka_title t
    WHERE 
        t.production_year IS NOT NULL
),
CastCount AS (
    SELECT 
        ci.movie_id,
        COUNT(*) AS cast_count
    FROM 
        cast_info ci
    GROUP BY 
        ci.movie_id
),
GenreCount AS (
    SELECT 
        mi.movie_id,
        COUNT(DISTINCT k.keyword) AS genre_count
    FROM 
        movie_keyword mk
    JOIN 
        keyword k ON mk.keyword_id = k.id
    JOIN 
        movie_info mi ON mk.movie_id = mi.movie_id
    WHERE 
        mi.info_type_id = (SELECT id FROM info_type WHERE info = 'genre')
    GROUP BY 
        mi.movie_id
)
SELECT 
    rm.movie_id,
    rm.title,
    rm.production_year,
    COALESCE(cc.cast_count, 0) AS total_cast,
    COALESCE(gc.genre_count, 0) AS total_genres,
    CASE 
        WHEN cc.cast_count IS NULL THEN 'No Cast'
        WHEN gc.genre_count IS NULL THEN 'No Genre'
        ELSE 'Available'
    END AS availability_status
FROM 
    RankedMovies rm
LEFT JOIN 
    CastCount cc ON rm.movie_id = cc.movie_id
LEFT JOIN 
    GenreCount gc ON rm.movie_id = gc.movie_id
WHERE 
    rm.year_rank <= 10
ORDER BY 
    rm.production_year DESC,
    total_cast DESC;
