SELECT 
    a.name AS aka_name,
    t.title AS title,
    p.name AS person_name,
    ct.kind AS company_type,
    k.keyword AS movie_keyword
FROM 
    aka_name a
JOIN 
    cast_info ci ON a.person_id = ci.person_id
JOIN 
    title t ON ci.movie_id = t.id
JOIN 
    movie_companies mc ON mc.movie_id = t.id
JOIN 
    company_type ct ON mc.company_type_id = ct.id
JOIN 
    movie_keyword mk ON mk.movie_id = t.id
JOIN 
    keyword k ON mk.keyword_id = k.id
JOIN 
    name p ON p.id = a.person_id
WHERE 
    t.production_year >= 2000
ORDER BY 
    t.production_year DESC
LIMIT 100;
