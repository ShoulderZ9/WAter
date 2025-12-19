SELECT 
    at.title AS movie_title,
    ak.name AS actor_name,
    ct.kind AS cast_type,
    cc.name AS company_name,
    m.info AS movie_info,
    kw.keyword AS movie_keyword
FROM 
    aka_title at
JOIN 
    cast_info ci ON at.movie_id = ci.movie_id
JOIN 
    aka_name ak ON ci.person_id = ak.person_id
JOIN 
    comp_cast_type ct ON ci.person_role_id = ct.id
JOIN 
    movie_companies mc ON at.movie_id = mc.movie_id
JOIN 
    company_name cc ON mc.company_id = cc.id
JOIN 
    movie_info m ON at.movie_id = m.movie_id
JOIN 
    movie_keyword mk ON at.movie_id = mk.movie_id
JOIN 
    keyword kw ON mk.keyword_id = kw.id
WHERE 
    at.production_year = 2023
ORDER BY 
    at.title, ak.name;
