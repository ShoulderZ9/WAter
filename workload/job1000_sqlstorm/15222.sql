SELECT 
    t.title, 
    p.name AS person_name, 
    c.nr_order 
FROM 
    title t 
JOIN 
    complete_cast cc ON t.id = cc.movie_id 
JOIN 
    cast_info c ON cc.subject_id = c.person_id 
JOIN 
    aka_name p ON c.person_id = p.person_id 
WHERE 
    t.production_year >= 2000 
ORDER BY 
    t.title;
