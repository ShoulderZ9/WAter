
SELECT 
    t.title, 
    n.name AS actor_name, 
    a.name AS alias_name, 
    ct.kind AS company_type, 
    k.keyword AS keyword
FROM 
    title t
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name cn ON mc.company_id = cn.id
JOIN 
    company_type ct ON mc.company_type_id = ct.id
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    aka_name a ON cc.subject_id = a.person_id
JOIN 
    cast_info ci ON a.person_id = ci.person_id AND t.id = ci.movie_id
JOIN 
    name n ON a.person_id = n.imdb_id
JOIN 
    movie_keyword mk ON t.id = mk.movie_id
JOIN 
    keyword k ON mk.keyword_id = k.id
WHERE 
    t.production_year >= 2000
GROUP BY 
    t.title, n.name, a.name, ct.kind, k.keyword
ORDER BY 
    t.title, n.name;
