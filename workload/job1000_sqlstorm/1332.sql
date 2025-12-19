
WITH ranked_movies AS (
    SELECT 
        t.id AS movie_id,
        t.title,
        t.production_year,
        ROW_NUMBER() OVER (PARTITION BY t.production_year ORDER BY COUNT(DISTINCT ci.person_id) DESC) AS rn
    FROM 
        aka_title t
    JOIN 
        complete_cast cc ON t.id = cc.movie_id
    JOIN 
        cast_info ci ON cc.subject_id = ci.id
    GROUP BY 
        t.id, t.title, t.production_year
),
popular_movies AS (
    SELECT 
        rm.movie_id,
        rm.title,
        rm.production_year
    FROM 
        ranked_movies rm
    WHERE 
        rm.rn <= 5
),
keyword_count AS (
    SELECT 
        mk.movie_id,
        COUNT(mk.keyword_id) AS keyword_count
    FROM 
        movie_keyword mk
    GROUP BY 
        mk.movie_id
),
company_movies AS (
    SELECT 
        mc.movie_id,
        STRING_AGG(cn.name, ', ') AS companies
    FROM 
        movie_companies mc
    JOIN 
        company_name cn ON mc.company_id = cn.id
    GROUP BY 
        mc.movie_id
)
SELECT 
    pm.title,
    pm.production_year,
    COALESCE(kc.keyword_count, 0) AS keyword_count,
    COALESCE(cm.companies, 'No production companies') AS production_companies,
    COUNT(DISTINCT ci.person_id) AS total_cast
FROM 
    popular_movies pm
LEFT JOIN 
    keyword_count kc ON pm.movie_id = kc.movie_id
LEFT JOIN 
    company_movies cm ON pm.movie_id = cm.movie_id
JOIN 
    complete_cast cc ON pm.movie_id = cc.movie_id
JOIN 
    cast_info ci ON cc.subject_id = ci.id
GROUP BY 
    pm.title, pm.production_year, kc.keyword_count, cm.companies
ORDER BY 
    pm.production_year DESC, total_cast DESC;
