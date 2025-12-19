SELECT 
    a.name AS actor_name,
    t.title AS movie_title,
    c.note AS character_note,
    r.role AS role_name,
    m.info AS movie_info
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    title t ON c.movie_id = t.id
JOIN 
    role_type r ON c.role_id = r.id
JOIN 
    movie_info m ON t.id = m.movie_id
WHERE 
    m.info_type_id = (SELECT id FROM info_type WHERE info = 'Summary')
AND 
    t.production_year >= 2000
ORDER BY 
    t.production_year DESC;
