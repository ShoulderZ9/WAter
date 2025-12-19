
WITH RankedMovies AS (
    SELECT 
        m.id AS movie_id,
        m.title,
        m.production_year,
        RANK() OVER (PARTITION BY m.production_year ORDER BY COUNT(c.id) DESC) AS rank_by_cast_count
    FROM 
        aka_title m
    LEFT JOIN 
        complete_cast cc ON m.id = cc.movie_id
    LEFT JOIN 
        cast_info c ON cc.subject_id = c.person_id
    GROUP BY 
        m.id, m.title, m.production_year
),
TopMovies AS (
    SELECT 
        r.movie_id,
        r.title,
        r.production_year
    FROM 
        RankedMovies r
    WHERE 
        r.rank_by_cast_count = 1
),
PersonRoles AS (
    SELECT 
        p.id AS person_id,
        p.name AS person_name,
        c.movie_id,
        rt.role
    FROM 
        aka_name p
    JOIN 
        cast_info c ON p.person_id = c.person_id
    JOIN 
        role_type rt ON c.role_id = rt.id
),
FilteredRoles AS (
    SELECT 
        pr.person_name,
        pr.movie_id,
        pr.role
    FROM 
        PersonRoles pr
    INNER JOIN 
        TopMovies tm ON pr.movie_id = tm.movie_id
    WHERE 
        pr.role IS NOT NULL
)
SELECT 
    tm.title AS movie_title,
    tm.production_year,
    STRING_AGG(DISTINCT fr.person_name, ', ') AS cast_members,
    COUNT(DISTINCT fr.role) AS unique_roles
FROM 
    TopMovies tm
LEFT JOIN 
    FilteredRoles fr ON tm.movie_id = fr.movie_id
GROUP BY 
    tm.movie_id,
    tm.title,
    tm.production_year
ORDER BY 
    tm.production_year DESC;
