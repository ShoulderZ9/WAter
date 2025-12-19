WITH RankedTitles AS (
    SELECT 
        a.name AS actor_name,
        t.title AS movie_title,
        t.production_year,
        ROW_NUMBER() OVER (PARTITION BY a.id ORDER BY t.production_year DESC) AS rn
    FROM 
        aka_name a
    JOIN 
        cast_info c ON a.person_id = c.person_id
    JOIN 
        aka_title t ON c.movie_id = t.id
    WHERE 
        t.production_year IS NOT NULL
),
RecentMovies AS (
    SELECT 
        actor_name, 
        movie_title, 
        production_year
    FROM 
        RankedTitles
    WHERE 
        rn <= 3
),
CompanyMovies AS (
    SELECT 
        m.movie_id,
        c.name AS company_name
    FROM 
        movie_companies m
    JOIN 
        company_name c ON m.company_id = c.id
    WHERE 
        c.country_code = 'USA'
)
SELECT 
    r.actor_name,
    STRING_AGG(r.movie_title, ', ') AS recent_movies,
    COUNT(DISTINCT cm.company_name) AS production_companies
FROM 
    RecentMovies r
LEFT JOIN 
    CompanyMovies cm ON r.movie_title = (SELECT title FROM aka_title WHERE id = cm.movie_id)
GROUP BY 
    r.actor_name
HAVING 
    COUNT(DISTINCT cm.company_name) > 0
ORDER BY 
    r.actor_name ASC;
