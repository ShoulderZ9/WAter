SELECT 
    a.id AS aka_id,
    a.name AS aka_name,
    t.title AS movie_title,
    c.person_role_id,
    n.name AS actor_name,
    p.info AS actor_info
FROM
    aka_name a
JOIN
    cast_info c ON a.person_id = c.person_id
JOIN
    title t ON c.movie_id = t.id
JOIN
    name n ON a.person_id = n.imdb_id
LEFT JOIN
    person_info p ON n.id = p.person_id
WHERE
    t.production_year >= 2000
ORDER BY
    t.production_year DESC, a.name;
