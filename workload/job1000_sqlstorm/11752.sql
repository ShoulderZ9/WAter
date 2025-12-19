SELECT
    a.name AS aka_name,
    t.title AS movie_title,
    c.nr_order AS cast_order,
    n.name AS actor_name,
    ct.kind AS cast_type,
    mi.info AS movie_info
FROM
    aka_name a
JOIN
    cast_info c ON a.person_id = c.person_id
JOIN
    title t ON c.movie_id = t.id
JOIN
    name n ON a.person_id = n.imdb_id
JOIN
    comp_cast_type ct ON c.role_id = ct.id
LEFT JOIN
    movie_info mi ON t.id = mi.movie_id
WHERE
    t.production_year BETWEEN 2000 AND 2023
ORDER BY
    t.production_year DESC, c.nr_order;
