SELECT 
    a.name AS aka_name,
    t.title AS movie_title,
    p.info AS person_info,
    k.keyword AS movie_keyword,
    c.kind AS comp_cast_type
FROM 
    aka_name a
JOIN 
    cast_info ci ON a.person_id = ci.person_id
JOIN 
    title t ON ci.movie_id = t.id
JOIN 
    movie_keyword mk ON t.id = mk.movie_id
JOIN 
    keyword k ON mk.keyword_id = k.id
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    company_name cn ON cc.subject_id = cn.imdb_id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    comp_cast_type c ON c.id = ci.role_id
JOIN 
    person_info p ON a.person_id = p.person_id
WHERE 
    t.production_year >= 2000
ORDER BY 
    t.production_year DESC;
