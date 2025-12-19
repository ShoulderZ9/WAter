SELECT 
    a.name AS actor_name,
    t.title AS movie_title,
    c.note AS role_note,
    p.info AS person_info
FROM 
    cast_info c
JOIN 
    aka_name a ON c.person_id = a.person_id
JOIN 
    aka_title t ON c.movie_id = t.movie_id
JOIN 
    person_info p ON c.person_id = p.person_id
WHERE 
    t.production_year = 2020
ORDER BY 
    a.name, t.title;
