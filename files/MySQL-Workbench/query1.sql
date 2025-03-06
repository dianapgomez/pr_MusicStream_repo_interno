SELECT *
FROM api_eurovision;

SELECT *
FROM api_lastfm_info_artists;


SELECT e.Artist, l.Artist
FROM api_eurovision AS e
LEFT JOIN api_lastfm_info_artists AS l
ON e.Artist = l.Artist;

SELECT *
FROM api_lastfm_top_tracks;


SELECT e.Artist, l.Artist, t.Artist
FROM api_eurovision AS e
LEFT JOIN api_lastfm_info_artists AS l ON e.Artist = l.Artist
LEFT JOIN api_lastfm_top_tracks AS t ON e.Artist = t.Artist;


SELECT e.Artist AS eurovision, l.Artist AS spotify
FROM api_eurovision AS e
LEFT JOIN api_spotify_playlist AS l
ON e.Artist = l.Artist
WHERE e.Artist = 
	(SELECT CASE WHEN e.Artist = l.Artist THEN "Okay"
ELSE "Not Okay"
END AS "verification");



-- 👇👇 query for sorting and verifying artist names between eurovision and spotify --

SELECT e.Artist AS eurovision, 
       l.Artist AS spotify,
       CASE 
           WHEN l.Artist IS NOT NULL THEN "Okay"
           ELSE "Not Okay"
       END AS verification
FROM api_eurovision AS e
LEFT JOIN api_spotify_playlist AS l
ON e.Artist = l.Artist
ORDER BY verification DESC;




