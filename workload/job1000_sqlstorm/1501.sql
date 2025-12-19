WITH RankedMovies AS (
    SELECT
        at.id AS title_id,
        at.title,
        at.production_year,
        RANK() OVER (PARTITION BY at.production_year ORDER BY COUNT(ci.id) DESC) AS movie_rank,
        COALESCE(SUM(CASE WHEN ci.person_role_id IS NOT NULL THEN 1 ELSE 0 END), 0) AS total_roles
    FROM
        aka_title at
    LEFT JOIN
        complete_cast cc ON at.id = cc.movie_id
    LEFT JOIN
        cast_info ci ON cc.subject_id = ci.id
    GROUP BY
        at.id, at.title, at.production_year
),
TitleCounts AS (
    SELECT
        production_year,
        COUNT(*) AS total_movies
    FROM
        RankedMovies
    GROUP BY
        production_year
),
FilteredMovies AS (
    SELECT
        rm.title_id,
        rm.title,
        rm.production_year,
        rm.movie_rank,
        rm.total_roles,
        tc.total_movies
    FROM
        RankedMovies rm
    JOIN
        TitleCounts tc ON rm.production_year = tc.production_year
    WHERE
        rm.movie_rank <= 5
        AND tc.total_movies > 0
)
SELECT
    f.title_id,
    f.title,
    f.production_year,
    f.movie_rank,
    f.total_roles,
    f.total_movies,
    CONCAT(f.title, ' has ', f.total_roles, ' roles in ', f.total_movies, ' movies in the year ', f.production_year) AS role_summary
FROM
    FilteredMovies f
ORDER BY
    f.production_year DESC, f.movie_rank;
