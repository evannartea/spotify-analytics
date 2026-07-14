-- STAGING
-- Filter raw data
DROP TABLE IF EXISTS staging.spotify_streams;

CREATE TABLE staging.spotify_streams AS
SELECT 
	ts AS date_played, 
	ms_played AS milliseconds_played, 
	conn_country AS country_code, 
	master_metadata_track_name AS track_name, 
	master_metadata_album_artist_name AS artist_name, 
	master_metadata_album_album_name AS album_name, 
	reason_start, 
	reason_end, 
	shuffle, 
	skipped, 
	mins_played
FROM public.streaming_history
WHERE master_metadata_track_name IS NOT NULL
	AND master_metadata_album_artist_name IS NOT NULL
	AND master_metadata_album_album_name IS NOT NULL
ORDER BY ts ASC;