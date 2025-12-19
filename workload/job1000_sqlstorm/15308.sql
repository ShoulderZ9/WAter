SELECT 
    a.name AS actor_name,
    t.title AS movie_title,
    c.note AS cast_note,
    p.info AS person_info
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    aka_title t ON c.movie_id = t.movie_id
JOIN 
    person_info p ON a.person_id = p.person_id
WHERE 
    p.info_type_id = (SELECT id FROM info_type WHERE info = 'Biography')
ORDER BY 
    a.name, t.title;
