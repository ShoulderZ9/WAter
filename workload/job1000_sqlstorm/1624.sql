WITH RankedMovies AS (
    SELECT 
        mt.title,
        mt.production_year,
        COUNT(ci.person_id) AS actor_count,
        ROW_NUMBER() OVER (PARTITION BY mt.production_year ORDER BY COUNT(ci.person_id) DESC) AS rank
    FROM 
        aka_title mt
    LEFT JOIN 
        cast_info ci ON mt.id = ci.movie_id
    GROUP BY 
        mt.id, mt.title, mt.production_year
),
PopularActors AS (
    SELECT 
        an.name,
        COUNT(DISTINCT ci.movie_id) AS movie_count
    FROM 
        aka_name an
    JOIN 
        cast_info ci ON an.person_id = ci.person_id
    GROUP BY 
        an.id, an.name
    HAVING 
        COUNT(DISTINCT ci.movie_id) > 5
),
TitleDetails AS (
    SELECT 
        mt.title,
        CASE 
            WHEN mt.production_year IS NULL THEN 'Unknown Year'
            ELSE CAST(mt.production_year AS VARCHAR)
        END AS production_year,
        COALESCE(kw.keyword, 'No Keywords') AS keyword
    FROM 
        aka_title mt
    LEFT JOIN 
        movie_keyword mk ON mt.id = mk.movie_id
    LEFT JOIN 
        keyword kw ON mk.keyword_id = kw.id
)
SELECT 
    rd.title,
    rd.production_year,
    rd.keyword,
    pa.name AS popular_actor,
    pa.movie_count,
    r.actor_count
FROM 
    RankedMovies r
JOIN 
    TitleDetails rd ON r.title = rd.title
LEFT JOIN 
    PopularActors pa ON pa.movie_count > 10
WHERE 
    r.rank <= 10 AND
    (rd.keyword LIKE '%Drama%' OR rd.keyword IS NULL)
ORDER BY 
    rd.production_year DESC, r.actor_count DESC;
