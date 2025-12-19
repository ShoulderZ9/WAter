WITH RankedMovies AS (
    SELECT 
        t.id AS movie_id,
        t.title,
        t.production_year,
        ROW_NUMBER() OVER (PARTITION BY t.production_year ORDER BY t.production_year DESC) AS ranking
    FROM 
        aka_title t
    WHERE 
        t.production_year IS NOT NULL
),
DetailedCast AS (
    SELECT 
        c.movie_id,
        a.name AS actor_name,
        r.role AS role_name,
        COALESCE(n.gender, 'U') AS actor_gender
    FROM 
        cast_info c
    JOIN 
        aka_name a ON c.person_id = a.person_id
    JOIN 
        role_type r ON c.role_id = r.id
    LEFT JOIN 
        name n ON a.person_id = n.imdb_id
),
CompanyData AS (
    SELECT 
        mc.movie_id,
        cn.name AS company_name,
        ct.kind AS company_type,
        COUNT(DISTINCT mc.company_id) AS total_companies
    FROM 
        movie_companies mc
    JOIN 
        company_name cn ON mc.company_id = cn.id
    JOIN 
        company_type ct ON mc.company_type_id = ct.id
    GROUP BY 
        mc.movie_id, cn.name, ct.kind
),
FinalOutput AS (
    SELECT 
        rm.movie_id,
        rm.title,
        rm.production_year,
        dc.actor_name,
        dc.role_name,
        dc.actor_gender,
        cd.company_name,
        cd.company_type,
        cd.total_companies
    FROM 
        RankedMovies rm
    LEFT JOIN 
        DetailedCast dc ON rm.movie_id = dc.movie_id
    LEFT JOIN 
        CompanyData cd ON rm.movie_id = cd.movie_id
    WHERE 
        rm.ranking <= 5 AND
        (dc.actor_gender = 'M' OR dc.actor_gender = 'F')
)

SELECT 
    movie_id,
    title,
    production_year,
    STRING_AGG(DISTINCT actor_name || ' as ' || role_name, ', ') AS actors,
    STRING_AGG(DISTINCT company_name || ' (' || company_type || ')', '; ') AS movie_companies
FROM 
    FinalOutput
GROUP BY 
    movie_id, title, production_year
ORDER BY 
    production_year DESC;
