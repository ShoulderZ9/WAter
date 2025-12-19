SELECT 
    a.name AS actor_name,
    t.title AS movie_title,
    c.note AS cast_note,
    c.nr_order AS cast_order
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    aka_title t ON c.movie_id = t.movie_id
WHERE 
    t.production_year = 2021
ORDER BY 
    c.nr_order;
