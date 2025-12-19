SELECT 
    t.id AS title_id,
    t.title AS title_name,
    t.production_year,
    c.person_id,
    a.name AS actor_name,
    r.role AS actor_role
FROM 
    title t
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    cast_info c ON cc.subject_id = c.id
JOIN 
    aka_name a ON c.person_id = a.person_id
JOIN 
    role_type r ON c.role_id = r.id
ORDER BY 
    t.production_year DESC, 
    a.name;
