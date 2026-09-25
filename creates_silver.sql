CREATE SCHEMA IF NOT EXISTS silver;

CREATE TABLE silver.tmdb_movies_s (
    id TEXT PRIMARY KEY,
    title TEXT,
    vote_average FLOAT,
    vote_count INT,
    status TEXT,
    release_date DATE,
    revenue BIGINT,
    runtime INT,
    adult BOOLEAN,
    backdrop_path TEXT,
    budget BIGINT,
    homepage TEXT,
    imdb_id TEXT,
    original_language TEXT,
    original_title TEXT,
    overview TEXT,
    popularity FLOAT,
    poster_path TEXT,
    tagline TEXT,
    genres TEXT,
    production_companies TEXT,
    production_countries TEXT,
    spoken_languages TEXT,
    keywords TEXT
);

CREATE TABLE silver.imdb_basics_s (
	tconst TEXT PRIMARY KEY,
    title_type TEXT,
    primary_title TEXT,
    original_title TEXT,
    is_adult BOOLEAN,
    start_year INT,
    end_year INT,
    runtime_minutes INT,
    genres TEXT
);

CREATE TABLE silver.imdb_ratings_s (
	tconst TEXT PRIMARY KEY,
    average_rating FLOAT,
    num_votes INT
);

CREATE TABLE silver.imdb_title_crew_s (
    tconst TEXT PRIMARY KEY,
    directors TEXT,
    writers TEXT
);

CREATE TABLE silver.imdb_name_basics_s (
    nconst TEXT PRIMARY KEY,
    primary_name TEXT,
    birth_year INT,
    death_year INT,
    primary_profession TEXT,
    known_for_titles TEXT
);

CREATE TABLE silver.movies_s (
    movie_id TEXT PRIMARY KEY,
    imdb_id TEXT,
    title TEXT,
    original_title TEXT,
    release_year INT,
    runtime INT,
    is_adult BOOLEAN,
    original_language TEXT,
    budget BIGINT,
    revenue BIGINT,
    tmdb_vote_avg FLOAT,
    tmdb_vote_count INT,
    imdb_rating FLOAT,
    imdb_votes INT,
    genres_imdb TEXT
);

CREATE TABLE silver.movie_directors_s (
    tconst TEXT,
    nconst TEXT,
    PRIMARY KEY (tconst, nconst)
);

CREATE TABLE silver.movie_directors_enriched_s (
    tconst TEXT,
    nconst TEXT,
    primary_name TEXT,
    birth_year INT,
    death_year INT,
    PRIMARY KEY (tconst, nconst)
);