SELECT 
    t.title, 
    a.name AS actor_name, 
    c.kind AS cast_type 
FROM 
    title t 
JOIN 
    movie_companies mc ON t.id = mc.movie_id 
JOIN 
    company_name cn ON mc.company_id = cn.id 
JOIN 
    cast_info ci ON t.id = ci.movie_id 
JOIN 
    aka_name a ON ci.person_id = a.person_id 
JOIN 
    comp_cast_type c ON ci.person_role_id = c.id 
WHERE 
    t.production_year = 2020 
ORDER BY 
    t.title;
