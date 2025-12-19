SELECT 
    a.name AS aka_name,
    t.title AS movie_title,
    c.nr_order,
    r.role
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    title t ON c.movie_id = t.id
JOIN 
    role_type r ON c.role_id = r.id
WHERE 
    t.production_year = 2020
ORDER BY 
    c.nr_order;
