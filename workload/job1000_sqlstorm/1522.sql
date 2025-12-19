
WITH RankedMovies AS (
    SELECT 
        a.title,
        a.production_year,
        k.keyword,
        ROW_NUMBER() OVER (PARTITION BY k.keyword ORDER BY a.production_year DESC) AS rank
    FROM 
        aka_title a
    JOIN 
        movie_keyword mk ON a.id = mk.movie_id
    JOIN 
        keyword k ON mk.keyword_id = k.id
    WHERE 
        a.production_year IS NOT NULL
),
CompanyRoles AS (
    SELECT 
        mc.movie_id,
        ct.kind AS company_type,
        COUNT(DISTINCT mc.company_id) AS company_count
    FROM 
        complete_cast cc
    JOIN 
        movie_companies mc ON cc.movie_id = mc.movie_id
    JOIN 
        company_type ct ON mc.company_type_id = ct.id
    GROUP BY 
        mc.movie_id, ct.kind
),
PersonMovieInfo AS (
    SELECT 
        p.person_id,
        COUNT(DISTINCT ci.movie_id) AS movie_count,
        STRING_AGG(DISTINCT a.name, ', ') AS actor_names
    FROM 
        cast_info ci
    JOIN 
        aka_name a ON ci.person_id = a.person_id
    JOIN 
        person_info p ON ci.person_id = p.person_id
    WHERE 
        p.info_type_id = (SELECT id FROM info_type WHERE info = 'Birth Year')
    GROUP BY 
        p.person_id
)
SELECT 
    rm.title,
    rm.production_year,
    rm.keyword,
    cr.company_type,
    cr.company_count,
    pm.actor_names,
    pm.movie_count
FROM 
    RankedMovies rm
LEFT JOIN 
    CompanyRoles cr ON rm.title = (SELECT title FROM aka_title WHERE id = cr.movie_id LIMIT 1)
LEFT JOIN 
    PersonMovieInfo pm ON pm.movie_count > 0
WHERE 
    rm.rank <= 5
ORDER BY 
    rm.production_year DESC, 
    rm.keyword;
