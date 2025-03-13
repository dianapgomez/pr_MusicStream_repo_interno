USE StreamMusic;


 -- artistas mas populares de cada año
    

SELECT artist, Track, Spotify_Popularity, Spotify_EurovisionYear
	FROM api_spotify_merged_eurovision 
	WHERE Spotify_EurovisionYear = 2019
	ORDER BY Spotify_Popularity DESC
    LIMIT 5;
    
    
 SELECT artist, Track, Spotify_Popularity, Spotify_EurovisionYear
	FROM api_spotify_merged_eurovision 
	WHERE Spotify_EurovisionYear = 2021
	ORDER BY Spotify_Popularity DESC
    LIMIT 5;   
    
  SELECT artist, Track, Spotify_Popularity, Spotify_EurovisionYear
	FROM api_spotify_merged_eurovision 
	WHERE Spotify_EurovisionYear = 2022
	ORDER BY Spotify_Popularity DESC
    LIMIT 5;      
    
 SELECT artist, Track, Spotify_Popularity, Spotify_EurovisionYear
	FROM api_spotify_merged_eurovision 
	WHERE Spotify_EurovisionYear = 2023
	ORDER BY Spotify_Popularity DESC
    LIMIT 5;       

 SELECT artist, Track, Spotify_Popularity, Spotify_EurovisionYear
	FROM api_spotify_merged_eurovision 
	WHERE Spotify_EurovisionYear = 2024
	ORDER BY Spotify_Popularity DESC
    LIMIT 5;   
    
    
-- 1. ¿cual es el artista de Eurovisión con mas oyentes (listeners) en last fm? MANESKIN

SELECT artist AS Artists
	FROM api_lastfm_info_artists 
    ORDER BY listeners DESC
    LIMIT 1;
    
-- 2. ¿Que genero musical es mas comun entre los artistas populares de Eurovision? -- POP
    
SELECT Genre, COUNT(*) AS Genre_Count 
FROM (
    SELECT Genre1 AS Genre FROM api_lastfm_info_artists
    UNION ALL
    SELECT Genre2 FROM api_lastfm_info_artists
    UNION ALL
    SELECT Genre3 FROM api_lastfm_info_artists
) AS Genres
GROUP BY Genre
ORDER BY Genre_Count DESC
LIMIT 1;
        
    
-- 4. averiguar si la cancion de Eurovision esta entre top tracks del artista -- de 25 artistas 22 de ellos, su cancion mas popular es la cancion de eurovision

SELECT s.artist, s.track, l.top_track					
	FROM api_spotify_merged_eurovision AS s
    INNER JOIN api_lastfm_top_tracks AS l
    USING (artist)
    WHERE s.track = l.top_track;
    


 -- 5. ¿que pais tiene mas artistas en el top 5 de la playlist de Eurovision -- Italia, Netherlands, Norway, Sweden, France. Italia ha llevado artistas que están en el top 5 todos los años. 
 
 SELECT e.country, COUNT(artist) AS Artist
	FROM api_eurovision AS e
    INNER JOIN api_lastfm_info_artists
    USING (artist)
    GROUP BY country
    ORDER BY artist DESC
    LIMIT 5
    ;
    
SELECT e.Artist, Country, Eurovision_Year
	FROM api_lastfm_top_tracks
	INNER JOIN api_eurovision AS e
	USING (artist)
	GROUP BY e.artist, Country, Eurovision_Year
	HAVING country = "IT";

-- 7. ¿Que año de Eurovision tuvo los artistas mas populares en last-fm?-- 2021 Maneskin con 79M, 2024 Joost con 17M, 2023 Loreen con 16M, 2022 Mahmood con 8M, y 2019 Mahmoond conM.

SELECT e.Eurovision_Year, e.artist, l.playcount, country
	FROM api_eurovision AS e
    INNER JOIN  api_lastfm_info_artists AS l
    USING (artist)
    ORDER BY playcount DESC
    LIMIT 5
    ;
    

-- 8. ¿Cuales son los artistas similares más comunes entre los artistas populares? -- De los 62 artistas similares 17 participaron en Eurovisión en los últimos 5 años. 
    

SELECT Artists, COUNT(*) AS artist_count, 
		CASE 
			WHEN Artists IN (SELECT artist FROM api_eurovision) THEN "WAS IN EUROVISION"
			ELSE "WASN'T IN EUROVISION"
			END AS Eurovision_status
