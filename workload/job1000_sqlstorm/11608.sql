SELECT 
    a.name AS aka_name, 
    t.title AS movie_title, 
    ci.nr_order AS cast_order, 
    p.name AS person_name, 
    ct.kind AS company_type 
FROM 
    aka_name a
JOIN 
    cast_info ci ON a.person_id = ci.person_id
JOIN 
    title t ON ci.movie_id = t.id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name cn ON mc.company_id = cn.id
JOIN 
    company_type ct ON mc.company_type_id = ct.id
JOIN 
    name p ON a.person_id = p.imdb_id
WHERE 
    a.name IS NOT NULL 
    AND t.production_year >= 2000
ORDER BY 
    t.production_year DESC, 
    ci.nr_order;
