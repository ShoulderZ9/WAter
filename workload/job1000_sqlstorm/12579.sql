SELECT
    a.id AS aka_id,
    a.name AS aka_name,
    t.title AS movie_title,
    c.note AS cast_note,
    r.role AS person_role,
    p.info AS person_info,
    m.info AS movie_info
FROM
    aka_name a
JOIN
    cast_info c ON a.person_id = c.person_id
JOIN
    title t ON c.movie_id = t.id
JOIN
    role_type r ON c.role_id = r.id
JOIN
    person_info p ON a.person_id = p.person_id
JOIN
    movie_info m ON t.id = m.movie_id
WHERE
    t.production_year > 2000
    AND m.info_type_id = (SELECT id FROM info_type WHERE info = 'Rating')
ORDER BY
    t.title;