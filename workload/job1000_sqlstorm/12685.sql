SELECT
    a.name AS aka_name,
    t.title AS movie_title,
    c.note AS cast_note,
    n.name AS person_name,
    m.info AS movie_additional_info
FROM
    aka_name a
JOIN
    cast_info c ON a.person_id = c.person_id
JOIN
    aka_title t ON c.movie_id = t.movie_id
JOIN
    name n ON a.person_id = n.imdb_id
JOIN
    movie_info m ON t.id = m.movie_id
WHERE
    t.production_year >= 2000
ORDER BY
    t.production_year DESC, a.name;
