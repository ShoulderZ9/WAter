SELECT 
    t.title AS movie_title,
    ak.name AS actor_name,
    c.kind AS company_type,
    m.info AS movie_info
FROM 
    title t
JOIN 
    aka_title ak_t ON ak_t.movie_id = t.id
JOIN 
    aka_name ak ON ak.person_id = ak_t.id
JOIN 
    cast_info ci ON ci.movie_id = t.id AND ci.person_id = ak.person_id
JOIN 
    movie_companies mc ON mc.movie_id = t.id
JOIN 
    company_type c ON mc.company_type_id = c.id
JOIN 
    movie_info m ON m.movie_id = t.id
WHERE 
    t.production_year > 2000
ORDER BY 
    t.production_year DESC, ak.name;
