WITH RankedMovies AS (
    SELECT 
        t.id AS movie_id,
        t.title,
        t.production_year,
        RANK() OVER (PARTITION BY t.production_year ORDER BY COUNT(ci.person_id) DESC) AS rank_num
    FROM 
        aka_title t
    LEFT JOIN 
        complete_cast cc ON t.id = cc.movie_id
    LEFT JOIN 
        cast_info ci ON cc.subject_id = ci.person_id
    GROUP BY 
        t.id, t.title, t.production_year
),
PopularKeywords AS (
    SELECT 
        mk.movie_id,
        STRING_AGG(k.keyword, ', ') AS keywords
    FROM 
        movie_keyword mk
    JOIN 
        keyword k ON mk.keyword_id = k.id
    GROUP BY 
        mk.movie_id
),
TopRoles AS (
    SELECT 
        ci.role_id,
        rt.role,
        COUNT(ci.id) AS role_count
    FROM 
        cast_info ci
    JOIN 
        role_type rt ON ci.role_id = rt.id
    GROUP BY 
        ci.role_id, rt.role
    HAVING 
        COUNT(ci.id) > 10
)
SELECT 
    rm.movie_id,
    rm.title,
    rm.production_year,
    COALESCE(pk.keywords, 'No Keywords') AS keywords,
    tr.role,
    tr.role_count,
    COUNT(DISTINCT ci.person_id) AS total_cast
FROM 
    RankedMovies rm
LEFT JOIN 
    PopularKeywords pk ON rm.movie_id = pk.movie_id
LEFT JOIN 
    cast_info ci ON rm.movie_id = ci.movie_id
LEFT JOIN 
    TopRoles tr ON ci.role_id = tr.role_id
WHERE 
    rm.rank_num = 1 AND
    (rm.production_year BETWEEN 1990 AND 2020)
GROUP BY 
    rm.movie_id, rm.title, rm.production_year, pk.keywords, tr.role, tr.role_count
ORDER BY 
    rm.production_year DESC, total_cast DESC;
