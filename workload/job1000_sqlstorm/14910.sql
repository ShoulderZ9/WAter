SELECT 
    a.name AS aka_name,
    t.title AS movie_title,
    p.info AS person_info,
    c.kind AS comp_cast_type,
    k.keyword AS movie_keyword,
    r.role AS role_type
FROM 
    aka_name a
JOIN 
    cast_info ci ON a.person_id = ci.person_id
JOIN 
    title t ON ci.movie_id = t.id
JOIN 
    person_info p ON ci.person_id = p.person_id
JOIN 
    complete_cast cc ON cc.movie_id = t.id
JOIN 
    company_type ct ON ct.id = cc.subject_id
JOIN 
    comp_cast_type c ON c.id = ci.person_role_id
JOIN 
    movie_keyword mk ON mk.movie_id = t.id
JOIN 
    keyword k ON mk.keyword_id = k.id
JOIN 
    role_type r ON r.id = ci.role_id
WHERE 
    t.production_year = 2020
ORDER BY 
    a.name, t.title;
