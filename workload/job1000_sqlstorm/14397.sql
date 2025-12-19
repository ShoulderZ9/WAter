SELECT 
    co.name AS company_name,
    t.title AS movie_title,
    p.name AS person_name,
    ci.note AS cast_note,
    m.info AS movie_info
FROM 
    aka_title AS t
JOIN 
    movie_companies AS mc ON t.id = mc.movie_id
JOIN 
    company_name AS co ON mc.company_id = co.id
JOIN 
    complete_cast AS cc ON t.id = cc.movie_id
JOIN 
    cast_info AS ci ON cc.subject_id = ci.id
JOIN 
    aka_name AS p ON ci.person_id = p.person_id
JOIN 
    movie_info AS m ON t.id = m.movie_id
WHERE 
    t.production_year >= 2000
ORDER BY 
    t.production_year DESC, t.title;
