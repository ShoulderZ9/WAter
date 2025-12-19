
SELECT 
    t.title AS movie_title,
    a.name AS actor_name,
    k.keyword AS movie_keyword,
    p.info AS person_info,
    ct.kind AS company_type
FROM 
    title t
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name cn ON mc.company_id = cn.id
JOIN 
    company_type ct ON mc.company_type_id = ct.id
JOIN 
    cast_info ci ON t.id = ci.movie_id
JOIN 
    aka_name a ON ci.person_id = a.person_id
JOIN 
    movie_keyword mk ON t.id = mk.movie_id
JOIN 
    keyword k ON mk.keyword_id = k.id
JOIN 
    person_info p ON a.person_id = p.person_id
WHERE 
    t.production_year >= 2000
    AND ct.kind = 'Production'
GROUP BY 
    t.title, a.name, k.keyword, p.info, ct.kind
ORDER BY 
    t.title, a.name;
