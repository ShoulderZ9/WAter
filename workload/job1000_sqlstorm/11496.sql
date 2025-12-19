SELECT 
    a.name AS aka_name,
    t.title AS movie_title,
    p.info AS person_info,
    r.role AS person_role,
    c.kind AS comp_cast_type
FROM 
    aka_name a
JOIN 
    cast_info ci ON a.person_id = ci.person_id
JOIN 
    title t ON ci.movie_id = t.id
JOIN 
    person_info p ON a.person_id = p.person_id
JOIN 
    role_type r ON ci.role_id = r.id
JOIN 
    complete_cast cc ON ci.movie_id = cc.movie_id AND ci.person_id = cc.subject_id
JOIN 
    movie_companies mc ON cc.movie_id = mc.movie_id
JOIN 
    comp_cast_type c ON mc.company_type_id = c.id
WHERE 
    t.production_year >= 2000
ORDER BY 
    t.production_year DESC, a.name;
