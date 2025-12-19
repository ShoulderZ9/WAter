SELECT 
    a.title,
    a.production_year,
    ak.name AS aka_name,
    c.nr_order,
    r.role,
    p.info AS person_info,
    k.keyword
FROM 
    aka_title a
JOIN 
    movie_keyword mk ON a.id = mk.movie_id
JOIN 
    keyword k ON mk.keyword_id = k.id
JOIN 
    complete_cast cc ON a.id = cc.movie_id
JOIN 
    cast_info c ON cc.subject_id = c.id
JOIN 
    role_type r ON c.role_id = r.id
JOIN 
    aka_name ak ON c.person_id = ak.person_id
JOIN 
    person_info p ON ak.person_id = p.person_id
WHERE 
    a.production_year > 2000
ORDER BY 
    a.production_year DESC, a.title;
