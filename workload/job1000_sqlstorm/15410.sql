SELECT 
    a.name AS aka_name,
    t.title AS movie_title,
    c.role_id,
    p.info
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    title t ON c.movie_id = t.id
JOIN 
    person_info p ON a.person_id = p.person_id
WHERE 
    t.production_year = 2023
ORDER BY 
    a.name, t.title;
