SELECT 
    a.name AS aka_name,
    t.title AS movie_title,
    p.name AS person_name,
    ct.kind AS company_type,
    ci.note AS cast_note
FROM 
    aka_name a
JOIN 
    cast_info ci ON a.person_id = ci.person_id
JOIN 
    aka_title t ON ci.movie_id = t.movie_id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_type ct ON mc.company_type_id = ct.id
JOIN 
    name p ON ci.person_id = p.imdb_id
WHERE 
    t.production_year >= 2000
    AND ct.kind IS NOT NULL
ORDER BY 
    t.production_year DESC, a.name;
