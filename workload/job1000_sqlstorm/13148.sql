SELECT 
    t.title AS movie_title, 
    a.name AS actor_name, 
    r.role AS role_type, 
    ci.note AS cast_note, 
    c.name AS company_name, 
    ci.nr_order AS cast_order
FROM 
    title t
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name c ON mc.company_id = c.id
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    cast_info ci ON cc.subject_id = ci.person_id
JOIN 
    aka_name a ON ci.person_id = a.person_id
JOIN 
    role_type r ON ci.role_id = r.id
WHERE 
    t.production_year >= 2000 
ORDER BY 
    t.production_year DESC, 
    ci.nr_order;
