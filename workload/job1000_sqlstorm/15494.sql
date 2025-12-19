SELECT 
    t.title, 
    ak.name AS actor_name, 
    c.note AS character_note 
FROM 
    title t 
JOIN 
    complete_cast cc ON t.id = cc.movie_id 
JOIN 
    cast_info c ON cc.subject_id = c.id 
JOIN 
    aka_name ak ON c.person_id = ak.person_id 
WHERE 
    t.production_year >= 2000 
ORDER BY 
    t.production_year DESC;
