SELECT
    a.name AS aka_name,
    t.title AS movie_title,
    p.info AS person_info,
    c.kind AS company_type,
    k.keyword AS movie_keyword
FROM
    aka_name a
JOIN
    cast_info ci ON a.person_id = ci.person_id
JOIN
    title t ON ci.movie_id = t.id
JOIN
    movie_info mi ON t.id = mi.movie_id
JOIN
    person_info p ON ci.person_id = p.person_id
JOIN
    movie_companies mc ON t.id = mc.movie_id
JOIN
    company_type c ON mc.company_type_id = c.id
JOIN
    movie_keyword mk ON t.id = mk.movie_id
JOIN
    keyword k ON mk.keyword_id = k.id
WHERE
    t.production_year >= 2000
    AND p.info_type_id = (SELECT id FROM info_type WHERE info = 'Bio')
ORDER BY
    t.production_year DESC, a.name;
