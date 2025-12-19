SELECT 
    t.title,
    a.name AS actor_name,
    ci.note AS role_note
FROM 
    title t
JOIN 
    movie_companies mc ON mc.movie_id = t.id
JOIN 
    company_name c ON c.id = mc.company_id
JOIN 
    complete_cast cc ON cc.movie_id = t.id
JOIN 
    cast_info ci ON ci.movie_id = cc.movie_id AND ci.person_id = cc.subject_id
JOIN 
    aka_name a ON a.person_id = ci.person_id
WHERE 
    t.production_year >= 2000
ORDER BY 
    t.production_year DESC;
