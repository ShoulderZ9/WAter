SELECT 
    a.title AS movie_title,
    a.production_year,
    c.name AS cast_name,
    r.role AS character_role,
    co.name AS company_name
FROM 
    aka_title a
JOIN 
    complete_cast cc ON a.id = cc.movie_id
JOIN 
    cast_info c_info ON cc.subject_id = c_info.id
JOIN 
    aka_name c ON c_info.person_id = c.id
JOIN 
    movie_companies mc ON a.id = mc.movie_id
JOIN 
    company_name co ON mc.company_id = co.id
JOIN 
    role_type r ON c_info.role_id = r.id
WHERE 
    a.production_year BETWEEN 2000 AND 2023
ORDER BY 
    a.production_year DESC, a.title;
