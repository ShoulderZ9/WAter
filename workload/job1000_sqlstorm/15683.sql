SELECT 
    m.title AS movie_title, 
    p.name AS person_name, 
    c.nr_order AS cast_order 
FROM 
    title m 
JOIN 
    complete_cast cc ON m.id = cc.movie_id 
JOIN 
    cast_info c ON cc.subject_id = c.id 
JOIN 
    aka_name p ON c.person_id = p.person_id 
WHERE 
    m.production_year = 2020 
ORDER BY 
    c.nr_order;
