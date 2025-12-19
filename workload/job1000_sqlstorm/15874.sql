SELECT 
    a.name AS actor_name, 
    t.title AS movie_title, 
    t.production_year
FROM 
    aka_name a
JOIN 
    cast_info ci ON a.person_id = ci.person_id
JOIN 
    title t ON ci.movie_id = t.id
WHERE 
    a.name IS NOT NULL
ORDER BY 
    t.production_year DESC
LIMIT 10;
