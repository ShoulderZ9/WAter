
SELECT 
    a.id AS aka_id,
    a.name AS aka_name,
    t.id AS title_id,
    t.title AS movie_title,
    c.id AS cast_id,
    n.name AS actor_name,
    ct.kind AS company_type
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    title t ON c.movie_id = t.id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_type ct ON mc.company_type_id = ct.id
JOIN 
    company_name cn ON mc.company_id = cn.id
JOIN 
    name n ON c.person_id = n.imdb_id
WHERE 
    t.production_year >= 2000
GROUP BY 
    a.id, a.name, t.id, t.title, c.id, n.name, ct.kind
ORDER BY 
    t.production_year DESC, a.name;
