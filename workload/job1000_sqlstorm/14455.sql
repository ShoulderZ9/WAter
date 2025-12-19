SELECT 
    t.title,
    a.name AS actor_name,
    ct.kind AS cast_type,
    m.name AS company_name,
    mi.info AS movie_info
FROM 
    title t
JOIN 
    cast_info ci ON t.id = ci.movie_id
JOIN 
    aka_name a ON ci.person_id = a.person_id
JOIN 
    comp_cast_type ct ON ci.person_role_id = ct.id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name m ON mc.company_id = m.id
JOIN 
    movie_info mi ON t.id = mi.movie_id
WHERE 
    m.country_code = 'USA' 
    AND t.production_year >= 2000
ORDER BY 
    t.production_year DESC, 
    a.name;
