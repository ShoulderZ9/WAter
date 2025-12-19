SELECT 
    t.title AS movie_title,
    a.name AS actor_name,
    COUNT(*) AS role_count
FROM 
    title t
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name c ON mc.company_id = c.id
JOIN 
    movie_info mi ON t.id = mi.movie_id
JOIN 
    cast_info ci ON t.id = ci.movie_id
JOIN 
    aka_name a ON ci.person_id = a.person_id
WHERE 
    t.production_year >= 2000
    AND c.country_code = 'USA'
GROUP BY 
    t.title, a.name
ORDER BY 
    role_count DESC
LIMIT 10;
