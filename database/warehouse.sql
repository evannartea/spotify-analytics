-- WAREHOUSE
-- Create date dim
DROP TABLE IF EXISTS warehouse.dim_date;

CREATE TABLE warehouse.dim_date (
	date_id INT PRIMARY KEY,
	full_date DATE UNIQUE NOT NULL,
	year INT NOT NULL,
	month_number INT NOT NULL,
	month_name VARCHAR(20) NOT NULL,
	day_of_month INT NOT NULL,
	day_of_week INT NOT NULL,
	day_name VARCHAR(20)
);

INSERT INTO warehouse.dim_date (
    date_id,
    full_date,
    year,
    month_number,
	month_name,
    day_of_month,
	day_of_week,
	day_name
)
SELECT DISTINCT
    TO_CHAR(date_played::date, 'YYYYMMDD')::INT AS date_id,
    date_played::date AS full_date,
    EXTRACT(YEAR FROM date_played)::INT AS year,
    EXTRACT(MONTH FROM date_played)::INT AS month_number,
	TO_CHAR(date_played::date, 'FMMonth') AS month_name,
    EXTRACT(DAY FROM date_played)::INT AS day_of_month,
    EXTRACT(ISODOW FROM date_played)::INT AS day_of_week,
	TO_CHAR(date_played::date, 'FMDay') AS day_name
FROM staging.spotify_streams
ORDER BY full_date;

-- Create time dim
DROP TABLE IF EXISTS warehouse.dim_time;

CREATE TABLE warehouse.dim_time (
	time_id INT PRIMARY KEY,
	hour INT NOT NULL,
	minute INT NOT NULL,
	time_of_day VARCHAR(10) NOT NULL
);

INSERT INTO warehouse.dim_time (
    time_id,
    hour,
	minute,
    time_of_day
)
SELECT DISTINCT
	(EXTRACT(HOUR FROM date_played)::INT * 100 +
		EXTRACT(MINUTE FROM date_played)::INT) as time_id,
	EXTRACT(HOUR FROM date_played):: INT AS hour,
	EXTRACT(MINUTE FROM date_played):: INT AS minute,
	CASE
		WHEN EXTRACT(HOUR FROM date_played) BETWEEN 6 and 11 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM date_played) BETWEEN 12 and 17 THEN 'Afternoon'
		WHEN EXTRACT(HOUR FROM date_played) BETWEEN 18 and 23 THEN 'Evening'
		WHEN EXTRACT(HOUR FROM date_played) BETWEEN 0 and 5 THEN 'Night'
		ELSE 'Unknown'
	END AS time_of_day
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
DROP TABLE IF EXISTS warehouse.ref_country;

CREATE TABLE warehouse.ref_country (
	country_code CHAR(2) UNIQUE NOT NULL,
	country_name VARCHAR(100) UNIQUE NOT NULL
);

INSERT INTO warehouse.ref_country (
	country_code,
	country_name
)

VALUES
    ('AE', 'United Arab Emirates'),
    ('AU', 'Australia'),
    ('CN', 'China'),
    ('GB', 'United Kingdom'),
    ('ID', 'Indonesia'),
    ('IS', 'Iceland'),
    ('IT', 'Italy'),
    ('KH', 'Cambodia'),
    ('LA', 'Laos'),
    ('MY', 'Malaysia'),
    ('PH', 'Philippines'),
    ('SC', 'Seychelles'),
    ('TH', 'Thailand'),
    ('VN', 'Vietnam');

DROP TABLE IF EXISTS warehouse.dim_country;

CREATE TABLE warehouse.dim_country (
	country_id SERIAL PRIMARY KEY,
	country_code CHAR(2) UNIQUE NOT NULL,
	country_name VARCHAR(100) UNIQUE NOT NULL,

	FOREIGN KEY(country_code)
		REFERENCES warehouse.ref_country(country_code)
);

INSERT INTO warehouse.dim_country (
	country_code,
	country_name
)
SELECT DISTINCT
	s.country_code,
	r.country_name
FROM staging.spotify_streams s
JOIN warehouse.ref_country r
	ON s.country_code = r.country_code
ORDER BY s.country_code;

-- Create play info dim
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
	time_id INT NOT NULL,
	track_id INT NOT NULL,
	country_id INT NOT NULL,
	play_info_id INT NOT NULL,

	milliseconds_played INT,
	minutes_played NUMERIC(10,2),

	FOREIGN KEY(date_id)
		REFERENCES warehouse.dim_date(date_id),

	FOREIGN KEY(time_id)
		REFERENCES warehouse.dim_time(time_id),

	FOREIGN KEY(track_id)
		REFERENCES warehouse.dim_track(track_id),

	FOREIGN KEY(country_id)
		REFERENCES warehouse.dim_country(country_id),

	FOREIGN KEY(play_info_id)
		REFERENCES warehouse.dim_play_info(play_info_id)
);

INSERT INTO warehouse.fact_streams (
	date_id,
	time_id,
	track_id,
	country_id,
	play_info_id,

	milliseconds_played,
	minutes_played
)

SELECT
	d.date_id,
	ti.time_id,
	tr.track_id,
	c.country_id,
	pi.play_info_id,

	s.milliseconds_played,
	s.mins_played
FROM staging.spotify_streams s

JOIN warehouse.dim_date d
	ON s.date_played::date = d.full_date

JOIN warehouse.dim_time ti
	ON (
		EXTRACT(HOUR FROM s.date_played)::INT * 100 +
			EXTRACT (MINUTE FROM s.date_played)::INT
	) = ti.time_id

JOIN warehouse.dim_track tr
    ON s.track_name = tr.track_name
    AND s.artist_name = tr.artist_name
    AND s.album_name = tr.album_name

JOIN warehouse.dim_country c
    ON s.country_code = c.country_code

JOIN warehouse.dim_play_info pi
    ON s.reason_start = pi.reason_start
    AND s.reason_end = pi.reason_end
    AND s.shuffle = pi.shuffle
    AND s.skipped = pi.skipped;