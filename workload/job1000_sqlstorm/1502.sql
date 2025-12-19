
WITH RankedMovies AS (
    SELECT 
        a.id AS movie_id,
        a.title,
        a.production_year,
        ROW_NUMBER() OVER (PARTITION BY a.production_year ORDER BY a.production_year DESC) AS rn
    FROM 
        aka_title a
    WHERE 
        a.production_year IS NOT NULL
),
MovieDetails AS (
    SELECT 
        m.movie_id,
        m.title,
        COALESCE(c.name, 'Unknown Company') AS company_name,
        COUNT(DISTINCT k.id) AS keyword_count,
        SUM(CASE WHEN pi.info_type_id = 1 THEN 1 ELSE 0 END) AS awards_count
    FROM 
        RankedMovies m
    LEFT JOIN 
        movie_companies mc ON m.movie_id = mc.movie_id
    LEFT JOIN 
        company_name c ON mc.company_id = c.id
    LEFT JOIN 
        movie_keyword mk ON m.movie_id = mk.movie_id
    LEFT JOIN 
        keyword k ON mk.keyword_id = k.id
    LEFT JOIN 
        movie_info mi ON m.movie_id = mi.movie_id
    LEFT JOIN 
        person_info pi ON m.movie_id = pi.person_id
    WHERE 
        m.rn <= 10
    GROUP BY 
        m.movie_id, m.title, c.name
)
SELECT 
    md.movie_id,
    md.title,
    md.company_name,
    md.keyword_count,
    (CASE WHEN md.awards_count IS NULL THEN 'No Awards' ELSE CAST(md.awards_count AS TEXT) END) AS awards_info
FROM 
    MovieDetails md
WHERE 
    md.keyword_count > 2
ORDER BY 
    md.keyword_count DESC, 
    md.title ASC
LIMIT 20;
