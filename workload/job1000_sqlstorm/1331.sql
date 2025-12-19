WITH MovieDetails AS (
    SELECT
        t.id AS movie_id,
        t.title,
        t.production_year,
        ki.kind AS movie_kind,
        COALESCE(COUNT(DISTINCT c.id), 0) AS cast_count
    FROM
        aka_title t
    LEFT JOIN
        cast_info c ON t.id = c.movie_id
    INNER JOIN
        kind_type ki ON t.kind_id = ki.id
    GROUP BY
        t.id, t.title, t.production_year, ki.kind
),
TopMovies AS (
    SELECT
        md.movie_id,
        md.title,
        md.production_year,
        md.movie_kind,
        md.cast_count,
        RANK() OVER (PARTITION BY md.movie_kind ORDER BY md.cast_count DESC) AS rank
    FROM
        MovieDetails md
)
SELECT
    tm.movie_id,
    tm.title,
    tm.production_year,
    tm.movie_kind,
    tm.cast_count,
    STRING_AGG(DISTINCT a.name, ', ') AS actors
FROM
    TopMovies tm
LEFT JOIN
    cast_info ci ON tm.movie_id = ci.movie_id
LEFT JOIN
    aka_name a ON ci.person_id = a.person_id
WHERE
    tm.rank <= 5
GROUP BY
    tm.movie_id, tm.title, tm.production_year, tm.movie_kind, tm.cast_count
ORDER BY
    tm.movie_kind, tm.cast_count DESC;
