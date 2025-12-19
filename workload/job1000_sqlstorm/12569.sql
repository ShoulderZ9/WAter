SELECT 
    a.name AS aka_name,
    t.title AS movie_title,
    c.id AS cast_id,
    p.name AS person_name,
    r.role AS role_name,
    m.info AS movie_info
FROM 
    aka_name AS a
JOIN 
    cast_info AS c ON a.person_id = c.person_id
JOIN 
    title AS t ON c.movie_id = t.id
JOIN 
    name AS p ON c.person_id = p.imdb_id
JOIN 
    role_type AS r ON c.role_id = r.id
LEFT JOIN 
    movie_info AS m ON t.id = m.movie_id
WHERE 
    t.production_year BETWEEN 2000 AND 2020
ORDER BY 
    t.production_year DESC, a.name;
