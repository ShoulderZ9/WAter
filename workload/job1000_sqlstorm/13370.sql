SELECT 
    t.title, 
    a.name AS actor_name, 
    ci.nr_order AS actor_order, 
    tc.kind AS company_type, 
    m.title AS movie_title 
FROM 
    aka_name a 
JOIN 
    cast_info ci ON a.person_id = ci.person_id 
JOIN 
    aka_title t ON ci.movie_id = t.id 
JOIN 
    movie_companies mc ON t.id = mc.movie_id 
JOIN 
    company_type tc ON mc.company_type_id = tc.id 
JOIN 
    title m ON mc.movie_id = m.id 
WHERE 
    t.production_year >= 2000 
ORDER BY 
    t.production_year DESC, 
    a.name;
