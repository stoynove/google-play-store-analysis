Data Source: https://www.kaggle.com/datasets/lava18/google-play-store-apps?datasetId=49864&searchQuery=sql&select=googleplaystore_user_reviews.csv 

I cleaned a scraped dataset of apps from the Google Play store by converting data types, removing duplicates entries, creating, and joining tables together in SQL Server and more. 

SQL Skills used:
- Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Converting Data Types


Interesting findings:
 - The apps with the most duplicates are (9) ROBLOX, (8) CBS Sports App - Scores, News, Stats & Watch Live , Candy Crush Saga, (7) 8 Ball Pool, 
   Duolingo: Learn Languages Free , ESPN , (6)slither.io , Sniper 3D Gun Shooter: Free Shooting Games - FPS, Subway Surfers, Temple Run 2, Zombie Catchers, Helix Jump,
   Nick, Bleacher Report: sports news, scores, & highlights, Bowmasters.
      Most of these apps are game-related so it's possible the web scraper picked them up the most because they are from other sections of the play store like the game section.
      
 - It is not always correct to remove duplicate entries for bot reviews for example as you might end up removing human reviews in the process. 
      
Further work that can be done:
 - Run a regression to predict the missing values of ratings. 
   We can also measure our model accuracy by taking the ratings we already know and splitting that into a training and test set
