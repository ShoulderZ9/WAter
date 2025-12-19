SELECT 
    t.title AS movie_title, 
    p.name AS actor_name, 
    c.nr_order AS cast_order 
FROM 
    title t
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name cn ON mc.company_id = cn.id
JOIN 
    cast_info c ON t.id = c.movie_id
JOIN 
    aka_name p ON c.person_id = p.person_id
WHERE 
    t.production_year = 2020
ORDER BY 
    t.title, c.nr_order;
