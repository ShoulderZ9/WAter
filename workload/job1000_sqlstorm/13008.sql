
SELECT 
    tt.title AS movie_title,
    a.name AS actor_name,
    rt.role AS actor_role,
    tt.production_year
FROM 
    title tt
JOIN 
    aka_title at ON tt.id = at.movie_id
JOIN 
    cast_info ci ON at.id = ci.movie_id
JOIN 
    aka_name a ON ci.person_id = a.person_id
JOIN 
    role_type rt ON ci.role_id = rt.id
WHERE 
    tt.production_year >= 2000
GROUP BY 
    tt.title, a.name, rt.role, tt.production_year
ORDER BY 
    tt.production_year DESC, 
    tt.title;
