SELECT 
    a.name AS aka_name,
    t.title AS movie_title,
    c.nr_order,
    r.role,
    p.info AS person_info,
    m.info AS movie_info
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    title t ON c.movie_id = t.id
JOIN 
    role_type r ON c.role_id = r.id
JOIN 
    person_info p ON a.person_id = p.person_id
JOIN 
    movie_info m ON t.id = m.movie_id
WHERE 
    m.info_type_id IN (SELECT id FROM info_type WHERE info = 'Some Info Criteria') 
    AND c.nr_order IS NOT NULL 
ORDER BY 
    t.production_year DESC, 
    a.name;