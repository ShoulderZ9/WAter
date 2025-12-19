WITH RankedMovies AS (
    SELECT 
        a.id AS movie_id,
        a.title,
        a.production_year,
        ROW_NUMBER() OVER (PARTITION BY a.production_year ORDER BY a.title) AS rn
    FROM 
        aka_title a
    WHERE 
        a.production_year IS NOT NULL
),
CastInfoWithRole AS (
    SELECT 
        ci.movie_id,
        ci.person_id,
        ci.role_id,
        rt.role AS role_name
    FROM 
        cast_info ci
    LEFT JOIN 
        role_type rt ON ci.role_id = rt.id
),
CompanyDetails AS (
    SELECT 
        mc.movie_id,
        cn.name AS company_name,
        ct.kind AS company_type
    FROM 
        movie_companies mc
    JOIN 
        company_name cn ON mc.company_id = cn.id
    JOIN 
        company_type ct ON mc.company_type_id = ct.id
),
MovieKeywords AS (
    SELECT 
        mk.movie_id,
        STRING_AGG(k.keyword, ', ') AS keywords
    FROM 
        movie_keyword mk
    JOIN 
        keyword k ON mk.keyword_id = k.id
    GROUP BY 
        mk.movie_id
)
SELECT 
    rm.title,
    rm.production_year,
    COUNT(DISTINCT ci.person_id) AS cast_count,
    cd.company_name,
    cd.company_type,
    mk.keywords
FROM 
    RankedMovies rm
LEFT JOIN 
    CastInfoWithRole ci ON rm.movie_id = ci.movie_id
LEFT JOIN 
    CompanyDetails cd ON rm.movie_id = cd.movie_id
LEFT JOIN 
    MovieKeywords mk ON rm.movie_id = mk.movie_id
WHERE 
    rm.rn <= 5 AND 
    (cd.company_type IS NULL OR cd.company_type != 'Distributor')
GROUP BY 
    rm.movie_id, rm.title, rm.production_year, cd.company_name, cd.company_type, mk.keywords
ORDER BY 
    rm.production_year DESC, rm.title;
