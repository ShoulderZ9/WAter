SELECT 
    t.title AS movie_title, 
    a.name AS actor_name, 
    c.kind AS cast_type, 
    m.info AS movie_description
FROM 
    aka_name a
JOIN 
    cast_info ci ON a.person_id = ci.person_id
JOIN 
    title t ON ci.movie_id = t.id
JOIN 
    movie_info m ON t.id = m.movie_id
JOIN 
    comp_cast_type c ON ci.person_role_id = c.id
WHERE 
    m.info_type_id IN (SELECT id FROM info_type WHERE info = 'description')
ORDER BY 
    t.production_year DESC, a.name ASC;
