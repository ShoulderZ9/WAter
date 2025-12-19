SELECT 
    t.title, 
    a.name AS actor_name, 
    c.kind AS cast_type, 
    mi.info AS movie_info
FROM 
    title t
JOIN 
    aka_title at ON t.id = at.movie_id
JOIN 
    cast_info ci ON at.id = ci.movie_id
JOIN 
    aka_name a ON ci.person_id = a.person_id
JOIN 
    company_name cn ON ci.movie_id = cn.imdb_id
JOIN 
    movie_info mi ON t.id = mi.movie_id
JOIN 
    role_type rt ON ci.role_id = rt.id
JOIN 
    comp_cast_type c ON ci.person_role_id = c.id
WHERE 
    t.production_year >= 2000
ORDER BY 
    t.production_year DESC, 
    a.name;
