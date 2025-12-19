SELECT 
    t.title, 
    a.name AS actor_name, 
    c.kind AS company_type, 
    k.keyword, 
    pi.info 
FROM 
    title t 
JOIN 
    movie_companies mc ON t.id = mc.movie_id 
JOIN 
    company_name cn ON mc.company_id = cn.id 
JOIN 
    comp_cast_type c ON mc.company_type_id = c.id 
JOIN 
    movie_keyword mk ON t.id = mk.movie_id 
JOIN 
    keyword k ON mk.keyword_id = k.id 
JOIN 
    complete_cast cc ON t.id = cc.movie_id 
JOIN 
    cast_info ci ON cc.subject_id = ci.id 
JOIN 
    aka_name a ON ci.person_id = a.person_id 
JOIN 
    person_info pi ON a.person_id = pi.person_id 
WHERE 
    t.production_year > 2000 
ORDER BY 
    t.title, 
    a.name;
