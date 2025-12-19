
WITH RankedMovies AS (
    SELECT 
        at.title,
        at.production_year,
        COUNT(DISTINCT mci.company_id) AS company_count,
        ROW_NUMBER() OVER (PARTITION BY at.production_year ORDER BY COUNT(DISTINCT mci.company_id) DESC) AS rank_by_companies
    FROM 
        aka_title at
    LEFT JOIN 
        movie_companies mci ON at.id = mci.movie_id
    GROUP BY 
        at.title, at.production_year
),
TopMovies AS (
    SELECT 
        title, 
        production_year
    FROM 
        RankedMovies
    WHERE 
        rank_by_companies <= 5
),
ActorCounts AS (
    SELECT 
        ct.kind AS actor_type,
        COUNT(DISTINCT ci.person_id) AS actor_count,
        mt.production_year
    FROM 
        cast_info ci
    JOIN 
        comp_cast_type ct ON ci.person_role_id = ct.id
    JOIN 
        aka_title mt ON ci.movie_id = mt.id
    GROUP BY 
        ct.kind, mt.production_year
)
SELECT 
    tm.title,
    tm.production_year,
    COALESCE(ac.actor_count, 0) AS actor_count,
    rm.company_count
FROM 
    TopMovies tm
LEFT JOIN 
    RankedMovies rm ON tm.title = rm.title AND tm.production_year = rm.production_year
LEFT JOIN 
    ActorCounts ac ON tm.production_year = ac.production_year
ORDER BY 
    tm.production_year DESC, tm.title;
