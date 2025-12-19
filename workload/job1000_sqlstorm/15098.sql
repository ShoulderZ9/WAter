
SELECT 
    t.title AS movie_title,
    a.name AS actor_name,
    ci.nr_order AS actor_order
FROM 
    title t
JOIN 
    complete_cast cc ON t.id = cc.movie_id
JOIN 
    cast_info ci ON cc.subject_id = ci.id
JOIN 
    aka_name a ON ci.person_id = a.person_id
WHERE 
    t.production_year >= 2000
GROUP BY 
    t.title, a.name, ci.nr_order, t.production_year
ORDER BY 
    t.production_year DESC, 
    ci.nr_order;
