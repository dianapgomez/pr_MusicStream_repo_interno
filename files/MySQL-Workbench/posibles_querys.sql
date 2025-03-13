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
    
    
-- 1. ¿cual es el artista con mas oyentes (listeners) en last fm?

SELECT artist AS Artists
	FROM api_lastfm_info_artists 
    ORDER BY listeners DESC
    LIMIT 1;
    
-- 2. ¿Que genero musical es mas comun entre los artistas populares de Eurovision?--
    
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
        
    
-- 4. averiguar si la cancion de Eurovision esta entre top tracks del artista -- 

SELECT s.artist, s.track, l.top_track					-- de 25 artistas 22 de ellos, su cancion mas popular es la cancion de eurovision --
	FROM api_spotify_merged_eurovision AS s
    INNER JOIN api_lastfm_top_tracks AS l
    USING (artist)
    WHERE s.track = l.top_track;
    


 -- 5. ¿que pais tiene mas artistas en la playlist de Eurovision?--
 
 SELECT country, COUNT(artist) AS Artist
	FROM api_eurovision
    GROUP BY country
    ORDER BY artist DESC
    LIMIT 10;
    
SELECT artist

 -- 6. ¿Que artista de lastfm tiene mas oyentes--

SELECT artist, AVG(listeners)
	FROM api_lastfm_info_artists;
    
    
-- 7. ¿Que año de Eurovision tuvo los artistas mas populares?-- 

SELECT e.Eurovision_Year, COUNT(l.artist)
	FROM api_eurovision AS e
    INNER JOIN  api_lastfm_info_artists AS l
    USING (artist)
	GROUP BY e.Eurovision_Year;
    

-- 8. ¿Cuales son los artistas similares más comunes entre los artistas populares? --
    
    SELECT Similar_Artists1, COUNT(artist)
		FROM api_lastfm_info_artists
        GROUP BY Similar_Artists1;
        
        
-- 9. ¿Cuál es el artista con mejor ranking en Eurovisión y que también tiene alta popularidad en Spotify?-- 

SELECT e.artist 
	FROM api_eurovision AS e
    WHERE e.artist IN (
		SELECT MAX(e.ranking)
		FROM api_eurovision AS e
		INNER JOIN api_spotify_merged_eurovision AS s
		USING (artist)
		WHERE s.Spotify_Popularity < 5
		GROUP BY e.ranking)
	

        
-- 10. Obtener información de los artistas con su popularidad en Spotify y sus oyentes en Last.fm-- 

SELECT s.artist, s.Spotify_Popularity, l.listeners 
	FROM api_spotify_merged_eurovision AS s
    INNER JOIN api_lastfm_info_artists AS l
    USING (artist); 



-- 11. Encontrar los artistas con más oyentes en Last.fm y comparar la duración de sus canciones en Spotify con la duración promedio--

SELECT artist
	FROM api_lastfm_info_artists
    WHERE listeners > AVG(listeners) AND artist (SELECT track, AVG(Spotify_Duration)
													FROM api_spotify_merged_eurovision
													GROUP BY track);
    

    
    
    
    
    
    
    
    
    