
SELECT 
    t.title AS movie_title,
    a.name AS actor_name,
    r.role AS actor_role,
    t.production_year AS production_year
FROM
    title t
JOIN
    movie_companies mc ON t.id = mc.movie_id
JOIN
    company_name cn ON mc.company_id = cn.id
JOIN
    cast_info ci ON t.id = ci.movie_id
JOIN
    aka_name a ON ci.person_id = a.person_id
JOIN
    role_type r ON ci.role_id = r.id
WHERE
    cn.country_code = 'USA'
    AND t.production_year > 2000
GROUP BY
    t.title, a.name, r.role, t.production_year
ORDER BY
    t.production_year DESC;
