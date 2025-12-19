SELECT
    t.title AS movie_title,
    a.name AS actor_name,
    c.note AS role_note,
    t.production_year,
    k.keyword AS movie_keyword,
    cn.name AS company_name,
    ci.kind AS company_type
FROM
    title t
JOIN
    complete_cast cc ON t.id = cc.movie_id
JOIN
    cast_info c ON cc.subject_id = c.id
JOIN
    aka_name a ON c.person_id = a.person_id
JOIN
    movie_keyword mk ON t.id = mk.movie_id
JOIN
    keyword k ON mk.keyword_id = k.id
JOIN
    movie_companies mc ON t.id = mc.movie_id
JOIN
    company_name cn ON mc.company_id = cn.id
JOIN
    company_type ci ON mc.company_type_id = ci.id
WHERE
    t.production_year >= 2000
ORDER BY
    t.production_year DESC, t.title;
