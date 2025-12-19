SELECT 
    a.name AS aka_name,
    t.title AS movie_title,
    c.person_role_id,
    inf.info AS movie_info,
    k.keyword AS movie_keyword
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    aka_title t ON c.movie_id = t.movie_id
JOIN 
    movie_info inf ON t.movie_id = inf.movie_id
JOIN 
    movie_keyword mk ON t.movie_id = mk.movie_id
JOIN 
    keyword k ON mk.keyword_id = k.id
WHERE 
    inf.info_type_id = (SELECT id FROM info_type WHERE info = 'tagline')
    AND t.production_year BETWEEN 2000 AND 2020
ORDER BY 
    t.production_year DESC, a.name;