SELECT 
    t.title,
    a.name AS actor_name,
    p.info AS person_info,
    c.kind AS company_type,
    k.keyword AS movie_keyword
FROM 
    title t
JOIN 
    aka_title a_t ON t.id = a_t.movie_id
JOIN 
    cast_info c_i ON a_t.movie_id = c_i.movie_id
JOIN 
    aka_name a ON c_i.person_id = a.person_id
JOIN 
    person_info p ON a.person_id = p.person_id
JOIN 
    movie_companies m_c ON t.id = m_c.movie_id
JOIN 
    company_type c ON m_c.company_type_id = c.id
JOIN 
    movie_keyword m_k ON t.id = m_k.movie_id
JOIN 
    keyword k ON m_k.keyword_id = k.id
WHERE 
    c.kind = 'Production Company'
    AND p.info_type_id = (SELECT id FROM info_type WHERE info = 'Birthdate')
ORDER BY 
    t.production_year DESC, a.name;
