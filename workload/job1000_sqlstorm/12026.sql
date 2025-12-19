SELECT 
    t.title AS movie_title,
    a.name AS actor_name,
    rt.role AS actor_role,
    c.name AS company_name,
    km.keyword AS movie_keyword,
    mi.info AS movie_info
FROM 
    title t
JOIN 
    cast_info ci ON t.id = ci.movie_id
JOIN 
    aka_name a ON ci.person_id = a.person_id
JOIN 
    role_type rt ON ci.role_id = rt.id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name c ON mc.company_id = c.id
JOIN 
    movie_keyword mk ON t.id = mk.movie_id
JOIN 
    keyword km ON mk.keyword_id = km.id
JOIN 
    movie_info mi ON t.id = mi.movie_id
WHERE 
    t.production_year >= 2000
    AND c.country_code = 'USA'
ORDER BY 
    t.title, a.name;
