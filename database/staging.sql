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
ORDER BY ts ASC;

-- Filter genres data
