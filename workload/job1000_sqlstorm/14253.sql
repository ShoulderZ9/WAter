SELECT 
    t.title AS movie_title,
    a.name AS actor_name,
    ct.kind AS role_type,
    c.name AS company_name,
    mi.info AS movie_info
FROM 
    title t
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    cast_info ci ON cc.subject_id = ci.person_id
JOIN 
    aka_name a ON ci.person_id = a.person_id
JOIN 
    company_name c ON c.id = (SELECT company_id FROM movie_companies mc WHERE mc.movie_id = t.id LIMIT 1)
JOIN 
    company_type ct ON ct.id = (SELECT company_type_id FROM movie_companies mc WHERE mc.movie_id = t.id LIMIT 1)
JOIN 
    movie_info mi ON mi.movie_id = t.id
WHERE 
    t.production_year = 2021
ORDER BY 
    t.title, a.name;
