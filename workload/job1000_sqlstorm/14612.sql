SELECT 
    t.title, 
    a.name AS actor_name, 
    p.info AS person_info, 
    k.keyword AS movie_keyword, 
    c.kind AS company_type
FROM 
    title t
JOIN 
    movie_link ml ON t.id = ml.movie_id
JOIN 
    title linked_t ON ml.linked_movie_id = linked_t.id
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
    person_info p ON a.person_id = p.person_id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_type c ON mc.company_type_id = c.id
WHERE 
    t.production_year >= 2000
ORDER BY 
    t.production_year DESC, 
    a.name;
