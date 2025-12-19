
WITH RankedMovies AS (
    SELECT 
        t.id AS movie_id,
        t.title,
        t.production_year,
        COUNT(c.person_id) AS num_cast_members,
        ROW_NUMBER() OVER (PARTITION BY t.production_year ORDER BY COUNT(c.person_id) DESC) AS rank
    FROM 
        aka_title AS t
    LEFT JOIN 
        complete_cast AS cc ON t.id = cc.movie_id
    LEFT JOIN 
        cast_info AS c ON cc.subject_id = c.person_id
    GROUP BY 
        t.id, t.title, t.production_year
),
MovieKeywords AS (
    SELECT 
        mk.movie_id,
        STRING_AGG(k.keyword, ', ') AS keywords
    FROM 
        movie_keyword AS mk
    JOIN 
        keyword AS k ON mk.keyword_id = k.id
    GROUP BY 
        mk.movie_id
),
TopMovies AS (
    SELECT 
        rm.movie_id,
        rm.title,
        rm.production_year,
        rm.num_cast_members,
        mk.keywords
    FROM 
        RankedMovies AS rm
    LEFT JOIN 
        MovieKeywords AS mk ON rm.movie_id = mk.movie_id
    WHERE 
        rm.rank <= 10
)
SELECT 
    tm.movie_id,
    tm.title,
    tm.production_year,
    tm.num_cast_members,
    COALESCE(tm.keywords, 'No Keywords') AS keywords,
    (SELECT COUNT(*) 
     FROM movie_info mi 
     WHERE mi.movie_id = tm.movie_id AND mi.info_type_id = (SELECT id 
                                                           FROM info_type 
                                                           WHERE info = 'Summary')) AS summary_count
FROM 
    TopMovies AS tm
ORDER BY 
    tm.production_year DESC, 
    tm.num_cast_members DESC;
