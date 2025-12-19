SELECT 
    t.title,
    a.name AS actor_name,
    w.name AS company_name,
    m.info AS movie_info,
    k.keyword AS movie_keyword,
    r.role AS role_type
FROM 
    title t
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    cast_info ci ON cc.subject_id = ci.person_id
JOIN 
    aka_name a ON ci.person_id = a.person_id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name w ON mc.company_id = w.id
JOIN 
    movie_info m ON t.id = m.movie_id
JOIN 
    movie_keyword mk ON t.id = mk.movie_id
JOIN 
    keyword k ON mk.keyword_id = k.id
JOIN 
    role_type r ON ci.role_id = r.id
WHERE 
    t.production_year >= 2000
    AND w.country_code = 'USA'
ORDER BY 
    t.production_year DESC, a.name;
