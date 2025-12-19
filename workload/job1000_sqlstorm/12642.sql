
SELECT 
    t.title,
    a.name AS actor_name,
    c.kind AS role_description,
    tc.production_year,
    kc.keyword AS movie_keyword
FROM 
    title t
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name cn ON mc.company_id = cn.id
JOIN 
    movie_keyword mk ON t.id = mk.movie_id
JOIN 
    keyword kc ON mk.keyword_id = kc.id
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    cast_info ci ON cc.subject_id = ci.person_id
JOIN 
    aka_name a ON ci.person_id = a.person_id
JOIN 
    comp_cast_type c ON ci.role_id = c.id
JOIN 
    title tc ON t.id = tc.id
WHERE 
    tc.production_year > 2000
GROUP BY 
    t.title,
    a.name,
    c.kind,
    tc.production_year,
    kc.keyword
ORDER BY 
    tc.production_year DESC, 
    actor_name;
