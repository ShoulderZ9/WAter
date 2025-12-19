
WITH MovieActorInfo AS (
    SELECT 
        a.person_id, 
        k.keyword AS genre, 
        t.title, 
        t.production_year, 
        ROW_NUMBER() OVER (PARTITION BY a.person_id ORDER BY t.production_year DESC) AS recent_work_rank
    FROM 
        aka_name a
    JOIN 
        cast_info ci ON a.person_id = ci.person_id
    JOIN 
        aka_title t ON ci.movie_id = t.id
    JOIN 
        movie_keyword mk ON t.id = mk.movie_id
    JOIN 
        keyword k ON mk.keyword_id = k.id
    WHERE 
        t.production_year >= 2000
)
SELECT 
    ai.name, 
    COUNT(mai.genre) AS genre_count, 
    MAX(mai.production_year) AS last_year, 
    STRING_AGG(DISTINCT mai.genre, ', ') AS genres_list
FROM 
    aka_name ai
LEFT JOIN 
    MovieActorInfo mai ON ai.person_id = mai.person_id
GROUP BY 
    ai.name
HAVING 
    COUNT(mai.genre) > 3 
    AND MAX(mai.production_year) IS NOT NULL
ORDER BY 
    last_year DESC;
