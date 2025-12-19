SELECT 
    a.name AS aka_name, 
    t.title AS movie_title, 
    c.note AS cast_note, 
    k.keyword AS movie_keyword, 
    m.info AS movie_info, 
    n.name AS person_name, 
    r.role AS role_type
FROM 
    aka_name a
JOIN 
    cast_info c ON a.person_id = c.person_id
JOIN 
    title t ON c.movie_id = t.id
JOIN 
    movie_keyword mk ON t.id = mk.movie_id
JOIN 
    keyword k ON mk.keyword_id = k.id
JOIN 
    movie_info m ON t.id = m.movie_id
JOIN 
    name n ON c.person_id = n.imdb_id
JOIN 
    role_type r ON c.role_id = r.id
ORDER BY 
    t.production_year DESC, 
    a.name;
