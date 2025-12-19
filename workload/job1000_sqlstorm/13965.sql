SELECT 
    a.name AS actor_name,
    t.title AS movie_title,
    r.role AS role,
    ct.kind AS comp_cast_type,
    ci.note AS cast_info_note
FROM 
    aka_name a
JOIN 
    cast_info ci ON a.person_id = ci.person_id
JOIN 
    title t ON ci.movie_id = t.id
JOIN 
    role_type r ON ci.role_id = r.id
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    comp_cast_type ct ON ci.person_role_id = ct.id
WHERE 
    t.production_year >= 2000 AND 
    a.name IS NOT NULL
ORDER BY 
    t.production_year DESC, 
    a.name;
