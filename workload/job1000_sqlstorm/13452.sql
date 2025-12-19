SELECT 
    t.title AS movie_title, 
    ak.name AS actor_name, 
    r.role AS role_type, 
    c.note AS cast_note, 
    m.info AS movie_info
FROM 
    title t
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    cast_info c ON cc.subject_id = c.id
JOIN 
    aka_name ak ON c.person_id = ak.person_id
JOIN 
    role_type r ON c.role_id = r.id
JOIN 
    movie_info m ON t.id = m.movie_id
WHERE 
    m.info_type_id = (SELECT id FROM info_type WHERE info = 'summary')
ORDER BY 
    t.production_year DESC;
