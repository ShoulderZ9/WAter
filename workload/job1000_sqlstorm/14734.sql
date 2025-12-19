SELECT 
    ak.name AS aka_name,
    t.title AS movie_title,
    c.nr_order AS cast_order,
    p.name AS person_name,
    ct.kind AS cast_type,
    mt.info AS movie_info
FROM 
    aka_name ak
JOIN 
    cast_info c ON ak.person_id = c.person_id
JOIN 
    title t ON c.movie_id = t.id
JOIN 
    name p ON c.person_id = p.imdb_id
JOIN 
    comp_cast_type ct ON c.role_id = ct.id
JOIN 
    movie_info mt ON t.id = mt.movie_id
WHERE 
    mt.info_type_id = (SELECT id FROM info_type WHERE info = 'Box Office')
ORDER BY 
    t.production_year DESC, c.nr_order;
