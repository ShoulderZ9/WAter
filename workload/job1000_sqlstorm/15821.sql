SELECT t.title, a.name, c.note
FROM title t
JOIN complete_cast cc ON t.id = cc.movie_id
JOIN aka_name a ON cc.subject_id = a.person_id
JOIN cast_info c ON a.person_id = c.person_id AND cc.movie_id = c.movie_id
WHERE t.production_year > 2000
ORDER BY t.production_year DESC;
