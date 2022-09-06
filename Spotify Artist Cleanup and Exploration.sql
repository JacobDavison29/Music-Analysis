
--MINOR DATA EXPLORATION---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Taking a look at the datasets
Select * 
From Eminem;

Select * 
From FiftyCent;

Select * 
From GEazy;

Select * 
From Logic;

-- Checking for duplicate song values in the Eminem Dataset
SELECT Name, COUNT(Name) AS Occurences 
FROM Eminem
GROUP BY Name;

-- Checking for duplicate song values in the Fifty Cent Dataset
SELECT Name, COUNT(Name) AS Occurences 
FROM FiftyCent
GROUP BY Name;

-- Checking for duplicate song values in the G-Eazy Dataset
SELECT Name, COUNT(Name) AS Occurences 
FROM GEazy
GROUP BY Name;

-- Checking for duplicate song values in the Logic Dataset
SELECT Name, COUNT(Name) AS Occurences 
FROM Logic
GROUP BY Name;

--DATA CLEANING-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicate Song Values From the Eminem_Temp Table. Keeping the version of each song with the highest Popularity
SELECT *, ROW_NUMBER() OVER(PARTITION BY Name ORDER BY Popularity DESC) AS Most_Popular_Eminem
INTO #Eminem_Temp
FROM Eminem;


DELETE
FROM #Eminem_Temp
WHERE Most_Popular_Eminem != 1;

-- Removing Duplicate Song Values From the FiftyCent_Temp Table. Keeping the version of each song with the highest Popularity
SELECT *, ROW_NUMBER() OVER(PARTITION BY Name ORDER BY Popularity DESC) AS Most_Popular_FiftyCent
INTO #FiftyCent_Temp
FROM FiftyCent;

DELETE
FROM #FiftyCent_Temp
WHERE Most_Popular_FiftyCent != 1;


-- Removing Duplicate Song Values From the GEazy_Temp Table. Keeping the version of each song with the highest Popularity
SELECT *, ROW_NUMBER() OVER(PARTITION BY Name ORDER BY Popularity DESC) AS Most_Popular_GEazy
INTO #GEazy_Temp
FROM GEazy;

DELETE
FROM #GEazy_Temp
WHERE Most_Popular_GEazy != 1;


-- Removing Duplicate Song Values From the Logic_Temp Table. Keeping the version of each song with the highest Popularity
SELECT *, ROW_NUMBER() OVER(PARTITION BY Name ORDER BY Popularity DESC) AS Most_Popular_Logic
INTO #Logic_Temp
FROM Logic;

DELETE 
FROM #Logic_Temp
WHERE Most_Popular_Logic != 1;


-- Removing the scientific notation associated with the Instrumentalness/Acousticness column

--Altering The Eminem_Temp Table and Updating it to remove the Scientific Notation
ALTER TABLE #Eminem_Temp
ADD Instrumentalness_Regular NVARCHAR(25), Acousticness_Regular NVARCHAR(25);

UPDATE #Eminem_Temp
SET Instrumentalness_Regular = Format(Instrumentalness,'0.0###################') FROM #Eminem_Temp;

UPDATE #Eminem_Temp
SET Acousticness_Regular = Format(Acousticness,'0.0###################') FROM #Eminem_Temp;




--Altering The FiftyCent_Temp Table and Updating it to remove the Scientific Notation
ALTER TABLE #FiftyCent_Temp
ADD Instrumentalness_Regular NVARCHAR(25);

UPDATE #FiftyCent_Temp
SET Instrumentalness_Regular = Format(Instrumentalness,'0.0###################') FROM #FiftyCent_Temp;



--Altering The GEazy_Temp Table and Updating it to remove the Scientific Notation
ALTER TABLE #GEazy_Temp
ADD Instrumentalness_Regular NVARCHAR(25), Acousticness_Regular NVARCHAR(25);

UPDATE #GEazy_Temp
SET Instrumentalness_Regular = Format(Instrumentalness,'0.0###################') FROM #GEazy_Temp;

UPDATE #GEazy_Temp
SET Acousticness_Regular = Format(Acousticness,'0.0###################') FROM #GEazy_Temp;



--Altering The Logic_Temp Table and Updating it to remove the Scientific Notation
ALTER TABLE #Logic_Temp
ADD Instrumentalness_Regular NVARCHAR(25);

UPDATE #Logic_Temp
SET Instrumentalness_Regular = Format(Instrumentalness,'0.0###################') FROM #Logic_Temp;


-- Dropping Columns no longer needed

--Dropping From the Eminem_Temp
ALTER TABLE #Eminem_Temp
DROP COLUMN Most_Popular_Eminem,Instrumentalness,Acousticness;

--Dropping From the FiftyCent_Temp
ALTER TABLE #FiftyCent_Temp
DROP COLUMN Most_Popular_FiftyCent,Instrumentalness;

--Dropping From the GEazy_Temp
ALTER TABLE #GEazy_Temp
DROP COLUMN Most_Popular_GEazy,Instrumentalness,Acousticness;

--Dropping From the Logic_Temp
ALTER TABLE #Logic_Temp
DROP COLUMN Most_Popular_Logic,Instrumentalness;


-- Creating Tables to Permanently House The Updated Data in the Temp Tables

-- Creating an Updated Eminem Table
SELECT * 
INTO Eminem_Updated
FROM #Eminem_Temp;

-- Creating an Updated Fifty Cent Table
SELECT * 
INTO FiftyCent_Updated
FROM #FiftyCent_Temp;

