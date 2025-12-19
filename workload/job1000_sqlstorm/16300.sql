SELECT 
    t.title AS movie_title,
    a.name AS actor_name,
    c.note AS character_name
FROM 
    aka_title t
JOIN 
    cast_info c ON t.id = c.movie_id
JOIN 
    aka_name a ON c.person_id = a.person_id
WHERE 
    t.production_year = 2020
ORDER BY 
    t.title, a.name;
