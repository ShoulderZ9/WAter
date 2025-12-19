
SELECT 
    t.title AS movie_title,
    a.name AS actor_name,
    ct.kind AS company_kind,
    k.keyword AS movie_keyword,
    p.info AS person_info
FROM 
    title t
JOIN 
    aka_title at ON t.id = at.movie_id
JOIN 
    cast_info ci ON at.id = ci.movie_id
JOIN 
    aka_name a ON ci.person_id = a.person_id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_type ct ON mc.company_type_id = ct.id
JOIN 
    keyword k ON k.id = mc.movie_id
JOIN 
    person_info p ON a.id = p.person_id
WHERE 
    t.production_year >= 2000
GROUP BY 
    t.title, a.name, ct.kind, k.keyword, p.info, t.production_year
ORDER BY 
    t.production_year DESC, 
    a.name;
