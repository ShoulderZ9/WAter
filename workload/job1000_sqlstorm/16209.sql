SELECT 
    t.title AS movie_title,
    a.name AS actor_name,
    ci.nr_order AS role_order,
    rt.role AS role 
FROM 
    title t
JOIN 
    cast_info ci ON t.id = ci.movie_id
JOIN 
    aka_name a ON ci.person_id = a.person_id
JOIN 
    role_type rt ON ci.role_id = rt.id
WHERE 
    t.production_year = 2020
ORDER BY 
    t.title, ci.nr_order;
