SELECT a.name AS actor_name, t.title AS movie_title, c.note AS role 
FROM cast_info c
JOIN aka_name a ON c.person_id = a.person_id
JOIN aka_title t ON c.movie_id = t.movie_id
WHERE t.production_year = 2023
ORDER BY a.name, t.title;
