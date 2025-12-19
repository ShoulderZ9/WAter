SELECT 
    a.name AS actor_name,
    t.title AS movie_title,
    t.production_year,
    t.kind_id,
    p.info AS actor_info,
    c.kind AS cast_type
FROM 
    aka_name a
JOIN 
    cast_info ci ON a.person_id = ci.person_id
JOIN 
    title t ON ci.movie_id = t.id
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    role_type rt ON ci.role_id = rt.id
JOIN 
    company_name cn ON t.id = cn.imdb_id
JOIN 
    comp_cast_type c ON ci.person_role_id = c.id
JOIN 
    person_info p ON a.person_id = p.person_id
WHERE 
    t.production_year > 2000
ORDER BY 
    t.production_year DESC, a.name ASC;
