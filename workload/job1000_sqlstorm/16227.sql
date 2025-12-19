SELECT 
    t.title, 
    p.name, 
    a.name AS aka_name, 
    c.nr_order, 
    r.role 
FROM 
    title t 
JOIN 
    cast_info c ON t.id = c.movie_id 
JOIN 
    aka_name a ON c.person_id = a.person_id 
JOIN 
    name p ON c.person_id = p.imdb_id 
JOIN 
    role_type r ON c.role_id = r.id 
WHERE 
    t.production_year = 2023;
