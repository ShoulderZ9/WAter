SELECT 
    a.name AS aka_name,
    t.title AS movie_title,
    c.name AS character_name,
    p.name AS person_name,
    r.role AS role,
    cc.kind AS cast_type,
    mc.note AS company_note,
    mi.info AS movie_info,
    kw.keyword AS movie_keyword
FROM 
    aka_name a
JOIN 
    cast_info ci ON a.person_id = ci.person_id
JOIN 
    title t ON ci.movie_id = t.id
JOIN 
    char_name c ON ci.person_role_id = c.id
JOIN 
    name p ON a.person_id = p.imdb_id
JOIN 
    role_type r ON ci.role_id = r.id
JOIN 
    comp_cast_type cc ON ci.person_role_id = cc.id
JOIN 
    movie_companies mc ON t.id = mc.movie_id
JOIN 
    movie_info mi ON t.id = mi.movie_id
JOIN 
    movie_keyword mk ON t.id = mk.movie_id
JOIN 
    keyword kw ON mk.keyword_id = kw.id
WHERE 
    t.production_year BETWEEN 2000 AND 2020 
ORDER BY 
    t.production_year ASC, a.name ASC;
