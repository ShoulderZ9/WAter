SELECT 
    t.title, 
    a.name AS actor_name, 
    c.kind AS company_type 
FROM 
    title t 
JOIN 
    movie_companies mc ON t.id = mc.movie_id 
JOIN 
    company_type c ON mc.company_type_id = c.id 
JOIN 
    cast_info ci ON t.id = ci.movie_id 
JOIN 
    aka_name a ON ci.person_id = a.person_id 
WHERE 
    t.production_year >= 2020 
ORDER BY 
    t.production_year DESC, 
    a.name;
