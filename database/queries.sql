-- STAGING
-- Filter raw data
DROP TABLE IF EXISTS staging.spotify_streams;

CREATE TABLE staging.spotify_streams AS
SELECT 
	ts AS date_played, 
	ms_played AS milliseconds_played, 
	conn_country AS country, 
	master_metadata_track_name AS track_name, 
	master_metadata_album_artist_name AS artist_name, 
	master_metadata_album_album_name AS album_name, 
	reason_start, 
	reason_end, 
	shuffle, 
	skipped, 
	mins_played
FROM public.streaming_history
ORDER BY ts ASC;

-- WARHOUSE
-- Create date dim
DROP TABLE IF EXISTS warehouse.dim_date;

CREATE TABLE warehouse.dim_date (
	date_id INT PRIMARY KEY,
	full_date DATE UNIQUE NOT NULL,
	year INT NOT NULL,
	month INT NOT NULL,
	day INT NOT NULL
);

INSERT INTO warehouse.dim_date (
    date_id,
    full_date,
    year,
    month,
    day
)
SELECT DISTINCT
    TO_CHAR(date_played::date, 'YYYYMMDD')::INT AS date_id,
    date_played::date AS full_date,
    EXTRACT(YEAR FROM date_played)::INT AS year,
    EXTRACT(MONTH FROM date_played)::INT AS month,
    EXTRACT(DAY FROM date_played)::INT AS day
FROM staging.spotify_streams;
