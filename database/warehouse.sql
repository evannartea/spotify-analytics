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

-- Create track dim
DROP TABLE IF EXISTS warehouse.dim_track;

CREATE TABLE warehouse.dim_track (
	track_id SERIAL PRIMARY KEY,
	track_name VARCHAR(255),
	artist_name VARCHAR(255),
	album_name VARCHAR (255),

	UNIQUE (
		track_name,
		artist_name,
		album_name
	)
);

INSERT INTO warehouse.dim_track (
	track_name,
	artist_name,
	album_name
)
SELECT DISTINCT
	track_name,
	artist_name,
	album_name
FROM staging.spotify_streams
ORDER BY artist_name, album_name, track_name;

-- Create country dim
DROP TABLE IF EXISTS warehouse.dim_country;

CREATE TABLE warehouse.dim_country (
	country_id SERIAL PRIMARY KEY,
	country_code VARCHAR(10) UNIQUE NOT NULL
);

INSERT INTO warehouse.dim_country (
	country_code
)
SELECT DISTINCT
	country
FROM staging.spotify_streams
ORDER BY country;

-- Create context dim
DROP TABLE IF EXISTS warehouse.dim_play_info;

CREATE TABLE warehouse.dim_play_info (
	play_info_id SERIAL PRIMARY KEY,
	reason_start VARCHAR(100),
	reason_end VARCHAR(100),
	shuffle BOOLEAN,
	skipped BOOLEAN,

	UNIQUE (
		reason_start,
		reason_end,
		shuffle,
		skipped
	)
);

INSERT INTO warehouse.dim_play_info (
	reason_start,
	reason_end,
	shuffle,
	skipped
)
SELECT DISTINCT
	reason_start,
	reason_end,
	shuffle,
	skipped
FROM staging.spotify_streams
ORDER BY reason_start, reason_end;

-- Create fact table
DROP TABLE IF EXISTS warehouse.fact_streams;

CREATE TABLE warehouse.fact_streams (
	stream_id BIGSERIAL PRIMARY KEY,

	date_id INT NOT NULL,
	track_id INT NOT NULL,
	country_id INT NOT NULL,
	play_info_id INT NOT NULL,

	milliseconds_played INT,
	minutes_played NUMERIC(10,2),

	FOREIGN KEY(date_id)
		REFERENCES warehouse.dim_date(date_id),

	FOREIGN KEY(track_id)
		REFERENCES warehouse.dim_track(track_id),

	FOREIGN KEY(country_id)
		REFERENCES warehouse.dim_country(country_id),

	FOREIGN KEY(play_info_id)
		REFERENCES warehouse.dim_play_info(play_info_id)
);

INSERT INTO warehouse.fact_streams (
	date_id,
	track_id,
	country_id,
	play_info_id,

	milliseconds_played,
	minutes_played
)

SELECT
	d.date_id,
	t.track_id,
	c.country_id,
	pi.play_info_id,

	s.milliseconds_played,
	s.mins_played
FROM staging.spotify_streams s

JOIN warehouse.dim_date d
	ON s.date_played::date = d.full_date

JOIN warehouse.dim_track t
    ON s.track_name = t.track_name
    AND s.artist_name = t.artist_name
    AND s.album_name = t.album_name

JOIN warehouse.dim_country c
    ON s.country = c.country_code

JOIN warehouse.dim_play_info pi
    ON s.reason_start = pi.reason_start
    AND s.reason_end = pi.reason_end
    AND s.shuffle = pi.shuffle
    AND s.skipped = pi.skipped;


