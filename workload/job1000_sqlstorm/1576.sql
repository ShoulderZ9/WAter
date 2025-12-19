WITH TopMovies AS (
    SELECT
        t.id AS movie_id,
        t.title,
        t.production_year,
        COUNT(DISTINCT c.person_id) AS actor_count
    FROM
        aka_title t
    LEFT JOIN
        cast_info c ON t.id = c.movie_id
    WHERE
        t.production_year >= 2000
    GROUP BY
        t.id, t.title, t.production_year
    HAVING
        COUNT(DISTINCT c.person_id) > 5
), 

TopRatedMovies AS (
    SELECT
        m.movie_id,
        AVG(CASE WHEN pi.info_type_id = (SELECT id FROM info_type WHERE info = 'rating') THEN CAST(pi.info AS FLOAT) END) AS avg_rating
    FROM
        movie_info pi
    INNER JOIN
        complete_cast m ON pi.movie_id = m.movie_id
    GROUP BY
        m.movie_id
    HAVING
        AVG(CASE WHEN pi.info_type_id = (SELECT id FROM info_type WHERE info = 'rating') THEN CAST(pi.info AS FLOAT) END) > 7
)

SELECT 
    tm.title,
    tm.production_year,
    tm.actor_count,
    tr.avg_rating
FROM 
    TopMovies tm
JOIN 
    TopRatedMovies tr ON tm.movie_id = tr.movie_id
LEFT JOIN 
    (SELECT 
         mc.movie_id,
         STRING_AGG(cn.name, ', ') AS companies
     FROM 
         movie_companies mc
     JOIN 
         company_name cn ON mc.company_id = cn.id
     GROUP BY 
         mc.movie_id) company_info ON tm.movie_id = company_info.movie_id
ORDER BY 
    avg_rating DESC, 
    actor_count DESC
LIMIT 10;
