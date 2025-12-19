SELECT 
    t.title AS movie_title,
    a.name AS actor_name,
    r.role AS role_type,
    c.note AS cast_note,
    y.info AS movie_info
FROM 
    title t
JOIN 
    cast_info c ON t.id = c.movie_id
JOIN 
    aka_name a ON c.person_id = a.person_id
JOIN 
    role_type r ON c.role_id = r.id
JOIN 
    movie_info y ON t.id = y.movie_id
WHERE 
    r.role = 'Actor'
    AND y.info_type_id = (SELECT id FROM info_type WHERE info = 'Description')
ORDER BY 
    t.production_year DESC, 
    a.name;
