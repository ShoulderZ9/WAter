SELECT 
    t.title, 
    a.name AS actor_name, 
    p.info AS actor_info
FROM 
    title t
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name c ON mc.company_id = c.id
JOIN 
    cast_info ci ON t.id = ci.movie_id
JOIN 
    aka_name a ON ci.person_id = a.person_id
JOIN 
    person_info p ON a.person_id = p.person_id
WHERE 
    c.country_code = 'US'
ORDER BY 
    t.production_year DESC;
