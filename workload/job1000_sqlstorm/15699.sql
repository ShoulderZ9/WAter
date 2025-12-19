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
    complete_cast cc ON t.id = cc.movie_id 
JOIN 
    aka_name a ON cc.subject_id = a.person_id 
JOIN 
    person_info p ON a.person_id = p.person_id 
WHERE 
    t.production_year > 2000 
ORDER BY 
    t.title;
