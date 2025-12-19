SELECT 
    a.name AS actor_name,
    t.title AS movie_title,
    c.nr_order AS cast_order,
    t.production_year,
    p.info AS person_info
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    aka_title t ON c.movie_id = t.movie_id
JOIN 
    movie_info mi ON t.id = mi.movie_id
JOIN 
    person_info p ON c.person_id = p.person_id
WHERE 
    mi.info_type_id = (SELECT id FROM info_type WHERE info = 'Some Info Type') 
    AND t.production_year >= 2000
ORDER BY 
    t.production_year DESC, 
    c.nr_order;
