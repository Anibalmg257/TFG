INSERT INTO gold.dim_movie (
    movie_id,
    imdb_id,
    title,
    original_title,
    release_year,
    runtime,
    is_adult,
    original_language
)
SELECT
    movie_id,
    imdb_id,
    title,
    original_title,
    release_year,
    runtime,
    is_adult,
    original_language
FROM silver.movies_s;


INSERT INTO gold.dim_genre (genre_name)
SELECT DISTINCT
    TRIM(unnest(string_to_array(genres_imdb, ',')))
FROM silver.movies_s
WHERE genres_imdb IS NOT NULL
ON CONFLICT DO NOTHING;


INSERT INTO gold.dim_director (
    nconst,
    primary_name,
    birth_year,
    death_year
)
SELECT DISTINCT
    nconst,
    primary_name,
    birth_year,
    death_year
FROM silver.movie_directors_enriched_s
WHERE nconst IS NOT NULL
ON CONFLICT (nconst)DO NOTHING;


INSERT INTO gold.fact_movies
    (movie_key, budget, revenue, profit, roi,
     tmdb_vote_avg, tmdb_vote_count, imdb_rating, imdb_votes)
SELECT
    d.movie_key,
    m.budget,
    m.revenue,
    (m.revenue - m.budget) AS profit,
    CASE
        WHEN m.budget >= 50000
        AND m.revenue IS NOT NULL
        AND m.imdb_votes >= 20
        THEN ((m.revenue - m.budget)::FLOAT / m.budget)
        ELSE NULL
    END AS roi,
    m.tmdb_vote_avg,
    m.tmdb_vote_count,
    m.imdb_rating,
    m.imdb_votes
FROM silver.movies_s m
JOIN gold.dim_movie d
    ON m.movie_id = d.movie_id
ON CONFLICT (movie_key) DO NOTHING;

INSERT INTO gold.bridge_movie_genre
SELECT
    d.movie_key,
    g.genre_id
FROM (
    SELECT
        movie_id,
        TRIM(
            unnest(string_to_array(genres_imdb, ','))
        ) AS genre
    FROM silver.movies_s
) m
JOIN gold.dim_movie d
    ON m.movie_id = d.movie_id
JOIN gold.dim_genre g
    ON m.genre = g.genre_name
WHERE TRIM(m.genre) <> ''
ON CONFLICT DO NOTHING;


INSERT INTO gold.bridge_movie_director (
    movie_key,
    director_id
)
SELECT
    m.movie_key,
    d.director_id
FROM silver.movie_directors_enriched_s md
JOIN gold.dim_movie m
    ON md.tconst = m.imdb_id
JOIN gold.dim_director d
    ON md.nconst = d.nconst
WHERE md.nconst IS NOT NULL
ON CONFLICT DO NOTHING;
