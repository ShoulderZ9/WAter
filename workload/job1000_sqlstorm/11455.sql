SELECT 
    a.name AS aka_name, 
    t.title AS movie_title, 
    c.note AS cast_note, 
    cc.kind AS company_type, 
    k.keyword AS movie_keyword, 
    inf.info AS movie_info
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    aka_title t ON c.movie_id = t.movie_id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    company_type cc ON mc.company_type_id = cc.id
JOIN 
    movie_keyword mk ON t.id = mk.movie_id
JOIN 
    keyword k ON mk.keyword_id = k.id
JOIN 
    movie_info inf ON t.id = inf.movie_id
WHERE 
    inf.info_type_id = (
        SELECT id FROM info_type WHERE info = 'Rating' LIMIT 1
    )
ORDER BY 
    a.name, t.production_year DESC;
