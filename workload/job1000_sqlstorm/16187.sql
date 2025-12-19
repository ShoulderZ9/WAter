SELECT 
    t.title, 
    a.name AS actor_name, 
    k.keyword AS movie_keyword 
FROM 
    title t 
JOIN 
    movie_keyword mk ON t.id = mk.movie_id 
JOIN 
    keyword k ON mk.keyword_id = k.id 
JOIN 
    cast_info ci ON t.id = ci.movie_id 
JOIN 
    aka_name a ON ci.person_id = a.person_id 
WHERE 
    t.production_year = 2020;
