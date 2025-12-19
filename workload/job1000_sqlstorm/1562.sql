WITH RankedTitles AS (
    SELECT 
        a.title, 
        a.production_year, 
        ROW_NUMBER() OVER (PARTITION BY a.production_year ORDER BY a.production_year DESC) as YearRank
    FROM 
        aka_title a
    WHERE 
        a.production_year IS NOT NULL
),
FilteredMovies AS (
    SELECT 
        t.title,
        c.name AS company_name,
        ARRAY_AGG(DISTINCT k.keyword) AS keywords,
        COUNT(DISTINCT ci.person_id) AS actor_count,
        MAX(t.production_year) AS last_production_year
    FROM 
        title t
    JOIN 
        movie_info mi ON t.id = mi.movie_id
    LEFT JOIN 
        movie_companies mc ON t.id = mc.movie_id
    LEFT JOIN 
        company_name c ON mc.company_id = c.id
    LEFT JOIN 
        movie_keyword mk ON t.id = mk.movie_id
    LEFT JOIN 
        keyword k ON mk.keyword_id = k.id
    LEFT JOIN 
        complete_cast cc ON t.id = cc.movie_id
    LEFT JOIN 
        cast_info ci ON cc.subject_id = ci.id
    WHERE 
        mi.info_type_id IN (SELECT id FROM info_type WHERE info = 'summary')
        AND (c.country_code IS NULL OR c.country_code != 'USA')
    GROUP BY 
        t.title, c.name
),
FinalResults AS (
    SELECT 
        ft.title, 
        ft.company_name, 
        ft.keywords, 
        ft.actor_count,
        rt.YearRank,
        CASE 
            WHEN ft.actor_count > 10 THEN 'High'
            WHEN ft.actor_count BETWEEN 6 AND 10 THEN 'Medium'
            ELSE 'Low'
        END AS ActorDiversity
    FROM 
        FilteredMovies ft
    LEFT JOIN 
        RankedTitles rt ON ft.title = rt.title
    WHERE 
        rt.YearRank <= 5
)
SELECT 
    title,
    company_name,
    keywords,
    actor_count,
    ActorDiversity
FROM 
    FinalResults
ORDER BY 
    actor_count DESC NULLS LAST;
