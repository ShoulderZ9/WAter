SELECT 
    t.title, 
    a.name AS actor_name, 
    c.nr_order 
FROM 
    title t 
JOIN 
    cast_info c ON t.id = c.movie_id 
JOIN 
    aka_name a ON c.person_id = a.person_id 
WHERE 
    t.production_year = 2023 
ORDER BY 
    t.title, 
    c.nr_order;
