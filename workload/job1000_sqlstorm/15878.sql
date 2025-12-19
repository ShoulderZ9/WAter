SELECT 
    a.name AS actor_name,
    t.title AS movie_title,
    c.person_role_id AS role_id,
    c.nr_order AS order_in_cast
FROM 
    aka_name AS a
JOIN 
    cast_info AS c ON a.person_id = c.person_id
JOIN 
    aka_title AS t ON c.movie_id = t.movie_id
WHERE 
    t.production_year = 2022
ORDER BY 
    a.name, t.title;
