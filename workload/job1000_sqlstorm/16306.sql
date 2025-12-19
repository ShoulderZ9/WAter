SELECT 
    t.title, 
    a.name, 
    c.note, 
    k.keyword 
FROM 
    title t 
JOIN 
    movie_keyword mk ON t.id = mk.movie_id 
JOIN 
    keyword k ON mk.keyword_id = k.id 
JOIN 
    complete_cast cc ON t.id = cc.movie_id 
JOIN 
    aka_name a ON cc.subject_id = a.person_id 
JOIN 
    cast_info c ON a.id = c.person_id AND cc.movie_id = c.movie_id 
WHERE 
    t.production_year > 2000 
ORDER BY 
    t.title;
