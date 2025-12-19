SELECT 
    a.name AS aka_name, 
    t.title AS movie_title, 
    p.name AS person_name, 
    c.role_id AS role
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    title t ON c.movie_id = t.id
JOIN 
    name p ON a.person_id = p.imdb_id
WHERE 
    t.production_year = 2022;
