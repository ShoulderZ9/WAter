WITH movie_details AS (
    SELECT 
        t.id AS movie_id,
        t.title,
        t.production_year,
        COALESCE(k.keyword, 'No Keyword') AS keyword,
        COUNT(c.person_id) AS cast_count,
        COUNT(DISTINCT mc.company_id) AS company_count
    FROM 
        aka_title t
    LEFT JOIN 
        movie_keyword mk ON t.id = mk.movie_id
    LEFT JOIN 
        keyword k ON mk.keyword_id = k.id
    LEFT JOIN 
        complete_cast cc ON t.id = cc.movie_id
    LEFT JOIN 
        cast_info c ON cc.subject_id = c.id
    LEFT JOIN 
        movie_companies mc ON t.id = mc.movie_id
    GROUP BY 
        t.id, t.title, t.production_year, k.keyword
),
ranked_movies AS (
    SELECT 
        movie_id,
        title,
        production_year,
        keyword,
        cast_count,
        company_count,
        RANK() OVER (PARTITION BY production_year ORDER BY cast_count DESC, company_count DESC) AS rank
    FROM 
        movie_details
)
SELECT 
    rm.title,
    rm.production_year,
    rm.keyword,
    rm.cast_count,
    rm.company_count,
    CASE 
        WHEN rm.rank <= 5 THEN 'Top 5'
        ELSE 'Other'
    END AS ranking_category
FROM 
    ranked_movies rm
WHERE 
    rm.production_year BETWEEN 2000 AND 2020
    AND rm.cast_count IS NOT NULL
ORDER BY 
    rm.production_year, rm.rank;
