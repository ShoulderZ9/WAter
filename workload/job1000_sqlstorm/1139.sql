
WITH RankedTitles AS (
    SELECT 
        T.id AS title_id,
        T.title,
        T.production_year,
        ROW_NUMBER() OVER (PARTITION BY T.production_year ORDER BY T.title) AS title_rank
    FROM 
        title T
), TitleKeyword AS (
    SELECT 
        MT.movie_id,
        K.keyword,
        COUNT(DISTINCT K.id) AS keyword_count
    FROM 
        movie_keyword MT
    JOIN 
        keyword K ON MT.keyword_id = K.id
    GROUP BY 
        MT.movie_id, K.keyword
), ActorRoles AS (
    SELECT 
        CI.movie_id,
        MAX(RT.role) AS main_role
    FROM 
        cast_info CI
    JOIN 
        role_type RT ON CI.role_id = RT.id
    GROUP BY 
        CI.movie_id
), DetailedMovieInfo AS (
    SELECT 
        M.id AS movie_id,
        M.title,
        COALESCE(A.main_role, 'Unknown') AS role,
        COALESCE(TK.keyword_count, 0) AS keyword_count,
        M.production_year,
        R.title_rank
    FROM 
        aka_title M
    LEFT JOIN 
        ActorRoles A ON M.movie_id = A.movie_id
    LEFT JOIN 
        TitleKeyword TK ON M.movie_id = TK.movie_id
    LEFT JOIN 
        RankedTitles R ON M.id = R.title_id
    WHERE 
        M.production_year > 2000 
        AND (R.title_rank IS NULL OR R.title_rank <= 5)
)
SELECT 
    DMI.movie_id,
    DMI.title,
    DMI.role,
    DMI.keyword_count,
    DMI.production_year
FROM 
    DetailedMovieInfo DMI
JOIN 
    movie_info MI ON DMI.movie_id = MI.movie_id
WHERE 
    MI.info_type_id = (SELECT id FROM info_type WHERE info = 'Rating')
    AND MI.info IS NOT NULL
ORDER BY 
    DMI.keyword_count DESC, 
    DMI.title;
