SELECT 
    ta.title AS movie_title,
    an.name AS actor_name,
    ci.nr_order AS cast_order,
    cct.kind AS company_type,
    ti.info AS movie_info,
    kw.keyword AS movie_keyword,
    tt.kind AS movie_kind
FROM 
    aka_title ta
JOIN 
    complete_cast cc ON ta.id = cc.movie_id
JOIN 
    cast_info ci ON cc.subject_id = ci.person_id
JOIN 
    aka_name an ON ci.person_id = an.person_id
JOIN 
    movie_companies mc ON ta.id = mc.movie_id
JOIN 
    company_type cct ON mc.company_type_id = cct.id
JOIN 
    movie_info mi ON ta.id = mi.movie_id
JOIN 
    info_type ti ON mi.info_type_id = ti.id
JOIN 
    movie_keyword mk ON ta.id = mk.movie_id
JOIN 
    keyword kw ON mk.keyword_id = kw.id
JOIN 
    kind_type tt ON ta.kind_id = tt.id
WHERE 
    ta.production_year > 2000
ORDER BY 
    ta.production_year DESC, 
    an.name;