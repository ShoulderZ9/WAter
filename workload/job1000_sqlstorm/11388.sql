SELECT
    n.name AS actor_name,
    a.title AS movie_title,
    a.production_year,
    c.kind AS cast_type,
    m.note AS movie_note
FROM
    aka_name AS n
JOIN
    cast_info AS ci ON n.person_id = ci.person_id
JOIN
    aka_title AS a ON ci.movie_id = a.movie_id
JOIN
    complete_cast AS cc ON a.id = cc.movie_id
JOIN
    role_type AS r ON ci.role_id = r.id
JOIN
    movie_info AS m ON a.id = m.movie_id
JOIN
    comp_cast_type AS c ON ci.person_role_id = c.id
WHERE
    a.production_year >= 2000
ORDER BY
    a.production_year DESC, n.name;
