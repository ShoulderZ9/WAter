WITH RankedMovies AS (
    SELECT 
        a.id AS movie_id,
        a.title,
        a.production_year,
        ROW_NUMBER() OVER (PARTITION BY a.production_year ORDER BY a.production_year DESC) AS year_rank
    FROM aka_title a
    WHERE a.production_year IS NOT NULL
),
ActorCounts AS (
    SELECT 
        c.movie_id,
        COUNT(DISTINCT c.person_id) AS actor_count
    FROM cast_info c
    GROUP BY c.movie_id
),
MovieDetails AS (
    SELECT 
        m.movie_id,
        m.title,
        m.production_year,
        COALESCE(ac.actor_count, 0) AS actor_count,
        CASE 
            WHEN m.production_year < 2000 THEN 'Classic'
            WHEN m.production_year BETWEEN 2000 AND 2010 THEN 'Modern'
            ELSE 'Recent'
        END AS era
    FROM RankedMovies m
    LEFT JOIN ActorCounts ac ON m.movie_id = ac.movie_id
),
TopMovies AS (
    SELECT 
        md.* 
    FROM MovieDetails md
    WHERE md.actor_count > 3 AND md.era = 'Modern'
    ORDER BY md.actor_count DESC
    LIMIT 10
)
SELECT 
    tm.title,
    tm.production_year,
    tm.actor_count,
    n.name AS leading_actor,
    (SELECT COUNT(*) 
     FROM movie_keyword mk
     WHERE mk.movie_id = tm.movie_id) AS keyword_count,
    (SELECT STRING_AGG(DISTINCT kw.keyword, ', ')
     FROM movie_keyword mk
     JOIN keyword kw ON mk.keyword_id = kw.id
     WHERE mk.movie_id = tm.movie_id) AS keywords
FROM TopMovies tm
LEFT JOIN cast_info ci ON tm.movie_id = ci.movie_id
LEFT JOIN aka_name n ON ci.person_id = n.person_id
WHERE n.name IS NOT NULL
GROUP BY tm.movie_id, tm.title, tm.production_year, tm.actor_count, n.name
HAVING COUNT(DISTINCT ci.person_id) > 1
ORDER BY tm.actor_count DESC;
