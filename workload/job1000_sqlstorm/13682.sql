SELECT 
    t.title AS movie_title,
    c.name AS actor_name,
    p.info AS person_info,
    k.keyword AS movie_keyword,
    cn.name AS company_name,
    m.info AS movie_info
FROM 
    title t
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    cast_info ci ON cc.subject_id = ci.id
JOIN 
    aka_name c ON ci.person_id = c.person_id
JOIN 
    person_info p ON c.person_id = p.person_id
JOIN 
    movie_keyword mk ON t.id = mk.movie_id
JOIN 
    keyword k ON mk.keyword_id = k.id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name cn ON mc.company_id = cn.id
JOIN 
    movie_info m ON t.id = m.movie_id
WHERE 
    t.production_year = 2020
ORDER BY 
    t.title, c.name;
