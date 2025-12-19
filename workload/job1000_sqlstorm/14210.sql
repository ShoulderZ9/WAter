SELECT
    ak.name AS aka_name,
    t.title AS movie_title,
    p.name AS person_name,
    r.role AS person_role,
    c.note AS cast_note,
    comp.name AS company_name,
    m.info AS movie_info
FROM
    aka_name ak
JOIN
    cast_info c ON ak.person_id = c.person_id
JOIN
    title t ON c.movie_id = t.id
JOIN
    name p ON c.person_id = p.imdb_id
JOIN
    role_type r ON c.role_id = r.id
JOIN
    movie_companies mc ON t.id = mc.movie_id
JOIN
    company_name comp ON mc.company_id = comp.id
JOIN
    movie_info m ON t.id = m.movie_id
WHERE
    t.production_year >= 2000
ORDER BY
    t.production_year DESC, ak.name;
