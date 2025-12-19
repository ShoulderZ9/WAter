SELECT 
    a.id AS aka_name_id,
    a.name AS aka_name,
    t.id AS title_id,
    t.title AS title,
    c.id AS cast_info_id,
    c.note AS cast_note,
    p.id AS person_id,
    p.name AS person_name,
    r.role AS role_type
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    title t ON c.movie_id = t.id
JOIN 
    name p ON c.person_id = p.imdb_id
JOIN 
    role_type r ON c.role_id = r.id
WHERE 
    t.production_year >= 2000 
ORDER BY 
    t.production_year DESC;
