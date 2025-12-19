
SELECT 
    t.title AS movie_title,
    ak.name AS actor_name,
    rc.role AS role,
    c.name AS company_name,
    t.production_year,
    k.keyword AS movie_keyword
FROM 
    title t
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    cast_info ci ON cc.subject_id = ci.person_id
JOIN 
    aka_name ak ON ci.person_id = ak.person_id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name c ON mc.company_id = c.id
JOIN 
    movie_keyword mk ON t.id = mk.movie_id
JOIN 
    keyword k ON mk.keyword_id = k.id
JOIN 
    role_type rc ON ci.role_id = rc.id
WHERE 
    t.production_year >= 2000
GROUP BY 
    t.title,
    ak.name,
    rc.role,
    c.name,
    t.production_year,
    k.keyword
ORDER BY 
    t.production_year DESC, 
    t.title, 
    ak.name;
