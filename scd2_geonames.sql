WITH new_true AS (
    SELECT 
        gs.*,
        current_date AS start_date,
        '9999-12-31'::DATE AS end_date,
        TRUE AS is_current
    FROM 
        geoname_source gs
    INNER JOIN 
        geoname g 
        ON g.geonameid = gs.geonameid 
        AND (g.latitude != gs.latitude OR g.population != gs.population) -- Just checking latitude and population
),
old_updated AS (
    SELECT 
        g.geonameid,
        g.name,
        g.asciiname,
        g.alternatenames,
        g.latitude,
        g.longitude,
        g.feature_class,
        g.feature_code,
        g.country_code,
        g.cc2,
        g.admin1_code,
        g.admin2_code,
        g.admin3_code,
        g.admin4_code,
        g.population,
        g.elevation,
        g.dem,
        g.timezone,
        g.modification_date,
        g.start_date,
        current_date AS end_date,
        FALSE AS is_current
    FROM 
        geoname g 
    INNER JOIN 
        new_true 
        ON g.geonameid = new_true.geonameid
),
unaltered AS (
    SELECT 
        g.* 
    FROM 
        geoname g
    LEFT JOIN 
        new_true
        ON g.geonameid = new_true.geonameid
    WHERE 
        new_true.geonameid IS NULL
),
new_entries AS (
    SELECT 
        gs.*,
        current_date AS start_date,
        '9999-12-31'::DATE AS end_date,
        TRUE AS is_current
    FROM 
        geoname_source gs
    LEFT JOIN 
        geoname g 
        ON g.geonameid = gs.geonameid
    WHERE 
        g.geonameid IS NULL
)
SELECT * FROM old_updated
UNION ALL
SELECT * FROM new_true
UNION ALL
SELECT * FROM unaltered
UNION ALL
SELECT * FROM new_entries;