-- Creating an Updated G-Eazy Table
SELECT * 
INTO GEazy_Updated
FROM #GEazy_Temp;

-- Creating an Updated Logic Table
SELECT * 
INTO Logic_Updated
FROM #Logic_Temp;


-- Adding an Artist Column to each table to distinguish artists Songs

--Adding Artist Column to Eminem
ALTER TABLE Eminem_Updated
ADD Artist varchar(25);

UPDATE Eminem_Updated
SET Artist = 'Eminem';

--Adding Artist Column to Fifty Cent
ALTER TABLE FiftyCent_Updated
ADD Artist varchar(25);

UPDATE FiftyCent_Updated
SET Artist = '50 Cent';


--Adding Artist Column to G-Eazy
ALTER TABLE GEazy_Updated
ADD Artist varchar(25);

UPDATE GEazy_Updated
SET Artist = 'G-Eazy';


--Adding Artist Column to Logic
ALTER TABLE Logic_Updated
ADD Artist varchar(25);

UPDATE logic_Updated
SET Artist = 'Logic';



-- EXPLORING THE DATA A LITTLE FURTHER NOW THAT IS IS CLEANED UP---------------------------------------------------------------------------------------------------------------------------------------------------------------



-- Validating that there are no duplicate songs in the Eminem_Updated dataset
SELECT Name, COUNT(Name) AS Occurences 
FROM Eminem_Updated
GROUP BY Name
ORDER BY Occurences DESC;

-- Validating that there are no duplicate songs in the FiftyCent_Updated dataset
SELECT Name, COUNT(Name) AS Occurences 
FROM FiftyCent_Updated
GROUP BY Name
ORDER BY Occurences DESC;

-- Validating that there are no duplicate songs in the GEazy_Updated dataset
SELECT Name, COUNT(Name) AS Occurences 
FROM GEazy_Updated
GROUP BY Name
ORDER BY Occurences DESC;

-- Validating that there are no duplicate songs in the Logic_Updated dataset
SELECT Name, COUNT(Name) AS Occurences 
FROM Logic_Updated
GROUP BY Name
ORDER BY Occurences DESC;



-- Looking at the Albums on average that have the most popular songs for all artists.
SELECT *
FROM(
	SELECT Album,AVG(Popularity) AS Most_Song_Popularity
	FROM Eminem_Updated
	GROUP BY Album
	HAVING AVG(Popularity) > 0
	UNION	
	SELECT Album,AVG(Popularity) AS Most_Song_Popularity
	FROM FiftyCent_Updated
	GROUP BY Album
	HAVING AVG(Popularity) > 0
	UNION
	SELECT Album,AVG(Popularity) AS Most_Song_Popularity
	FROM GEazy_Updated
	GROUP BY Album
	HAVING AVG(Popularity) > 0
	UNION
	SELECT Album,AVG(Popularity) AS Most_Song_Popularity
	FROM Logic_Updated
	GROUP BY Album
	HAVING AVG(Popularity) > 0

) as album_song_pop_avg
ORDER BY Most_Song_Popularity DESC;


--Getting Top 5 most popular song from each Artist
SELECT *
FROM (
	SELECT TOP 5 Album,Artist,Name,Popularity
	FROM Eminem_Updated
	ORDER BY Popularity DESC
	UNION
	SELECT TOP 5 Album,Artist,Name,Popularity
	FROM FiftyCent_Updated
	ORDER BY Popularity DESC
	UNION
	SELECT TOP 5 Album,Artist,Name,Popularity
	FROM GEazy_Updated
	ORDER BY Popularity DESC
	UNION
	SELECT TOP 5 Album,Artist,Name,Popularity
	FROM Logic_Updated
	ORDER BY Popularity DESC

) AS top_songs
ORDER BY Popularity DESC;



--Looking at all artists songs with the most tempo
SELECT * 
FROM (
	SELECT Album,Artist,Name,Tempo
	FROM Eminem_Updated
	UNION
	SELECT Album,Artist,Name,Tempo
	FROM FiftyCent_Updated
	UNION
	SELECT Album,Artist,Name,Tempo
	FROM GEazy_Updated
	UNION
	SELECT Album,Artist,Name,Tempo
	FROM Logic_Updated
) AS song_tempo
WHERE Name NOT LIKE '%Skit%' AND Name NOT LIKE '%Announcement%'
ORDER BY Tempo DESC;




--Looking at all songs with the most Valence
SELECT *
FROM(
	SELECT Album,Artist,Name,Valence
	FROM Eminem_Updated
	UNION
	SELECT Album,Artist,Name,Valence
	FROM FiftyCent_Updated
	UNION
	SELECT Album,Artist,Name,Valence
	FROM GEazy_Updated
	UNION
	SELECT Album,Artist,Name,Valence
	FROM Logic_Updated
) AS song_valence
WHERE Name NOT LIKE '%Skit%' AND Name NOT LIKE '%Announcement%'
ORDER BY Valence DESC;




--Looking at All songs with the most Energy
SELECT *
FROM(
	SELECT Album,Artist,Name,Energy
	FROM Eminem_Updated
	UNION
	SELECT Album,Artist,Name,Energy
	FROM FiftyCent_Updated
	UNION
	SELECT Album,Artist,Name,Energy
	FROM GEazy_Updated
	UNION
	SELECT Album,Artist,Name,Energy
	FROM Logic_Updated
) AS song_energy
WHERE Name NOT LIKE '%Skit%' AND Name NOT LIKE '%Announcement%'
ORDER BY Energy DESC;

