
WITH RankedMovies AS (
    SELECT
        t.id AS movie_id,
        t.title,
        t.production_year,
        COUNT(ci.id) AS cast_count,
        RANK() OVER (PARTITION BY t.production_year ORDER BY COUNT(ci.id) DESC) AS rank_within_year
    FROM
        aka_title t
        LEFT JOIN cast_info ci ON t.id = ci.movie_id
    WHERE
        t.production_year IS NOT NULL
    GROUP BY
        t.id, t.title, t.production_year
),
TopMovies AS (
    SELECT
        movie_id,
        title,
        production_year
    FROM
        RankedMovies
    WHERE
        rank_within_year <= 5
),
MovieKeywords AS (
    SELECT
        mt.movie_id,
        STRING_AGG(k.keyword, ', ') AS keywords
    FROM
        movie_keyword mt
        JOIN keyword k ON mt.keyword_id = k.id
    GROUP BY
        mt.movie_id
)
SELECT
    tm.title,
    tm.production_year,
    COALESCE(mk.keywords, 'No keywords') AS keywords,
    COUNT(DISTINCT c.id) AS distinct_cast_members,
    (SELECT COUNT(*) FROM movie_companies mc WHERE mc.movie_id = tm.movie_id AND mc.company_type_id IS NOT NULL) AS company_count
FROM
    TopMovies tm
    LEFT JOIN MovieKeywords mk ON tm.movie_id = mk.movie_id
    LEFT JOIN cast_info c ON tm.movie_id = c.movie_id
WHERE
    tm.production_year BETWEEN 2000 AND 2020
GROUP BY
    tm.movie_id, tm.title, tm.production_year, mk.keywords
HAVING
    COUNT(DISTINCT c.id) >= 2
ORDER BY
    tm.production_year DESC, distinct_cast_members DESC;
