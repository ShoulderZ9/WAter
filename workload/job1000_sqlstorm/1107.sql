WITH MovieTitles AS (
    SELECT 
        t.id AS title_id,
        t.title,
        t.production_year,
        ROW_NUMBER() OVER (PARTITION BY t.production_year ORDER BY t.title) AS rn
    FROM 
        aka_title t
    WHERE 
        t.production_year >= 2000
),
ActorsAndRoles AS (
    SELECT 
        a.id AS actor_id,
        n.name AS actor_name,
        c.movie_id,
        r.role AS actor_role,
        ROW_NUMBER() OVER (PARTITION BY c.movie_id ORDER BY a.id) AS role_order
    FROM 
        cast_info c
    JOIN 
        aka_name a ON c.person_id = a.person_id
    JOIN 
        role_type r ON c.role_id = r.id
    JOIN 
        name n ON a.person_id = n.imdb_id
),
MovieCompaniesInfo AS (
    SELECT 
        mc.movie_id,
        COUNT(DISTINCT mc.company_id) AS company_count,
        STRING_AGG(DISTINCT cn.name, ', ') AS company_names
    FROM 
        movie_companies mc
    JOIN 
        company_name cn ON mc.company_id = cn.id
    GROUP BY 
        mc.movie_id
),
FilteredMovies AS (
    SELECT 
        m.title_id,
        m.title,
        m.production_year,
        ACT.actor_name,
        COALESCE(MC.company_count, 0) AS company_count,
        MC.company_names
    FROM 
        MovieTitles m
    LEFT JOIN 
        ActorsAndRoles ACT ON m.title_id = ACT.movie_id
    LEFT JOIN 
        MovieCompaniesInfo MC ON m.title_id = MC.movie_id
    WHERE 
        m.rn = 1
)
SELECT 
    f.title,
    f.production_year,
    f.actor_name,
    f.company_count,
    f.company_names
FROM 
    FilteredMovies f
WHERE 
    f.company_count > 1
ORDER BY 
    f.production_year DESC, f.title ASC
LIMIT 10;
