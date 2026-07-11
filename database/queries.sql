-- Filter raw data
CREATE TABLE staging.spotify_streams AS
SELECT 
	ts AS played_at, 
	ms_played AS milliseconds_played, 
	conn_country AS country, 
	master_metadata_track_name AS track_name, 
	master_metadata_album_artist_name AS artist_name, 
	master_metadata_album_album_name AS album_name, 
	reason_start, 
	reason_end, 
	shuffle, 
	skipped, 
	year_played,
    month_played, 
	mins_played
FROM public.streaming_history
ORDER BY ts ASC;

