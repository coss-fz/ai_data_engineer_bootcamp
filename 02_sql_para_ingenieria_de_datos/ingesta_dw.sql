USE dw_netflix;

-- Combinamos datos de Movie, Gender y Participants (Denormalización)
INSERT INTO dimMovie (movieID, title, releaseMovie, gender, participantName, roleparticipant, awardMovie)
SELECT 
    m.movieID,
    m.movieTitle,
    m.releaseDate,
    g.name AS gender,
    p.name AS participantName,
    pa.participantRole,
    'N/A' AS awardMovie -- Supuesto: No hay info de premios en el OLTP
FROM db_movies_netflix_transact.Movie m
LEFT JOIN db_movies_netflix_transact.Movie_Gender mg ON m.movieID = mg.movieId
LEFT JOIN db_movies_netflix_transact.Gender g ON mg.genderId = g.genderId
LEFT JOIN db_movies_netflix_transact.Participant pa ON m.movieID = pa.movieId
LEFT JOIN db_movies_netflix_transact.Person p ON pa.personId = p.personID;


-- Supuesto: Asumimos que existe una tabla 'User' en el OLTP
INSERT INTO dimUser (userID, username, country)
SELECT 
    u.id, 
    u.name, 
    u.country
FROM db_movies_netflix_transact.Users u; -- Tabla supuesta


-- Supuesto: Asumimos que existe una tabla transaccional de consumo/ratings
INSERT INTO FactWatchs (userID, movieID, rating, timestamp)
SELECT 
    tr.userID,
    tr.movieID,
    tr.rating,
    tr.watch_date
FROM db_movies_netflix_transact.Watch_History tr; -- Tabla supuesta