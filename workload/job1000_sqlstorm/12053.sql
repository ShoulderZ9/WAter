SELECT
    t.title,
    a.name AS actor_name,
    c.kind AS cast_type,
    k.keyword AS movie_keyword,
    p.info AS person_info
FROM
    title t
JOIN
    movie_keyword mk ON t.id = mk.movie_id
JOIN
    keyword k ON mk.keyword_id = k.id
JOIN
    complete_cast cc ON t.id = cc.movie_id
JOIN
    cast_info ci ON cc.subject_id = ci.id
JOIN
    aka_name a ON ci.person_id = a.person_id
JOIN
    comp_cast_type c ON ci.person_role_id = c.id
JOIN
    person_info p ON a.person_id = p.person_id
ORDER BY
    t.title, a.name;
