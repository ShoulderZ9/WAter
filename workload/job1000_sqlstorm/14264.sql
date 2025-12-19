SELECT 
    a.name AS actor_name,
    t.title AS movie_title,
    c.role_id AS role_id,
    ti.info AS movie_info
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    aka_title t ON c.movie_id = t.movie_id
JOIN 
    movie_info ti ON t.id = ti.movie_id
WHERE 
    ti.info_type_id = (SELECT id FROM info_type WHERE info = 'Genre')
ORDER BY 
    a.name, t.production_year;
