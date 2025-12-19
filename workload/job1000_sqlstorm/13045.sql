
SELECT 
    t.title AS movie_title,
    a.name AS actor_name,
    c.kind AS character_role,
    t.production_year,
    k.keyword AS movie_keyword
FROM 
    aka_name a
JOIN 
    cast_info ci ON a.person_id = ci.person_id
JOIN 
    title t ON ci.movie_id = t.id
JOIN 
    movie_keyword mk ON t.id = mk.movie_id
JOIN 
    keyword k ON mk.keyword_id = k.id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name cn ON mc.company_id = cn.id
JOIN 
    comp_cast_type c ON ci.role_id = c.id
WHERE 
    k.keyword = 'action'
GROUP BY 
    t.title, a.name, c.kind, t.production_year, k.keyword
ORDER BY 
    t.production_year DESC;
