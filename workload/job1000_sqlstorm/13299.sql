SELECT 
    a.name AS actor_name,
    t.title AS movie_title,
    c.nr_order AS role_order,
    r.role AS role_type,
    y.production_year
FROM 
    aka_name AS a
JOIN 
    cast_info AS c ON a.person_id = c.person_id
JOIN 
    title AS t ON c.movie_id = t.id
JOIN 
    role_type AS r ON c.role_id = r.id
JOIN 
    aka_title AS y ON t.id = y.movie_id
WHERE 
    y.kind_id = (SELECT id FROM kind_type WHERE kind = 'feature')
ORDER BY 
    y.production_year DESC, 
    a.name;
