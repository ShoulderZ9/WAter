SELECT 
    t.title, 
    a.name AS actor_name, 
    r.role AS role_type,
    c.name AS company_name,
    m.info AS movie_info
FROM 
    title t
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name c ON mc.company_id = c.id
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    cast_info ca ON cc.subject_id = ca.id
JOIN 
    aka_name a ON ca.person_id = a.person_id
JOIN 
    role_type r ON ca.role_id = r.id
JOIN 
    movie_info m ON t.id = m.movie_id
WHERE 
    t.production_year >= 2000
ORDER BY 
    t.production_year DESC, 
    a.name;
