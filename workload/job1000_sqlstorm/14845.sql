SELECT 
    t.id AS title_id,
    t.title AS movie_title,
    a.name AS actor_name,
    c.kind AS cast_kind,
    m.info AS movie_info,
    co.name AS company_name
FROM 
    title t
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name co ON mc.company_id = co.id
JOIN 
    cast_info ci ON t.id = ci.movie_id
JOIN 
    aka_name a ON ci.person_id = a.person_id
JOIN 
    comp_cast_type c ON ci.person_role_id = c.id
JOIN 
    movie_info m ON t.id = m.movie_id
WHERE 
    t.production_year >= 2000
AND 
    co.country_code = 'USA'
ORDER BY 
    t.production_year DESC, actor_name;