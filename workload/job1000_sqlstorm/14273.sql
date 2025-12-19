SELECT 
    a.name AS aka_name, 
    t.title AS movie_title, 
    m.name AS company_name, 
    p.info AS person_info
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    aka_title t ON c.movie_id = t.movie_id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name m ON mc.company_id = m.id
JOIN 
    person_info p ON a.person_id = p.person_id
WHERE 
    t.production_year >= 2000
    AND m.country_code = 'USA'
ORDER BY 
    t.production_year DESC, 
    a.name;
