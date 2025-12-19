SELECT 
    t.id AS movie_id,
    t.title,
    a.name AS actor_name,
    p.info AS person_info,
    k.keyword AS movie_keyword,
    c.name AS company_name,
    ct.kind AS company_type,
    r.role AS role_type
FROM 
    title t
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name c ON mc.company_id = c.id
JOIN 
    company_type ct ON mc.company_type_id = ct.id
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    cast_info ci ON cc.subject_id = ci.person_id
JOIN 
    aka_name a ON ci.person_id = a.person_id
JOIN 
    person_info p ON a.person_id = p.person_id
JOIN 
    movie_keyword mk ON t.id = mk.movie_id
JOIN 
    keyword k ON mk.keyword_id = k.id
JOIN 
    role_type r ON ci.role_id = r.id
WHERE 
    r.role IS NOT NULL
ORDER BY 
    t.production_year DESC, 
    t.title ASC;