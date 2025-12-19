
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
DirectorInfo AS (
    SELECT 
        c.movie_id,
        a.name AS director_name,
        COUNT(DISTINCT a.person_id) AS director_count
    FROM 
        cast_info c
    JOIN 
        aka_name a ON c.person_id = a.person_id
    WHERE 
        c.person_role_id = (SELECT id FROM role_type WHERE role = 'director')
    GROUP BY 
        c.movie_id, a.name
),
MovieGenres AS (
    SELECT 
        m.movie_id,
        STRING_AGG(k.keyword, ', ') AS genres
    FROM 
        movie_keyword mk
    JOIN 
        keyword k ON mk.keyword_id = k.id
    JOIN 
        aka_title m ON mk.movie_id = m.id
    GROUP BY 
        m.movie_id
)
SELECT 
    rm.title,
    rm.production_year,
    di.director_name,
    di.director_count,
    mg.genres,
    COALESCE(AVG(CAST(mi.info AS FLOAT)), 0) AS avg_rating
FROM 
    RankedMovies rm
LEFT JOIN 
    DirectorInfo di ON rm.movie_id = di.movie_id
LEFT JOIN 
    MovieGenres mg ON rm.movie_id = mg.movie_id
LEFT JOIN 
    movie_info mi ON rm.movie_id = mi.movie_id AND mi.info_type_id = (SELECT id FROM info_type WHERE info = 'rating')
WHERE 
    rm.year_rank <= 10
GROUP BY 
    rm.movie_id, rm.title, rm.production_year, di.director_name, di.director_count, mg.genres
ORDER BY 
    rm.production_year DESC, avg_rating DESC;
