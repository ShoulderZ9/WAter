
WITH MovieDetails AS (
    SELECT 
        t.id AS title_id,
        t.title,
        t.production_year,
        COUNT(DISTINCT c.person_id) AS total_actors,
        STRING_AGG(DISTINCT ak.name, ', ') AS actor_names,
        SUM(CASE WHEN c.note IS NOT NULL THEN 1 ELSE 0 END) AS noted_cast
    FROM 
        aka_title t
    JOIN 
        complete_cast cc ON t.id = cc.movie_id
    JOIN 
        cast_info c ON cc.subject_id = c.id
    LEFT JOIN 
        aka_name ak ON c.person_id = ak.person_id
    GROUP BY 
        t.id, t.title, t.production_year
),
KeywordCounts AS (
    SELECT 
        mk.movie_id,
        COUNT(mk.keyword_id) AS total_keywords
    FROM 
        movie_keyword mk
    LEFT JOIN 
        title Title ON mk.movie_id = Title.id
    WHERE 
        Title.production_year BETWEEN 2000 AND 2020
    GROUP BY 
        mk.movie_id
)
SELECT 
    md.title,
    md.production_year,
    COALESCE(kc.total_keywords, 0) AS keyword_count,
    md.total_actors,
    md.actor_names,
    RANK() OVER (ORDER BY md.production_year DESC, md.total_actors DESC) AS movie_rank
FROM 
    MovieDetails md
LEFT JOIN 
    KeywordCounts kc ON md.title_id = kc.movie_id
WHERE 
    md.total_actors > 5
ORDER BY 
    md.production_year DESC, 
    keyword_count DESC, 
    md.title;
