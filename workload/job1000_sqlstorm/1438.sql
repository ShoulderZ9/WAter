WITH RankedMovies AS (
    SELECT 
        t.id AS movie_id,
        t.title,
        t.production_year,
        ROW_NUMBER() OVER (PARTITION BY t.production_year ORDER BY COUNT(DISTINCT c.person_id) DESC) AS rank
    FROM 
        aka_title t
    LEFT JOIN 
        cast_info c ON t.id = c.movie_id
    GROUP BY 
        t.id, t.title, t.production_year
),
MovieDetails AS (
    SELECT 
        rm.movie_id,
        rm.title,
        rm.production_year,
        COALESCE(mci.company_count, 0) AS company_count,
        COALESCE(kwi.keyword_count, 0) AS keyword_count,
        COUNT(DISTINCT ci.person_id) AS cast_count
    FROM 
        RankedMovies rm
    LEFT JOIN (
        SELECT 
            mc.movie_id,
            COUNT(*) AS company_count
        FROM 
            movie_companies mc
        GROUP BY 
            mc.movie_id
    ) mci ON rm.movie_id = mci.movie_id
    LEFT JOIN (
        SELECT 
            mk.movie_id,
            COUNT(*) AS keyword_count
        FROM 
            movie_keyword mk
        GROUP BY 
            mk.movie_id
    ) kwi ON rm.movie_id = kwi.movie_id
    LEFT JOIN 
        cast_info ci ON rm.movie_id = ci.movie_id
    WHERE 
        rm.rank <= 5
    GROUP BY 
        rm.movie_id, rm.title, rm.production_year, mci.company_count, kwi.keyword_count
),
FilteredMovies AS (
    SELECT 
        md.movie_id,
        md.title,
        md.production_year,
        md.company_count,
        md.keyword_count,
        md.cast_count,
        CASE 
            WHEN md.cast_count = 0 THEN 'No Cast'
            ELSE 'Has Cast'
        END AS cast_info
    FROM 
        MovieDetails md
    WHERE 
        md.production_year > 2000 AND 
        md.keyword_count > 1
)
SELECT 
    f.movie_id,
    f.title,
    f.production_year,
    f.company_count,
    f.keyword_count,
    f.cast_count,
    f.cast_info
FROM 
    FilteredMovies f
ORDER BY 
    f.production_year DESC, f.company_count DESC;
