WITH RankedMovies AS (
    SELECT
        t.id AS movie_id,
        t.title AS movie_title,
        t.production_year,
        ROW_NUMBER() OVER (PARTITION BY t.production_year ORDER BY t.id) AS rank_by_year
    FROM
        aka_title t
    JOIN
        movie_info mi ON t.id = mi.movie_id
    WHERE
        mi.info_type_id = (SELECT id FROM info_type WHERE info = 'Genre')
        AND mi.info IS NOT NULL
),
ActorMovies AS (
    SELECT
        ka.name AS actor_name,
        km.movie_id,
        COUNT(km.movie_id) OVER (PARTITION BY ka.name) AS movie_count
    FROM
        cast_info ci
    JOIN
        aka_name ka ON ci.person_id = ka.person_id
    JOIN
        RankedMovies km ON ci.movie_id = km.movie_id
    WHERE
        ci.role_id = (SELECT id FROM role_type WHERE role = 'actor')
)
SELECT
    am.actor_name,
    STRING_AGG(DISTINCT rm.movie_title, ', ') AS movie_titles,
    AVG(am.movie_count) AS average_movies
FROM
    ActorMovies am
JOIN
    RankedMovies rm ON am.movie_id = rm.movie_id
WHERE
    am.movie_count > 1
GROUP BY
    am.actor_name
HAVING
    COUNT(DISTINCT rm.production_year) > 1
ORDER BY
    average_movies DESC
LIMIT 10;
