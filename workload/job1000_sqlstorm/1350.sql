
WITH RankedMovies AS (
    SELECT 
        a.id AS movie_id,
        a.title,
        a.production_year,
        ROW_NUMBER() OVER (PARTITION BY a.production_year ORDER BY a.title) AS rn
    FROM aka_title a
    WHERE a.production_year IS NOT NULL
),
TopRatedMovies AS (
    SELECT 
        m.movie_id,
        COUNT(DISTINCT c.person_id) AS actor_count,
        AVG(CASE WHEN r.role IS NOT NULL THEN 1 ELSE 0 END) AS avg_actor_role
    FROM complete_cast cc
    JOIN cast_info c ON cc.subject_id = c.person_id
    JOIN RankedMovies m ON cc.movie_id = m.movie_id
    LEFT JOIN role_type r ON c.role_id = r.id
    GROUP BY m.movie_id
    HAVING COUNT(DISTINCT c.person_id) > 5
)
SELECT 
    m.title,
    m.production_year,
    COALESCE(t.actor_count, 0) AS actor_count,
    COALESCE(t.avg_actor_role, 0) AS avg_actor_role,
    COALESCE(ARRAY_AGG(DISTINCT n.name ORDER BY n.name), ARRAY[]::VARCHAR[]) AS actor_names
FROM RankedMovies m
LEFT JOIN TopRatedMovies t ON m.movie_id = t.movie_id
LEFT JOIN cast_info ci ON m.movie_id = ci.movie_id
LEFT JOIN aka_name n ON ci.person_id = n.person_id
WHERE m.rn <= 10
GROUP BY m.movie_id, m.title, m.production_year, t.actor_count, t.avg_actor_role
ORDER BY m.production_year DESC, m.title;
