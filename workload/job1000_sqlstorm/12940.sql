SELECT 
    a.name AS aka_name,
    t.title AS movie_title,
    p.name AS person_name,
    c.note AS cast_note,
    ci.kind AS comp_cast_type,
    ci.id AS comp_cast_id
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    title t ON c.movie_id = t.id
JOIN 
    company_name cn ON t.id = (SELECT mc.movie_id FROM movie_companies mc WHERE mc.movie_id = t.id)
JOIN 
    comp_cast_type ci ON c.person_role_id = ci.id
JOIN 
    name p ON a.person_id = p.imdb_id
WHERE 
    t.production_year >= 2000
ORDER BY 
    t.production_year DESC;
