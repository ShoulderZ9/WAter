SELECT 
    a.name AS aka_name,
    t.title AS movie_title,
    c.nr_order AS cast_order,
    p.info AS person_info,
    k.keyword AS movie_keyword,
    ct.kind AS company_type,
    ti.info AS movie_info
FROM title t
JOIN movie_link ml ON t.id = ml.movie_id
JOIN title linked_t ON ml.linked_movie_id = linked_t.id
JOIN movie_keyword mk ON t.id = mk.movie_id
JOIN keyword k ON mk.keyword_id = k.id
JOIN complete_cast cc ON t.id = cc.movie_id
JOIN cast_info c ON cc.subject_id = c.id
JOIN aka_name a ON c.person_id = a.person_id
JOIN person_info p ON a.person_id = p.person_id
JOIN movie_companies mc ON t.id = mc.movie_id
JOIN company_type ct ON mc.company_type_id = ct.id
JOIN movie_info mi ON t.id = mi.movie_id
JOIN info_type ti ON mi.info_type_id = ti.id
WHERE t.production_year >= 2000
ORDER BY t.production_year DESC, c.nr_order;
