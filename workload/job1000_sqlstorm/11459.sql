SELECT
    a.name AS aka_name,
    t.title AS movie_title,
    p.info AS person_info,
    c.kind AS comp_cast_type,
    k.keyword AS movie_keyword
FROM 
    aka_name a
JOIN 
    cast_info ci ON a.person_id = ci.person_id
JOIN 
    title t ON ci.movie_id = t.id
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    company_name cn ON cc.subject_id = cn.imdb_id
JOIN 
    movie_info mi ON t.id = mi.movie_id
JOIN 
    role_type rt ON ci.role_id = rt.id
JOIN 
    keyword k ON t.id = k.id
JOIN 
    comp_cast_type c ON ci.person_role_id = c.id
JOIN 
    person_info p ON a.person_id = p.person_id
WHERE 
    t.production_year >= 2000
ORDER BY 
    t.production_year DESC;
