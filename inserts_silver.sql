INSERT INTO silver.tmdb_movies_s
SELECT
    id,
    title,
    vote_average,
    vote_count,
    status,
    release_date,
    revenue,
    runtime,
    adult,
    backdrop_path,
    budget,
    homepage,
    imdb_id,
    original_language,
    original_title,
    overview,
    popularity,
    poster_path,
    tagline,
    genres,
    production_companies,
    production_countries,
    spoken_languages,
    keywords
FROM (
    SELECT
        id,
        title,
        CASE
            WHEN CAST(NULLIF(vote_average, '') AS FLOAT) = 0 THEN NULL
            ELSE CAST(NULLIF(vote_average, '') AS FLOAT)
        END AS vote_average,
        CAST(NULLIF(vote_count, '') AS INT) AS vote_count,
        status,
        CAST(NULLIF(release_date, '') AS DATE) AS release_date,
        CASE
            WHEN CAST(NULLIF(revenue, '') AS BIGINT) = 0 THEN NULL
            ELSE CAST(NULLIF(revenue, '') AS BIGINT)
        END AS revenue,
        CASE
            WHEN CAST(NULLIF(runtime, '') AS INT) = 0 THEN NULL
            ELSE CAST(NULLIF(runtime, '') AS INT)
        END AS runtime,
        CAST(NULLIF(adult, '') AS BOOLEAN) AS adult,
        backdrop_path,
        CASE
            WHEN CAST(NULLIF(budget, '') AS BIGINT) = 0 THEN NULL
            ELSE CAST(NULLIF(budget, '') AS BIGINT)
        END AS budget,
        homepage,
        NULLIF(imdb_id, 'None') AS imdb_id,
        original_language,
        original_title,
        overview,
        CAST(NULLIF(popularity, '') AS FLOAT) AS popularity,
        poster_path,
        tagline,
        genres,
        production_companies,
        production_countries,
        spoken_languages,
        keywords,
        ROW_NUMBER() OVER (
            PARTITION BY id
            ORDER BY 
                CAST(NULLIF(vote_count, '') AS INT) DESC NULLS LAST,
                CAST(NULLIF(popularity, '') AS FLOAT) DESC NULLS LAST,
                CAST(NULLIF(revenue, '') AS BIGINT) DESC NULLS LAST
        ) AS rn
    FROM bronze.tmdb_movies
) t
WHERE rn = 1;


INSERT INTO silver.imdb_basics_s
SELECT
    tconst,
    titleType,
    primaryTitle,
    originalTitle,
    CAST(NULLIF(isAdult, '\N') AS BOOLEAN),
    CAST(NULLIF(startYear, '\N') AS INT),
    CAST(NULLIF(endYear, '\N') AS INT),
    CAST(NULLIF(runtimeMinutes, '\N') AS INT),
    CAST(NULLIF(genres, '\N') AS TEXT)
FROM bronze.imdb_basics;


INSERT INTO silver.imdb_ratings_s
SELECT
    tconst,
    CAST(NULLIF(averageRating, '\N') AS FLOAT),
    CAST(NULLIF(numVotes, '\N') AS INT)
FROM bronze.imdb_ratings;


INSERT INTO silver.imdb_title_crew_s
SELECT
    tconst,
    NULLIF(directors, '\N') AS directors,
    NULLIF(writers, '\N') AS writers
FROM bronze.imdb_title_crew;


INSERT INTO silver.imdb_name_basics_s
SELECT
    nconst,
    primaryName,
    CAST(NULLIF(birthYear, '\N') AS INT),
    CAST(NULLIF(deathYear, '\N') AS INT),
    NULLIF(primaryProfession, '\N'),
    NULLIF(knownForTitles, '\N')
FROM bronze.imdb_name_basics;


INSERT INTO silver.movies_s
WITH tmdb_dedup AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (
                PARTITION BY imdb_id
                ORDER BY
                    vote_count DESC NULLS LAST,
                    revenue DESC NULLS LAST
            ) AS rn
        FROM silver.tmdb_movies_s
        WHERE imdb_id IS NOT NULL
    ) t
    WHERE rn = 1
)
SELECT
    i.tconst AS movie_id,
    i.tconst AS imdb_id,
    i.primary_title AS title,
    i.original_title,
    i.start_year AS release_year,
    i.runtime_minutes AS runtime,
    i.is_adult,
    t.original_language,
    t.budget,
    t.revenue,
    t.vote_average AS tmdb_vote_avg,
    t.vote_count AS tmdb_vote_count,
    r.average_rating AS imdb_rating,
    r.num_votes AS imdb_votes,
    i.genres AS genres_imdb
FROM silver.imdb_basics_s i
LEFT JOIN silver.imdb_ratings_s r
    ON i.tconst = r.tconst
LEFT JOIN tmdb_dedup t
    ON i.tconst = t.imdb_id
WHERE i.title_type = 'movie'
	AND i.start_year BETWEEN 1865 AND 2026;
	

INSERT INTO silver.movie_directors_s
SELECT
    tconst,
    TRIM(director) AS nconst
FROM (
    SELECT
        tconst,
        unnest(string_to_array(directors, ',')) AS director
    FROM silver.imdb_title_crew_s
    WHERE directors IS NOT NULL
) t
WHERE TRIM(director) <> '';


INSERT INTO silver.movie_directors_enriched_s
SELECT
    md.tconst,
    md.nconst,
    nb.primary_name,
    nb.birth_year,
    nb.death_year
FROM silver.movie_directors_s md
LEFT JOIN silver.imdb_name_basics_s nb
    ON md.nconst = nb.nconst;