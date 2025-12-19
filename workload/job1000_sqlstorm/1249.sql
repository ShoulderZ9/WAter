
WITH ActorMovieCount AS (
    SELECT 
        ca.person_id,
        COUNT(DISTINCT ci.movie_id) AS movie_count
    FROM 
        cast_info ci
    JOIN 
        aka_name ca ON ci.person_id = ca.person_id
    GROUP BY 
        ca.person_id
),
MostProlificActors AS (
    SELECT 
        amc.person_id,
        amc.movie_count
    FROM 
        ActorMovieCount amc
    WHERE 
        amc.movie_count = (SELECT MAX(movie_count) FROM ActorMovieCount)
),
ActorDetails AS (
    SELECT 
        na.name AS actor_name,
        na.surname_pcode,
        ci.movie_id,
        mt.title AS movie_title,
        mt.production_year
    FROM 
        MostProlificActors mpa
    JOIN 
        aka_name na ON mpa.person_id = na.person_id
    JOIN 
        cast_info ci ON na.person_id = ci.person_id
    JOIN 
        aka_title mt ON ci.movie_id = mt.movie_id
)
SELECT 
    ad.actor_name,
    ad.surname_pcode,
    COUNT(ad.movie_id) AS total_movies,
    STRING_AGG(ad.movie_title, ', ') AS movie_titles,
    AVG(COALESCE(ad.production_year, 0)) AS average_production_year
FROM 
    ActorDetails ad
GROUP BY 
    ad.actor_name, ad.surname_pcode
ORDER BY 
    total_movies DESC
LIMIT 10;
