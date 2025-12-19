SELECT 
    a.name AS actor_name,
    t.title AS movie_title,
    ci.nr_order AS role_order,
    ct.kind AS company_type
FROM 
    cast_info ci
JOIN 
    aka_name a ON ci.person_id = a.person_id
JOIN 
    aka_title t ON ci.movie_id = t.movie_id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_type ct ON mc.company_type_id = ct.id
WHERE 
    t.production_year = 2023
ORDER BY 
    a.name, t.title;
