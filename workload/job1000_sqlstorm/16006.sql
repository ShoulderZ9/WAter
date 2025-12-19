SELECT 
    a.name AS actor_name,
    t.title AS movie_title,
    c.nr_order AS role_order,
    rt.role AS role_type
FROM 
    cast_info c
JOIN 
    aka_name a ON c.person_id = a.person_id
JOIN 
    aka_title t ON c.movie_id = t.movie_id
JOIN 
    role_type rt ON c.role_id = rt.id
WHERE 
    t.production_year = 2022
ORDER BY 
    a.name, t.title;
