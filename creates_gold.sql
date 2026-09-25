CREATE SCHEMA IF NOT EXISTS gold;

CREATE TABLE gold.dim_movie (
    movie_key SERIAL PRIMARY KEY,
    movie_id TEXT UNIQUE,
    imdb_id TEXT UNIQUE,
    title TEXT,
    original_title TEXT,
    release_year INT,
    runtime INT,
    is_adult BOOLEAN,
    original_language TEXT
);

CREATE TABLE gold.dim_genre (
    genre_id SERIAL PRIMARY KEY,
    genre_name TEXT UNIQUE
);

CREATE TABLE gold.dim_director (
    director_id SERIAL PRIMARY KEY,
    nconst TEXT UNIQUE,
    primary_name TEXT,
    birth_year INT,
    death_year INT
);

CREATE TABLE gold.fact_movies (
    fact_movie_key SERIAL PRIMARY KEY,
    movie_key INT UNIQUE
        REFERENCES gold.dim_movie(movie_key),
    budget BIGINT,
    revenue BIGINT,
    profit BIGINT,
    roi FLOAT,
    tmdb_vote_avg FLOAT,
    tmdb_vote_count INT,
    imdb_rating FLOAT,
    imdb_votes INT
);

CREATE TABLE gold.bridge_movie_genre (
    movie_key INT
        REFERENCES gold.dim_movie(movie_key),
    genre_id INT
        REFERENCES gold.dim_genre(genre_id),
    PRIMARY KEY (movie_key, genre_id)
);

CREATE TABLE gold.bridge_movie_director (
    movie_key INT
        REFERENCES gold.dim_movie(movie_key),
    director_id INT
        REFERENCES gold.dim_director(director_id),
    PRIMARY KEY (movie_key, director_id)
);