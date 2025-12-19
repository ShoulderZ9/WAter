SELECT a.name, t.title, c.note, m.info
FROM aka_name a
JOIN cast_info c ON a.person_id = c.person_id
JOIN aka_title t ON c.movie_id = t.movie_id
JOIN movie_info m ON t.id = m.movie_id
WHERE m.info_type_id = (SELECT id FROM info_type WHERE info = 'Director');
