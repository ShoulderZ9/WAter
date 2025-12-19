SELECT 
    t.title,
    p.name AS person_name,
    c.note AS role_note
FROM 
    title t
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    cast_info c ON cc.subject_id = c.person_id
JOIN 
    name p ON c.person_id = p.id
WHERE 
    t.production_year > 2000
ORDER BY 
    t.title;
