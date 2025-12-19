
SELECT 
    t.title AS movie_title,
    a.name AS person_name,
    r.role AS role_name,
    ct.kind AS company_type,
    y.keyword AS movie_keyword
FROM 
    title t
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    cast_info ci ON cc.subject_id = ci.person_id
JOIN 
    aka_name a ON ci.person_id = a.person_id
JOIN 
    role_type r ON ci.role_id = r.id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_type ct ON mc.company_type_id = ct.id
JOIN 
    company_name cn ON mc.company_id = cn.id
JOIN 
    movie_keyword mk ON t.id = mk.movie_id
JOIN 
    keyword y ON mk.keyword_id = y.id
GROUP BY 
    t.title, a.name, r.role, ct.kind, y.keyword
ORDER BY 
    t.title, a.name;
