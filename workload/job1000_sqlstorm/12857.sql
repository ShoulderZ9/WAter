SELECT
    a.id AS aka_id,
    a.name AS aka_name,
    t.title AS movie_title,
    ci.note AS cast_note,
    p.info AS person_info,
    c.name AS company_name,
    k.keyword AS movie_keyword
FROM
    aka_name a
JOIN
    cast_info ci ON a.person_id = ci.person_id
JOIN
    title t ON ci.movie_id = t.id
JOIN
    movie_companies mc ON t.id = mc.movie_id
JOIN
    company_name c ON mc.company_id = c.id
JOIN
    movie_keyword mk ON t.id = mk.movie_id
JOIN
    keyword k ON mk.keyword_id = k.id
JOIN
    person_info p ON a.person_id = p.person_id
WHERE
    t.production_year >= 2000
    AND c.country_code = 'USA'
ORDER BY
    a.name,
    t.title;