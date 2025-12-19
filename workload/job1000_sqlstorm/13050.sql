SELECT 
    t.id AS title_id,
    t.title AS movie_title,
    t.production_year,
    ak.name AS aka_name,
    n.name AS person_name,
    r.role AS person_role,
    c.note AS cast_note
FROM 
    title t
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name cn ON mc.company_id = cn.id
JOIN 
    movie_info mi ON t.id = mi.movie_id
JOIN 
    cast_info c ON t.id = c.movie_id
JOIN 
    aka_name ak ON c.person_id = ak.person_id
JOIN 
    name n ON ak.person_id = n.imdb_id
JOIN 
    role_type r ON c.role_id = r.id
WHERE 
    t.production_year >= 2000
ORDER BY 
    t.production_year DESC, 
    t.title
LIMIT 100;