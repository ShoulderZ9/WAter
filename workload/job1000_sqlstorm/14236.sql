SELECT 
    a.name AS aka_name,
    t.title AS movie_title,
    c.note AS cast_note,
    n.name AS actor_name,
    rc.role AS role
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    title t ON c.movie_id = t.id
JOIN 
    name n ON a.person_id = n.imdb_id
JOIN 
    role_type rc ON c.role_id = rc.id
WHERE 
    t.production_year >= 2000 
ORDER BY 
    t.production_year DESC, n.name;
