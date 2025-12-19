SELECT
    a.name AS aka_name,
    t.title AS movie_title,
    c.note AS cast_note,
    r.role AS role_type,
    m.info AS movie_info,
    k.keyword AS movie_keyword,
    cn.name AS company_name
FROM
    aka_name a
JOIN
    cast_info c ON a.person_id = c.person_id
JOIN
    title t ON c.movie_id = t.id
JOIN
    role_type r ON c.role_id = r.id
JOIN
    movie_info m ON t.id = m.movie_id
JOIN
    movie_keyword mk ON t.id = mk.movie_id
JOIN
    keyword k ON mk.keyword_id = k.id
JOIN
    movie_companies mc ON t.id = mc.movie_id
JOIN
    company_name cn ON mc.company_id = cn.id
WHERE
    m.info_type_id = (SELECT id FROM info_type WHERE info = 'Budget')
    AND t.production_year >= 2000
ORDER BY
    t.production_year DESC;
