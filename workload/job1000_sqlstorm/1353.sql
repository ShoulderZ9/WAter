WITH RankedMovies AS (
    SELECT 
        a.title, 
        a.production_year, 
        a.id AS movie_id, 
        COUNT(DISTINCT c.person_id) AS actor_count,
        ROW_NUMBER() OVER (PARTITION BY a.production_year ORDER BY COUNT(DISTINCT c.person_id) DESC) AS rank
    FROM 
        aka_title a
    LEFT JOIN 
        cast_info c ON a.id = c.movie_id
    WHERE 
        a.production_year >= 2000
    GROUP BY 
        a.title, a.production_year, a.id
),
TopMovies AS (
    SELECT 
        movie_id,
        title,
        production_year,
        actor_count
    FROM 
        RankedMovies
    WHERE 
        rank <= 5
),
MovieKeywords AS (
    SELECT
        m.movie_id,
        STRING_AGG(k.keyword, ', ') AS keywords
    FROM 
        movie_keyword m
    JOIN 
        keyword k ON m.keyword_id = k.id
    GROUP BY 
        m.movie_id
)
SELECT 
    tm.title,
    tm.production_year,
    COALESCE(mk.keywords, 'No Keywords') AS keyword_list,
    COUNT(DISTINCT ci.person_id) AS total_actors,
    SUM(CASE WHEN ci.note IS NOT NULL THEN 1 ELSE 0 END) AS noted_actors,
    AVG(COALESCE(p.info_count, 0)) AS avg_person_info_count
FROM 
    TopMovies tm
LEFT JOIN 
    cast_info ci ON tm.movie_id = ci.movie_id
LEFT JOIN 
    MovieKeywords mk ON tm.movie_id = mk.movie_id
LEFT JOIN (
    SELECT 
        person_id,
        COUNT(*) AS info_count
    FROM 
        person_info
    GROUP BY 
        person_id
) p ON ci.person_id = p.person_id
GROUP BY 
    tm.title, tm.production_year, mk.keywords
ORDER BY 
    tm.production_year DESC, total_actors DESC;
