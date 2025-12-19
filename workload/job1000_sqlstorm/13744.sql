SELECT 
    at.title AS movie_title,
    ak.name AS actor_name,
    ci.note AS role_note,
    ci.nr_order AS role_order,
    ckt.kind AS cast_kind,
    mt.info AS movie_info
FROM 
    aka_title AS at
JOIN 
    movie_keyword AS mk ON at.id = mk.movie_id
JOIN 
    aka_name AS ak ON ak.id = mk.keyword_id
JOIN 
    cast_info AS ci ON ci.movie_id = at.id
JOIN 
    comp_cast_type AS ckt ON ckt.id = ci.person_role_id
JOIN 
    complete_cast AS cc ON cc.movie_id = at.id
JOIN 
    movie_info AS mt ON mt.movie_id = at.id
WHERE 
    at.production_year BETWEEN 2000 AND 2020
ORDER BY 
    at.title, ak.name;
