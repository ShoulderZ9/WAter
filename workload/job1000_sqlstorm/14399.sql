SELECT 
    a.name AS aka_name,
    t.title AS movie_title,
    c.nr_order,
    r.role AS role_type,
    i.info AS movie_info
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    title t ON c.movie_id = t.id
JOIN 
    role_type r ON c.role_id = r.id
JOIN 
    movie_info i ON t.id = i.movie_id
WHERE 
    i.info_type_id = (SELECT id FROM info_type WHERE info = 'Genre')
ORDER BY 
    t.production_year DESC;
