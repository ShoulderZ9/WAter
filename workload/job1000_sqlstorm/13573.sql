SELECT 
    at.title AS movie_title,
    an.name AS actor_name,
    cc.kind AS cast_type,
    ti.info AS movie_info,
    k.keyword AS movie_keyword
FROM 
    aka_title at
JOIN 
    movie_companies mc ON at.id = mc.movie_id
JOIN 
    aka_name an ON mc.company_id = an.person_id
JOIN 
    cast_info ci ON at.id = ci.movie_id
JOIN 
    comp_cast_type cc ON ci.person_role_id = cc.id
JOIN 
    movie_info mi ON at.id = mi.movie_id
JOIN 
    info_type ti ON mi.info_type_id = ti.id
JOIN 
    movie_keyword mk ON at.id = mk.movie_id
JOIN 
    keyword k ON mk.keyword_id = k.id
WHERE 
    at.production_year >= 2000
ORDER BY 
    at.production_year DESC, at.title;
