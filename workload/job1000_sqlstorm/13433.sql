SELECT 
    a.name AS actor_name,
    t.title AS movie_title,
    r.role AS role_type,
    c.kind AS comp_cast_type,
    k.keyword AS movie_keyword,
    p.info AS person_info
FROM 
    aka_name a
JOIN 
    cast_info ci ON a.person_id = ci.person_id
JOIN 
    title t ON ci.movie_id = t.id
JOIN 
    role_type r ON ci.role_id = r.id
JOIN 
    complete_cast cc ON ci.movie_id = cc.movie_id AND ci.person_id = cc.subject_id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    comp_cast_type c ON mc.company_type_id = c.id
JOIN 
    movie_keyword mk ON t.id = mk.movie_id
JOIN 
    keyword k ON mk.keyword_id = k.id
JOIN 
    person_info p ON a.person_id = p.person_id
WHERE 
    t.production_year > 2000
ORDER BY 
    a.name, t.production_year;
