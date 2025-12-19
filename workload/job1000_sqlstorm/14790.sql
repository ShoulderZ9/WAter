SELECT 
    a.name AS aka_name,
    t.title AS movie_title,
    ci.note AS cast_note,
    cn.name AS company_name,
    ckt.kind AS company_type,
    mt.link AS movie_link
FROM 
    aka_name a
JOIN 
    cast_info ci ON a.person_id = ci.person_id
JOIN 
    aka_title t ON ci.movie_id = t.movie_id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_name cn ON mc.company_id = cn.id
JOIN 
    company_type ckt ON mc.company_type_id = ckt.id
JOIN 
    movie_link ml ON t.id = ml.movie_id
JOIN 
    link_type mt ON ml.link_type_id = mt.id
WHERE 
    t.production_year >= 2000
ORDER BY 
    t.production_year DESC, 
    a.name;
