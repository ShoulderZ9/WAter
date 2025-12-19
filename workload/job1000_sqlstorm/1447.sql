WITH RankedMovies AS (
    SELECT
        mt.title AS movie_title,
        mt.production_year,
        COUNT(DISTINCT ci.person_id) AS cast_count,
        DENSE_RANK() OVER (PARTITION BY mt.production_year ORDER BY COUNT(DISTINCT ci.person_id) DESC) AS year_rank
    FROM
        aka_title mt
    LEFT JOIN
        cast_info ci ON mt.id = ci.movie_id
    GROUP BY
        mt.id, mt.title, mt.production_year
),
TopMovies AS (
    SELECT
        movie_title,
        production_year,
        cast_count
    FROM
        RankedMovies
    WHERE
        year_rank <= 5
),
MaxCastPerYear AS (
    SELECT
        production_year,
        MAX(cast_count) AS max_cast
    FROM
        TopMovies
    GROUP BY
        production_year
)
SELECT
    tm.movie_title,
    tm.production_year,
    tm.cast_count,
    COALESCE(mcp.max_cast, 0) AS max_cast_count
FROM
    TopMovies tm
LEFT JOIN
    MaxCastPerYear mcp ON tm.production_year = mcp.production_year
WHERE
    tm.cast_count >= (SELECT AVG(cast_count) FROM TopMovies) OR tm.cast_count IS NULL
ORDER BY
    tm.production_year DESC, tm.cast_count DESC;
