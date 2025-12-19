SELECT 
    ak.name AS aka_name,
    m.title AS movie_title,
    pi.info AS person_info,
    c.role_id AS role_id,
    c.nr_order AS order_number
FROM 
    aka_name ak
JOIN 
    cast_info c ON ak.person_id = c.person_id
JOIN 
    aka_title m ON c.movie_id = m.movie_id
JOIN 
    person_info pi ON ak.person_id = pi.person_id
WHERE 
    m.production_year = 2023
ORDER BY 
    m.title, c.nr_order;
