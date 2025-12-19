SELECT 
    a.name AS aka_name,
    at.title AS movie_title,
    p.name AS person_name,
    ci.note AS role_note,
    c.kind AS company_type,
    t.title AS title_name,
    ti.info AS movie_info
FROM 
    aka_name a
JOIN 
    cast_info ci ON a.person_id = ci.person_id
JOIN 
    aka_title at ON ci.movie_id = at.movie_id
JOIN 
    name p ON ci.person_id = p.imdb_id
JOIN 
    movie_companies mc ON at.movie_id = mc.movie_id
JOIN 
    company_name cn ON mc.company_id = cn.imdb_id
JOIN 
    company_type c ON mc.company_type_id = c.id
JOIN 
    title t ON at.movie_id = t.id
JOIN 
    movie_info mi ON at.movie_id = mi.movie_id
JOIN 
    info_type ti ON mi.info_type_id = ti.id
WHERE 
    at.production_year BETWEEN 2000 AND 2023
ORDER BY 
    at.production_year DESC, a.name;
