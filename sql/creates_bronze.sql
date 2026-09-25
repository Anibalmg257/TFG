CREATE SCHEMA IF NOT EXISTS bronze;

CREATE TABLE bronze.tmdb_movies (
    id TEXT,
    title TEXT,
    vote_average TEXT,
    vote_count TEXT,
    status TEXT,
    release_date TEXT,
    revenue TEXT,
    runtime TEXT,
    adult TEXT,
    backdrop_path TEXT,
    budget TEXT,
    homepage TEXT,
    imdb_id TEXT,
    original_language TEXT,
    original_title TEXT,
    overview TEXT,
    popularity TEXT,
    poster_path TEXT,
    tagline TEXT,
    genres TEXT,
    production_companies TEXT,
    production_countries TEXT,
    spoken_languages TEXT,
    keywords TEXT,
);

CREATE TABLE bronze.imdb_basics (
	tconst TEXT,
	titleType TEXT,
	primaryTitle TEXT,
	originalTitle TEXT,
	isAdult TEXT,
	startYear TEXT,
	endYear TEXT,
	runtimeMinutes TEXT,
	genres TEXT
);

CREATE TABLE bronze.imdb_ratings (
	tconst TEXT,
	averageRating TEXT,
	numVotes TEXT
);

CREATE TABLE bronze.imdb_title_crew (
    tconst TEXT,
    directors TEXT,
    writers TEXT
);

CREATE TABLE bronze.imdb_name_basics (
    nconst TEXT,
    primaryName TEXT,
    birthYear TEXT,
    deathYear TEXT,
    primaryProfession TEXT,
    knownForTitles TEXT
);
