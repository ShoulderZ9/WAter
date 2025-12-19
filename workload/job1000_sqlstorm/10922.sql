SELECT 
    aka.name AS aka_name,
    title.title AS movie_title,
    company.name AS company_name,
    person_info.info AS person_info,
    role.role AS role_type,
    movie_info.info AS movie_info
FROM title
JOIN movie_companies ON title.id = movie_companies.movie_id
JOIN company_name AS company ON movie_companies.company_id = company.id
JOIN complete_cast ON title.id = complete_cast.movie_id
JOIN cast_info ON complete_cast.subject_id = cast_info.id
JOIN aka_name AS aka ON cast_info.person_id = aka.person_id
JOIN person_info ON aka.person_id = person_info.person_id
JOIN role_type AS role ON cast_info.role_id = role.id
JOIN movie_info ON title.id = movie_info.movie_id
WHERE title.production_year >= 2000
ORDER BY title.production_year DESC, title.title;