SELECT
    a.name AS aka_name,
    t.title AS movie_title,
    p.name AS actor_name,
    r.role AS role_name,
    c.kind AS comp_cast_type,
    m.info AS movie_info
FROM
    aka_name a
JOIN
    cast_info ci ON a.person_id = ci.person_id
JOIN
    name p ON ci.person_id = p.id
JOIN
    role_type r ON ci.role_id = r.id
JOIN
    complete_cast cc ON ci.movie_id = cc.movie_id
JOIN
    title t ON cc.movie_id = t.id
JOIN
    movie_info m ON t.id = m.movie_id
JOIN
    movie_companies mc ON t.id = mc.movie_id
JOIN
    comp_cast_type c ON mc.company_type_id = c.id
WHERE
    m.info_type_id IN (SELECT id FROM info_type WHERE info = 'Budget')
ORDER BY
    t.production_year DESC, a.name;
