
WITH MovieDetails AS (
    SELECT 
        m.title AS movie_title,
        m.production_year,
        STRING_AGG(DISTINCT cn.name, ', ') AS companies,
        COUNT(DISTINCT kc.keyword) AS keyword_count,
        ROW_NUMBER() OVER (PARTITION BY m.id ORDER BY m.production_year DESC) AS rn
    FROM 
        aka_title m
    LEFT JOIN 
        movie_companies mc ON m.id = mc.movie_id
    LEFT JOIN 
        company_name cn ON mc.company_id = cn.id
    LEFT JOIN 
        movie_keyword mk ON m.id = mk.movie_id
    LEFT JOIN 
        keyword kc ON mk.keyword_id = kc.id
    WHERE 
        m.production_year >= 2000
    GROUP BY 
        m.id, m.title, m.production_year
),
ActorRoleDetails AS (
    SELECT 
        a.name AS actor_name,
        COUNT(c.movie_id) AS movie_count,
        SUM(CASE WHEN c.person_role_id IS NOT NULL THEN 1 ELSE 0 END) AS roles_count
    FROM 
        aka_name a
    JOIN 
        cast_info c ON a.person_id = c.person_id
    GROUP BY 
        a.id, a.name
),
MovieActorInfo AS (
    SELECT 
        md.movie_title,
        md.production_year,
        ar.actor_name,
        ar.movie_count,
        ar.roles_count
    FROM 
        MovieDetails md
    LEFT JOIN 
        ActorRoleDetails ar ON md.movie_title = ar.actor_name
)
SELECT 
    mai.movie_title,
    mai.production_year,
    COALESCE(mai.actor_name, 'Unknown Actor') AS actor_name,
    mai.movie_count,
    mai.roles_count,
    CASE 
        WHEN mai.movie_count > 0 THEN 'Active'
        ELSE 'Inactive'
    END AS actor_status
FROM 
    MovieActorInfo mai
WHERE 
    mai.production_year BETWEEN 2005 AND 2020
ORDER BY 
    mai.production_year DESC,
    mai.movie_title;
