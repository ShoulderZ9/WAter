WITH RankedMovies AS (
    SELECT 
        title.title AS movie_title,
        title.production_year,
        COUNT(DISTINCT cast_info.person_id) AS num_cast_members,
        ROW_NUMBER() OVER (PARTITION BY title.production_year ORDER BY COUNT(DISTINCT cast_info.person_id) DESC) AS rn
    FROM 
        title
    JOIN 
        cast_info ON title.id = cast_info.movie_id
    GROUP BY 
        title.title, title.production_year
), 
PopularKeywords AS (
    SELECT 
        keyword.keyword,
        COUNT(movie_keyword.movie_id) AS keyword_count
    FROM 
        keyword
    JOIN 
        movie_keyword ON keyword.id = movie_keyword.keyword_id
    GROUP BY 
        keyword.keyword
    HAVING 
        COUNT(movie_keyword.movie_id) > 10
), 
MovieDetails AS (
    SELECT 
        t.title AS movie_title,
        a.name AS actor_name,
        m.info AS movie_info,
        r.role AS cast_role
    FROM 
        title t
    LEFT JOIN 
        cast_info ci ON t.id = ci.movie_id
    LEFT JOIN 
        aka_name a ON ci.person_id = a.person_id
    LEFT JOIN 
        role_type r ON ci.role_id = r.id
    LEFT JOIN 
        movie_info m ON t.id = m.movie_id
    WHERE 
        m.info_type_id = (SELECT id FROM info_type WHERE info = 'Tagline')
    AND 
        a.name IS NOT NULL
)
SELECT 
    md.movie_title,
    STRING_AGG(DISTINCT md.actor_name, ', ') AS actor_names,
    COUNT(DISTINCT md.movie_info) AS info_count,
    RANK() OVER (ORDER BY SUM(pq.keyword_count) DESC) AS popularity_rank
FROM 
    MovieDetails md
LEFT JOIN 
    PopularKeywords pq ON md.movie_title ILIKE '%' || pq.keyword || '%'
WHERE 
    md.movie_title IS NOT NULL
GROUP BY 
    md.movie_title
HAVING 
    COUNT(DISTINCT md.actor_name) > 5
ORDER BY 
    popularity_rank;