FROM (
    SELECT Similar_Artists1 AS Artists FROM api_lastfm_info_artists
    UNION ALL
    SELECT Similar_Artists2 FROM api_lastfm_info_artists
    UNION ALL
    SELECT Similar_Artists3 FROM api_lastfm_info_artists
) AS Artists
GROUP BY Artists
HAVING Artists <> ''
ORDER BY artist_count DESC;



-- 9. ¿Cuál es el artista con mejor ranking en Eurovisión y que también tiene alta popularidad en Spotify?--  Loreen 2023 80 puntos, Duncan Laurence 2019 74 puntos en spotify, Maneskin 2021 56 puntos, Nemo 2024 65 puntos

SELECT e.artist, e.ranking, s.Spotify_Popularity, e.Eurovision_year
	FROM api_eurovision AS e
	INNER JOIN api_spotify_merged_eurovision AS s
	USING (artist)
	WHERE s.Spotify_Popularity > 50  
	AND e.ranking = 
				(SELECT MIN(ranking) 
                FROM api_eurovision)
	ORDER by Spotify_Popularity DESC; 
        
-- 10. Obtener información de los artistas con su popularidad en Spotify y sus oyentes en Last.fm--  Solo 3 de los artistas más populares en Spotify (Loreen y Duncan Laurence, Joost) son top listeners en Last Fm


WITH RankedBySpotify AS (
    SELECT artist, Spotify_Popularity, listeners,
           ROW_NUMBER() OVER (ORDER BY Spotify_Popularity DESC) AS ranking_spotify -- Asigna un número único por cada elemento de la fila, así evita que se repetian
    FROM api_spotify_merged_eurovision 
    JOIN api_lastfm_info_artists USING (artist)
),
RankedByListeners AS (
    SELECT artist, Spotify_Popularity, listeners,
           ROW_NUMBER() OVER (ORDER BY listeners DESC) AS ranking_listeners
    FROM api_spotify_merged_eurovision 
    JOIN api_lastfm_info_artists USING (artist)
)
SELECT 
    s.artist AS "ARTIST (Popularidad Spotify)", 
    s.Spotify_Popularity AS "TOP SPOTIFY POPULARITY", 
    s.listeners AS "LISTENERS", 
    l.artist AS "ARTIST (Top Oyentes)", 
    l.Spotify_Popularity AS "SPOTIFY POPULARITY", 
    l.listeners AS "TOP LISTENERS"
FROM RankedBySpotify AS s
JOIN RankedByListeners AS l 
ON s.ranking_spotify = l.ranking_listeners  -- Empareja por ranking pero evita duplicar artistas
ORDER BY s.Spotify_Popularity DESC
LIMIT 5;

-- 11. Encontrar los artistas con las canciones más populares en Spotify y comparar la duración de sus canciones en Spotify con la duración promedio-- Las canciones más populares tienen una media de 3 minutos

WITH avg_popularity AS (
    SELECT AVG(Spotify_Popularity) AS avg_pop
    FROM api_spotify_merged_eurovision
),
avg_duration AS (
    SELECT AVG(Spotify_Duration) AS avg_spotify_duration
    FROM api_spotify_merged_eurovision
)
SELECT a.artist, a.Spotify_Popularity, ROUND(a.Spotify_Duration / 60000, 2) AS "Duration in Minutes"
FROM api_spotify_merged_eurovision AS a
JOIN avg_popularity AS ap ON a.Spotify_Popularity > ap.avg_pop
JOIN avg_duration AS ad ON a.Spotify_Duration > ad.avg_spotify_duration
ORDER BY a.Spotify_Popularity DESC;

    

    
 -- Artistas en el top 5 de popularidad de spotify que tuvieron una trayectoria antes de pasar por eurovisión   -- Artistas noveles (sin top tracks anteriores a su participación)
 
 SELECT Artist, Release_year, Top_track
 FROM api_lastfm_top_tracks AS lf
 INNER JOIN api_eurovision AS e
 USING (artist);
    
SELECT Artist, ranking, Eurovision_Year
FROM api_eurovision
WHERE artist = "Mahmood";
    
SELECT Artist, country, Eurovision_Year
FROM api_eurovision
WHERE ranking = 1;

-- Top 5 artistas de spotifay por año en su ranking de Eurovisión y con su popularidad. 

SELECT lf.artist AS "TOP 5 x YEAR", ranking, Eurovision_Year, country, Spotify_Popularity
FROM api_spotify_merged_eurovision
LEFT JOIN api_eurovision
USING (artist)
INNER JOIN api_lastfm_info_artists AS lf
USING (artist)
ORDER BY Eurovision_year, spotify_popularity DESC;
    