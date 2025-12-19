
SELECT 
    t.title AS movie_title,
    a.name AS actor_name,
    r.role AS role_type,
    c.note AS cast_note,
    t.production_year,
    k.keyword AS movie_keyword
FROM 
    title AS t
JOIN 
    movie_keyword AS mk ON t.id = mk.movie_id
JOIN 
    keyword AS k ON mk.keyword_id = k.id
JOIN 
    complete_cast AS cc ON t.id = cc.movie_id
JOIN 
    cast_info AS c ON cc.subject_id = c.person_id
JOIN 
    aka_name AS a ON c.person_id = a.person_id
JOIN 
    role_type AS r ON c.role_id = r.id
JOIN 
    aka_title AS at ON t.id = at.movie_id
WHERE 
    t.production_year > 2000
GROUP BY 
    t.title, a.name, r.role, c.note, t.production_year, k.keyword
ORDER BY 
    t.production_year DESC, a.name;
