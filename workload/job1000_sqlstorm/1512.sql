WITH RankedMovies AS (
    SELECT 
        T.id AS movie_id,
        T.title,
        T.production_year,
        AVG(CAST(CASE WHEN CI.person_role_id IS NOT NULL THEN 1 ELSE 0 END AS FLOAT)) AS avg_cast_size,
        COUNT(DISTINCT MI.info_type_id) AS info_count,
        DENSE_RANK() OVER (PARTITION BY T.production_year ORDER BY COUNT(DISTINCT CI.person_id) DESC) AS rank_by_cast_size
    FROM 
        aka_title T 
    LEFT JOIN 
        complete_cast CC ON T.id = CC.movie_id
    LEFT JOIN 
        cast_info CI ON CC.subject_id = CI.id
    LEFT JOIN 
        movie_info MI ON T.id = MI.movie_id
    GROUP BY 
        T.id, T.title, T.production_year
),
TopMovies AS (
    SELECT 
        movie_id,
        title,
        production_year,
        avg_cast_size,
        info_count
    FROM 
        RankedMovies
    WHERE 
        rank_by_cast_size <= 5
),
HighInfoMovies AS (
    SELECT 
        movie_id,
        title,
        production_year,
        avg_cast_size,
        info_count
    FROM 
        TopMovies
    WHERE 
        info_count > 2
)
SELECT 
    HM.title,
    HM.production_year,
    COALESCE(K.keyword, 'No Keywords') AS movie_keyword,
    COALESCE(CN.name, 'Unknown Company') AS company_name,
    CASE 
        WHEN HM.avg_cast_size IS NULL THEN 'No Cast Information'
        ELSE CONCAT('Average Cast Size: ', HM.avg_cast_size) 
    END AS cast_info,
    (SELECT COUNT(*) 
     FROM movie_keyword MK 
     WHERE MK.movie_id = HM.movie_id) AS keyword_count
FROM 
    HighInfoMovies HM
LEFT JOIN 
    movie_keyword MK ON HM.movie_id = MK.movie_id
LEFT JOIN 
    keyword K ON MK.keyword_id = K.id
LEFT JOIN 
    movie_companies MC ON HM.movie_id = MC.movie_id
LEFT JOIN 
    company_name CN ON MC.company_id = CN.id
WHERE 
    HM.production_year BETWEEN 2000 AND 2023
ORDER BY 
    HM.production_year DESC, HM.avg_cast_size DESC;
