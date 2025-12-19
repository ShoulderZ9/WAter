SELECT 
    t.title AS movie_title,
    a.name AS actor_name,
    r.role AS actor_role,
    c.note AS cast_note,
    m.info AS movie_info
FROM 
    title t
JOIN 
    movie_info m ON t.id = m.movie_id
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    cast_info c ON cc.subject_id = c.person_id
JOIN 
    aka_name a ON c.person_id = a.person_id
JOIN 
    role_type r ON c.role_id = r.id
WHERE 
    m.info_type_id = 1  
ORDER BY 
    t.production_year DESC, a.name;