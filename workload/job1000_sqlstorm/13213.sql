SELECT 
    t.title, 
    a.name AS actor_name, 
    c.kind AS cast_type, 
    p.info AS person_info, 
    m.info AS movie_info 
FROM 
    title t
JOIN 
    movie_info m ON t.id = m.movie_id
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    cast_info ci ON cc.subject_id = ci.person_id
JOIN 
    aka_name a ON ci.person_id = a.person_id
JOIN 
    comp_cast_type c ON ci.role_id = c.id
JOIN 
    person_info p ON a.person_id = p.person_id
WHERE 
    m.info_type_id IN (SELECT id FROM info_type WHERE info = 'Summary')
    AND t.production_year >= 2000
ORDER BY 
    t.production_year DESC;
