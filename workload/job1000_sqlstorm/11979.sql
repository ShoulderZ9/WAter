SELECT 
    a.name AS actor_name, 
    t.title AS movie_title, 
    c.note AS role_note, 
    t.production_year, 
    cn.name AS company_name 
FROM 
    aka_name a 
JOIN 
    cast_info c ON a.person_id = c.person_id 
JOIN 
    aka_title t ON c.movie_id = t.movie_id 
JOIN 
    movie_companies mc ON t.id = mc.movie_id 
JOIN 
    company_name cn ON mc.company_id = cn.id 
WHERE 
    t.kind_id = (SELECT id FROM kind_type WHERE kind = 'feature') 
ORDER BY 
    t.production_year DESC;
