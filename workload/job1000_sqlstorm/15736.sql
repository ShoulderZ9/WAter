SELECT 
    t.title, 
    ak.name AS aka_name, 
    c.person_role_id, 
    p.info AS person_info 
FROM 
    title t 
JOIN 
    movie_companies mc ON t.id = mc.movie_id 
JOIN 
    company_name cn ON mc.company_id = cn.id 
JOIN 
    cast_info c ON t.id = c.movie_id 
JOIN 
    aka_name ak ON c.person_id = ak.person_id 
JOIN 
    person_info p ON ak.person_id = p.person_id 
WHERE 
    t.production_year = 2020;
