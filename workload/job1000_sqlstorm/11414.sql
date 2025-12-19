SELECT 
    a.id AS aka_id,
    a.name AS aka_name,
    t.id AS title_id,
    t.title AS movie_title,
    p.id AS person_id,
    p.name AS person_name,
    c.kind AS comp_cast_kind
FROM 
    aka_name AS a
JOIN 
    cast_info AS ci ON a.person_id = ci.person_id
JOIN 
    title AS t ON ci.movie_id = t.id
JOIN 
    company_name AS cn ON cn.imdb_id = t.imdb_id
JOIN 
    movie_companies AS mc ON mc.movie_id = t.id AND mc.company_id = cn.id
JOIN 
    comp_cast_type AS c ON ci.person_role_id = c.id
JOIN 
    name AS p ON p.imdb_id = ci.person_id
WHERE 
    t.production_year >= 2000
ORDER BY 
    t.production_year DESC, a.name;
