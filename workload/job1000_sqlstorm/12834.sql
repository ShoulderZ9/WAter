SELECT
    a.id AS aka_id,
    a.name AS aka_name,
    t.id AS title_id,
    t.title AS title,
    t.production_year,
    c.person_role_id,
    p.id AS person_id,
    p.name AS person_name
FROM
    aka_name a
JOIN
    cast_info c ON a.person_id = c.person_id
JOIN
    title t ON c.movie_id = t.id
JOIN
    name p ON a.person_id = p.imdb_id
WHERE
    t.production_year BETWEEN 2000 AND 2020
ORDER BY
    t.production_year DESC, a.name;
