SELECT 
    t.title,
    p.name,
    c.role_id
FROM 
    title t
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    cast_info c ON cc.subject_id = c.id
JOIN 
    aka_name p ON c.person_id = p.person_id
WHERE 
    t.production_year = 2020
ORDER BY 
    t.title;
