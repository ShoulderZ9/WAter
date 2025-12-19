
WITH MovieStats AS (
    SELECT 
        t.id AS movie_id,
        t.title,
        t.production_year,
        COUNT(DISTINCT c.person_id) AS actor_count,
        COUNT(DISTINCT k.keyword) AS keyword_count,
        AVG(CASE WHEN ci.note IS NOT NULL THEN 1 ELSE 0 END) * 100 AS actor_with_notes_percentage
    FROM aka_title t
    JOIN complete_cast cc ON t.id = cc.movie_id
    JOIN cast_info c ON cc.subject_id = c.id
    LEFT JOIN movie_keyword mk ON t.id = mk.movie_id
    LEFT JOIN keyword k ON mk.keyword_id = k.id
    LEFT JOIN cast_info ci ON c.person_id = ci.person_id AND ci.movie_id = t.id
    GROUP BY t.id, t.title, t.production_year
),

RankedMovies AS (
    SELECT 
        movie_id,
        title,
        production_year,
        actor_count,
        keyword_count,
        actor_with_notes_percentage,
        RANK() OVER (PARTITION BY production_year ORDER BY actor_count DESC, keyword_count DESC) AS rank_within_year
    FROM MovieStats
)

SELECT 
    rm.movie_id,
    rm.title,
    rm.production_year,
    rm.actor_count,
    rm.keyword_count,
    rm.actor_with_notes_percentage
FROM RankedMovies rm
WHERE (rm.rank_within_year <= 10 AND rm.keyword_count > 5)
   OR (rm.actor_count = 0 AND rm.actor_with_notes_percentage IS NOT NULL)
ORDER BY rm.production_year DESC, rm.rank_within_year;
