SELECT 
    p.id AS person_id, 
    p.name AS person_name, 
    t.title AS movie_title, 
    a.name AS aka_name 
FROM 
    cast_info AS ci 
JOIN 
    aka_name AS a ON ci.person_id = a.person_id 
JOIN 
    title AS t ON ci.movie_id = t.id 
JOIN 
    name AS p ON ci.person_id = p.id 
WHERE 
    t.production_year = 2020 
ORDER BY 
    p.name;
