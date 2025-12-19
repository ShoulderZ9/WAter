SELECT 
    a.name AS aka_name, 
    c.note AS cast_note, 
    t.title AS movie_title, 
    p.info AS person_info, 
    m.info AS movie_info 
FROM 
    aka_name a 
JOIN 
    cast_info c ON a.person_id = c.person_id 
JOIN 
    title t ON c.movie_id = t.id 
JOIN 
    person_info p ON a.person_id = p.person_id 
JOIN 
    movie_info m ON t.id = m.movie_id 
WHERE 
     m.info_type_id = (SELECT id FROM info_type WHERE info = 'Box Office') 
     AND t.production_year > 2000 
ORDER BY 
    t.production_year DESC, 
    a.name;