WITH ranked_movies AS (
    SELECT 
        m.id AS movie_id,
        m.title,
        m.production_year,
        ROW_NUMBER() OVER (PARTITION BY m.production_year ORDER BY COUNT(c.person_id) DESC) AS rn
    FROM 
        aka_title AS m
    LEFT JOIN 
        cast_info AS c ON m.id = c.movie_id
    GROUP BY 
        m.id, m.title, m.production_year
),
top_movies AS (
    SELECT 
        movie_id,
        title,
        production_year
    FROM 
        ranked_movies
    WHERE 
        rn <= 5
),
company_titles AS (
    SELECT 
        mc.movie_id,
        STRING_AGG(cn.name, ', ') AS company_names
    FROM 
        movie_companies AS mc
    JOIN 
        company_name AS cn ON mc.company_id = cn.id
    GROUP BY 
        mc.movie_id
),
keyword_titles AS (
    SELECT 
        mk.movie_id,
        STRING_AGG(k.keyword, ', ') AS keywords
    FROM 
        movie_keyword AS mk
    JOIN 
        keyword AS k ON mk.keyword_id = k.id
    GROUP BY 
        mk.movie_id
)
SELECT 
    tm.title,
    tm.production_year,
    ct.company_names,
    kt.keywords
FROM 
    top_movies AS tm
LEFT JOIN 
    company_titles AS ct ON tm.movie_id = ct.movie_id
LEFT JOIN 
    keyword_titles AS kt ON tm.movie_id = kt.movie_id
WHERE 
    tm.production_year >= 2000
ORDER BY 
    tm.production_year DESC, 
    tm.title ASC;
