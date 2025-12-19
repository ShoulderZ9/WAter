SELECT 
    a.name AS aka_name,
    t.title AS movie_title,
    c.note AS cast_note,
    r.role AS role_type,
    ci.name AS company_name,
    mn.info AS movie_info
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    title t ON c.movie_id = t.id
JOIN 
    role_type r ON c.role_id = r.id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name ci ON mc.company_id = ci.id
JOIN 
    movie_info mn ON t.id = mn.movie_id
WHERE 
    mn.info_type_id = (SELECT id FROM info_type WHERE info = 'Genre')
ORDER BY 
    t.production_year DESC, a.name;
