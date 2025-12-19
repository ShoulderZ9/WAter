SELECT 
    t.title, 
    a.name AS actor_name, 
    p.info AS actor_info 
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
    person_info p ON ci.person_id = p.person_id 
WHERE 
    t.production_year = 2023;
