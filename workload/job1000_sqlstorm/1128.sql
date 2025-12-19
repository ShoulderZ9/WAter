
WITH RankedMovies AS (
    SELECT 
        a.id AS movie_id,
        a.title,
        a.production_year,
        COUNT(DISTINCT c.person_id) AS cast_count,
        RANK() OVER (PARTITION BY a.production_year ORDER BY COUNT(DISTINCT c.person_id) DESC) AS rank
    FROM 
        aka_title a
    LEFT JOIN 
        complete_cast cc ON a.id = cc.movie_id
    LEFT JOIN 
        cast_info c ON cc.subject_id = c.id
    WHERE 
        a.production_year IS NOT NULL
    GROUP BY 
        a.id, a.title, a.production_year
),
TopRankedMovies AS (
    SELECT 
        movie_id, title, production_year, cast_count
    FROM 
        RankedMovies
    WHERE 
        rank <= 10
),
DetailedMovieInfo AS (
    SELECT 
        t.title,
        COALESCE(m.info, 'No Info Available') AS info,
        k.keyword AS related_keyword
    FROM 
        TopRankedMovies t
    LEFT JOIN 
        movie_info m ON t.movie_id = m.movie_id
    LEFT JOIN 
        movie_keyword mk ON t.movie_id = mk.movie_id
    LEFT JOIN 
        keyword k ON mk.keyword_id = k.id
)
SELECT 
    d.title,
    d.info,
    STRING_AGG(DISTINCT d.related_keyword, ', ') AS keywords
FROM 
    DetailedMovieInfo d
GROUP BY 
    d.title, d.info
ORDER BY 
    d.title;
