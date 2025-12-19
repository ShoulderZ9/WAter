SELECT 
    a.name AS actor_name, 
    t.title AS movie_title, 
    t.production_year
FROM 
    cast_info c
JOIN 
    aka_name a ON c.person_id = a.person_id
JOIN 
    aka_title t ON c.movie_id = t.movie_id
WHERE 
    c.nr_order = 1
ORDER BY 
    t.production_year DESC;
