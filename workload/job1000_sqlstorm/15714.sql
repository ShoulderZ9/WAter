SELECT 
    t.title, 
    a.name AS actor_name, 
    p.info AS actor_info
FROM 
    aka_title t
JOIN 
    cast_info c ON t.id = c.movie_id
JOIN 
    aka_name a ON c.person_id = a.person_id
JOIN 
    person_info p ON a.person_id = p.person_id
WHERE 
    t.production_year = 2022
ORDER BY 
    t.title;
