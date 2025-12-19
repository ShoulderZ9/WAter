SELECT 
    p.name AS person_name,
    t.title AS movie_title,
    c.nr_order AS role_order,
    r.role AS role_name,
    co.name AS company_name,
    m.info AS movie_info
FROM 
    cast_info c
JOIN 
    aka_name p ON c.person_id = p.person_id
JOIN 
    aka_title t ON c.movie_id = t.movie_id
JOIN 
    role_type r ON c.role_id = r.id
JOIN 
    movie_companies mc ON c.movie_id = mc.movie_id
JOIN 
    company_name co ON mc.company_id = co.id
JOIN 
    movie_info m ON c.movie_id = m.movie_id
WHERE 
    t.production_year > 2000
    AND co.country_code = 'USA'
ORDER BY 
    t.production_year DESC, 
    c.nr_order;
