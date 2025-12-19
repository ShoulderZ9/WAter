SELECT 
    aka_name.name AS aka_name,
    title.title AS movie_title,
    company_name.name AS company_name,
    role_type.role AS role,
    movie_info.info AS movie_info
FROM 
    aka_name
JOIN 
    cast_info ON aka_name.person_id = cast_info.person_id
JOIN 
    title ON cast_info.movie_id = title.id
JOIN 
    movie_companies ON title.id = movie_companies.movie_id
JOIN 
    company_name ON movie_companies.company_id = company_name.id
JOIN 
    role_type ON cast_info.role_id = role_type.id
JOIN 
    movie_info ON title.id = movie_info.movie_id
WHERE 
    title.production_year >= 2000
    AND company_name.country_code = 'USA'
ORDER BY 
    title.production_year DESC, aka_name.name;
