WITH MovieDetails AS (
    SELECT 
        t.title AS movie_title, 
        t.production_year, 
        t.kind_id, 
        COALESCE(c.name, 'Unknown') AS company_name, 
        COUNT(DISTINCT ci.person_id) AS cast_count,
        STRING_AGG(DISTINCT ak.name, ', ') AS aka_names
    FROM 
        aka_title AS t
    LEFT JOIN 
        movie_companies AS mc ON t.movie_id = mc.movie_id
    LEFT JOIN 
        company_name AS c ON mc.company_id = c.id
    JOIN 
        complete_cast AS cc ON t.movie_id = cc.movie_id
    LEFT JOIN 
        cast_info AS ci ON cc.subject_id = ci.person_id
    LEFT JOIN 
        aka_name AS ak ON ci.person_id = ak.person_id
    GROUP BY 
        t.id, t.title, t.production_year, t.kind_id, c.name
),
RankedMovies AS (
    SELECT 
        md.movie_title,
        md.production_year,
        md.company_name,
        md.cast_count,
        ROW_NUMBER() OVER (PARTITION BY md.production_year ORDER BY md.cast_count DESC) AS rank_within_year
    FROM 
        MovieDetails md
)
SELECT 
    r.movie_title,
    r.production_year,
    r.company_name,
    r.cast_count,
    r.rank_within_year
FROM 
    RankedMovies r
WHERE 
    r.rank_within_year <= 5 OR r.production_year IS NULL
ORDER BY 
    r.production_year DESC, r.rank_within_year;
