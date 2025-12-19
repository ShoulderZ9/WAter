SELECT 
    a.name AS aka_name,
    t.title AS movie_title,
    p.name AS person_name,
    ci.nr_order AS cast_order
FROM 
    aka_name a
JOIN 
    cast_info ci ON a.person_id = ci.person_id
JOIN 
    title t ON ci.movie_id = t.id
JOIN 
    name p ON a.person_id = p.imdb_id
WHERE 
    t.production_year BETWEEN 2000 AND 2023
ORDER BY 
    t.production_year DESC, ci.nr_order;
