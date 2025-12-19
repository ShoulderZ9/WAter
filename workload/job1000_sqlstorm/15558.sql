SELECT 
    t.title,
    a.name AS actor_name,
    c.kind AS company_type,
    k.keyword
FROM 
    title t
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_type c ON mc.company_type_id = c.id
JOIN 
    cast_info ca ON t.id = ca.movie_id
JOIN 
    aka_name a ON ca.person_id = a.person_id
JOIN 
    movie_keyword mk ON t.id = mk.movie_id
JOIN 
    keyword k ON mk.keyword_id = k.id
WHERE 
    t.production_year = 2020
ORDER BY 
    t.title, actor_name;
