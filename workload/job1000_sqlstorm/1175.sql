WITH MovieDetails AS (
    SELECT 
        a.title, 
        a.production_year, 
        COALESCE(cn.name, 'Unknown Company') AS company_name,
        COUNT(DISTINCT ci.person_id) AS num_cast_members,
        SUM(CASE WHEN ci.note IS NOT NULL THEN 1 ELSE 0 END) AS num_cast_notes
    FROM 
        aka_title a
    LEFT JOIN 
        movie_companies mc ON a.id = mc.movie_id
    LEFT JOIN 
        company_name cn ON mc.company_id = cn.id
    LEFT JOIN 
        complete_cast cc ON a.id = cc.movie_id
    LEFT JOIN 
        cast_info ci ON cc.subject_id = ci.person_id
    GROUP BY 
        a.title, 
        a.production_year, 
        cn.name
), 
RankedMovies AS (
    SELECT 
        title, 
        production_year, 
        company_name, 
        num_cast_members, 
        num_cast_notes,
        RANK() OVER (PARTITION BY production_year ORDER BY num_cast_members DESC) AS rank_within_year
    FROM 
        MovieDetails
)
SELECT 
    rm.title, 
    rm.production_year, 
    rm.company_name, 
    rm.num_cast_members, 
    rm.num_cast_notes
FROM 
    RankedMovies rm
WHERE 
    rm.rank_within_year <= 5 
    AND (rm.num_cast_notes > 0 OR rm.company_name IS NOT NULL)
ORDER BY 
    rm.production_year DESC, 
    rm.num_cast_members DESC;
