SELECT 
    a.name AS aka_name,
    t.title AS movie_title,
    p.name AS person_name,
    c.nr_order AS cast_order,
    ct.kind AS company_type,
    mi.info AS movie_info
FROM 
    aka_name AS a
JOIN 
    cast_info AS c ON a.person_id = c.person_id
JOIN 
    title AS t ON c.movie_id = t.id
JOIN 
    movie_companies AS mc ON t.id = mc.movie_id
JOIN 
    company_type AS ct ON mc.company_type_id = ct.id
JOIN 
    movie_info AS mi ON t.id = mi.movie_id
JOIN 
    name AS p ON a.person_id = p.imdb_id
WHERE 
    t.production_year > 2000
ORDER BY 
    t.production_year DESC, c.nr_order;
