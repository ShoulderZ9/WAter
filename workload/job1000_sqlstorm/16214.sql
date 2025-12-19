SELECT 
    title.title,
    aka_name.name AS actor_name,
    company_name.name AS company_name
FROM 
    title
JOIN 
    complete_cast ON title.id = complete_cast.movie_id
JOIN 
    aka_name ON complete_cast.subject_id = aka_name.person_id
JOIN 
    movie_companies ON title.id = movie_companies.movie_id
JOIN 
    company_name ON movie_companies.company_id = company_name.id
WHERE 
    title.production_year = 2023
ORDER BY 
    title.title;
