SELECT 
    t.title, 
    a.name, 
    c.note 
FROM 
    title t 
JOIN 
    movie_info mi ON t.id = mi.movie_id 
JOIN 
    cast_info c ON t.id = c.movie_id 
JOIN 
    aka_name a ON c.person_id = a.person_id 
WHERE 
    t.production_year = 2022 
ORDER BY 
    t.title;
