-- CLEANING THE DATA:
-- Note to reader: I Manually removed the space from Last Updated, Current Ver, and Android Ver and replaced it with "_"
--------------------------------------------------------------------------------------------------
-- Cleaning date format in Last_Updated column:
SELECT  Last_Updated, CONVERT(Date, Last_Updated) AS converted, *
FROM googleplaystore;

ALTER TABLE googleplaystore
ADD new_Last_Updated Date;

UPDATE googleplaystore
SET new_Last_Updated = CONVERT(Date, Last_Updated);

ALTER TABLE googleplaystore
DROP COLUMN Last_Updated;

--rename column.
EXEC sp_rename 'googleplaystore.new_Last_Updated', 'Last_Updated', 'Column';

--------------------------------------------------------------------------------------------------
-- Cleaning the Installs column by
-- removing the '+' and ',' and converting it to a float type: 

SELECT 
REPLACE(Installs, '+', '')
FROM googleplaystore; 

-- Remove the + 
UPDATE googleplaystore
SET Installs = REPLACE(Installs, '+', '')

-- Remove the ,
UPDATE googleplaystore
SET Installs = REPLACE(Installs, ',', '')

-- Remove outliar row
DELETE FROM googleplaystore
WHERE Installs = 'Free'


ALTER TABLE googleplaystore
ADD new_Installs float;

UPDATE googleplaystore
SET new_Installs = CONVERT(int, Installs)

ALTER TABLE googleplaystore
DROP COLUMN Installs;

--rename column
EXEC sp_rename 'googleplaystore.new_Installs', 'Installs', 'Column';

--------------------------------------------------------------------------------------------------
-- Cleaning the type column
SELECT DISTINCT(type), COUNT(type)
FROM googleplaystore
GROUP BY type
ORDER BY 2
-- There are supposed to be 2 types; free and paid, and there is just 1 null value, which we will delete

select *
FROM googleplaystore
where type  = 'NaN'

DELETE FROM googleplaystore
WHERE type  = 'NaN'


select *
FROM googleplaystore
where type  = 'NaN'
-- Nothing!
--------------------------------------------------------------------------------------------------

select rating
FROM googleplaystore
where rating IS NULL

select rating, COUNT(rating)
FROM googleplaystore
GROUP BY rating
ORDER BY 1 DESC

--------------------------------------------------------------------------------------------------
-- Cleaning Ratings Column
-- The only thing we need to fix ratings is the NULL values but there is nothing obvious that we can replace it with.
-- We can run a correlation to see if there is a relation between the game rating and other factors like Size, 
-- Reviews, Installs, Type, Price etc. and run a regression model if there is to have a decent guess. 

SELECT  *
FROM googleplaystore
WHERE rating IS NULL


--------------------------------------------------------------------------------------------------
-- Converting Sentiment to numerical values in user reviews table. 
-- We convert Positive ratings to 5, neutral to 3, and negative to 1, to have it on the same scale as Rating.
-- We can then compare the sentiment ratings on an app to the ratings of an app and see how controversial it is. 

SELECT DISTINCT Sentiment 
FROM googleplaystore_user_reviews;

ALTER TABLE googleplaystore_user_reviews
ADD new_Sentiment float;

UPDATE googleplaystore_user_reviews
SET new_Sentiment = CASE WHEN Sentiment = 'Negative' THEN 1 
WHEN Sentiment = 'Neutral' THEN 3
WHEN Sentiment = 'Positive' THEN 5
ELSE -1 END;


--------------------------------------------------------------------------------------------------
-- Removing Duplicate games:

-- We want to join both our tables together by App name but first we need to make sure there are no duplicate entries
-- as duplicate rows can really overcomplicate everything. 

-- We remove Duplicate Values using CTE and windows functions
-- We will assume the rows should be unique by their app name and rating

SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY App,
				 Rating
				 ORDER BY
				 App
				 )  duplicates
FROM googleplaystore
ORDER BY duplicates DESC
-- From above, we see the most game duplicates is ROBLOX with 9 duplicates. 

-- Delete duplicate games
With RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY App,
				 Rating
				 ORDER BY
				 App
				 ) AS duplicates
FROM googleplaystore
--ORDER BY duplicates DESC
)
DELETE
FROM RowNumCTE
WHERE duplicates > 1


--------------------------------------------------------------------------------------------------
-- Removing Duplicate reviews: 

-- It might seem obvious to try and remove duplicate reviews because of botting but there are some problems with that.
-- First, it is not mandatory to leave a comment on a review, and a lot of reviewers do not leave comments, meaning a lot of 
-- reviews with comment could be from humans even though it is very likely most of them are from bots. 
-- Second, even if we ignore reviews with no comments, reviewers might leave simple 1-2 word reviews like 'good' 
-- which makes it hard to distinguish if a person or bot wrote it. For these reasons, I think it is ineffective to do any analysis on the user_reviews. 

SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY Translated_review
				 ORDER BY
				 App
				 ) AS duplicates
FROM googleplaystore_user_reviews
WHERE Translated_Review <> 'nan'
ORDER BY duplicates DESC

--------------------------------------------------------------------------------------------------
-- Making a Temp Table from Joining googleplaystore with googleplaystore_user_review
-- We will use a left join on googleplaystore to we keep all of the games, even the ones without associated reviews. 
-- We will not use Sentiment_Polarity and Sentiment_Subjectivity because we don't know how it was derived and it could not make sense.

DROP Table if exists #GamesWithReviews
Create Table #GamesWithReviews
(
App nvarchar(255),
Category nvarchar(255),
Rating int,
Reviews int, 
Size nvarchar(255),
Type nvarchar(255),
Price int,
Content_Rating nvarchar(255),
Genres nvarchar(255),
Installs int,
Translated_review nvarchar(255),
new_Sentiment int,
)


Insert into #GamesWithReviews
Select googleplaystore.App, 
googleplaystore.Category, 
googleplaystore.Rating,
googleplaystore.Reviews,
googleplaystore.Size,
googleplaystore.Type,
googleplaystore.Price,
googleplaystore.Content_Rating,
googleplaystore.Genres,
googleplaystore.Installs,
googleplaystore_user_reviews.Translated_review,
googleplaystore_user_reviews.new_Sentiment
FROM googleplaystore
LEFT JOIN googleplaystore_user_reviews
ON googleplaystore.App = googleplaystore_user_reviews.App

-- NULL values in new_Sentiment column are for games that do not have a review associated with them
select *
from #GamesWithReviews


--------------------------------------------------------------------------------------------------
--EXPLORING THE DATA:





SELECT DISTINCT Content_Rating
FROM googleplaystore
--

--Distinct Categories:
SELECT DISTINCT Category
FROM googleplaystoreews.App