SELECT 
    t.title, 
    p.name, 
    c.nr_order, 
    ct.kind
FROM 
    title t
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    cast_info c ON cc.subject_id = c.person_id
JOIN 
    aka_name p ON c.person_id = p.person_id
JOIN 
    company_name cn ON t.id = cn.imdb_id
JOIN 
    company_type ct ON cn.id = ct.id
WHERE 
    t.production_year > 2000
ORDER BY 
    t.title, 
    c.nr_order;
