WITH RankedMovies AS (
    SELECT 
        t.title,
        t.production_year,
        COUNT(DISTINCT c.person_id) AS casting_count,
        RANK() OVER (PARTITION BY t.production_year ORDER BY COUNT(DISTINCT c.person_id) DESC) AS rank_within_year
    FROM 
        aka_title t
    LEFT JOIN 
        complete_cast cc ON t.id = cc.movie_id
    LEFT JOIN 
        cast_info c ON cc.subject_id = c.id
    WHERE 
        t.production_year IS NOT NULL
    GROUP BY 
        t.title, t.production_year
),
TopRankedMovies AS (
    SELECT 
        title,
        production_year
    FROM 
        RankedMovies
    WHERE 
        rank_within_year <= 5
),
MovieKeywords AS (
    SELECT 
        t.title,
        k.keyword,
        ROW_NUMBER() OVER (PARTITION BY t.title ORDER BY k.keyword) AS keyword_rank
    FROM 
        aka_title t
    JOIN 
        movie_keyword mk ON t.id = mk.movie_id
    JOIN 
        keyword k ON mk.keyword_id = k.id
    WHERE 
        t.production_year >= 2000
)
SELECT 
    TR.title,
    TR.production_year,
    COALESCE(string_agg(mk.keyword, ', ' ORDER BY mk.keyword_rank), 'No keywords') AS keywords_list
FROM 
    TopRankedMovies TR
LEFT JOIN 
    MovieKeywords mk ON TR.title = mk.title
GROUP BY 
    TR.title, TR.production_year
ORDER BY 
    TR.production_year DESC, TR.title;
