-- STAGING
-- Filter raw streaming history data
DROP TABLE IF EXISTS staging.streaming_history;

CREATE TABLE staging.streaming_history AS
SELECT 
	ts::timestamp AS date_played, 
	ms_played AS milliseconds_played, 
	ms_played::decimal / 60000 AS mins_played,
	conn_country AS country_code, 
	master_metadata_track_name AS track_name, 
	master_metadata_album_artist_name AS artist_name, 
	master_metadata_album_album_name AS album_name, 
	reason_start, 
	reason_end, 
	shuffle, 
	skipped
FROM public.streaming_history
WHERE master_metadata_track_name IS NOT NULL
	AND master_metadata_album_artist_name IS NOT NULL
	AND master_metadata_album_album_name IS NOT NULL
	AND ts >= '2022-01-01 00:00:00'
ORDER BY ts ASC;

-- Filter genres data
-- Written by ChatGPT
DROP TABLE IF EXISTS staging.artist_genres;

CREATE TABLE staging.artist_genres AS
WITH accepted_genres AS (
    SELECT
        artist_name,
        lower(regexp_replace(genre, '[-_\s]', '', 'g')) AS normalised_genre,
        weight,
        COUNT(*) OVER (
            PARTITION BY lower(regexp_replace(genre, '[-_\s]', '', 'g'))
        ) AS genre_count
    FROM public.artist_genres
    WHERE weight > 50
),
filtered_genres AS (
    SELECT
        artist_name,
        normalised_genre,
        weight,
        SUM(weight) OVER (
            PARTITION BY artist_name
        ) AS artist_total_weight
    FROM accepted_genres
    WHERE genre_count >= 30
)
SELECT
    artist_name,
    normalised_genre,
    ROUND((weight / artist_total_weight)::numeric, 2) AS weight
FROM filtered_genres
ORDER BY artist_name;
