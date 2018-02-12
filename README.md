# League of Legends Data Collector/Crawler
(PROTOTYPE) Functions to call the Riot API for League of Legends, extract relevant information, and obtain new matches.


Hello!

My name is Dustin Lehmkuhl and I am a chemical engineering graduate student and hobbyist data scientist/programmer. I tend to make a bunch of crappy, nerdy projects in order to massively overanalyze my favorite things and learn more about data management, statistical analysis, and software develoment. Here is one such project.


## At a glance Status:
12 Feb 2018:  
The first set of R functions are built and the proof of concept seems fairly solid. The current build is capable of manually building a dataset using the explore_player() and the explore_match functions(). Theoretically with enough clicking the temporary "House" database should propagate and empty as needed to create a useful data table including the keys for the various champions played in a series of games.

## Q: What is this project about?
A: My goal is to build a web app that determines the best champions to choose while in champion select based on ally and enemy champions already picked. This process should take into account champion synergy and potential counter picks. In order to accomplish this, a dataset needs to be generated. Since there isn't a grand table giving me all the champions picked for every game played in a particular patch, I need to use the Riot API (v3) and be relatively clever with my GET statements. The prototype will be built using only R, but will e upgraded using a more efficient language for making transactions to a SQL database. From there a model will be pickled using the data collected from the crawler, and accessed through a web app (likely RShiny or HTML).

## Q: What is League of Legends? What is Riot?
A: League of Legends is a multiplayer MOBA (multiplayer online battle arena) video game developed and published by Riot Games. As of this readme it is the most popular MOBA on the market and has a playerbase of 27 million players daily, with concurrent numbers at 7.5 million. The primary game mode known as "Summoner's Rift" pits two (mostly) random selected teams of 5 against eachother with the goal of destroying the opposing team's base. The players control what are known as "champions" which is the character they play as for the duration of the match. Each champion is different and often have good and bad matchups. Riot API: https://developer.riotgames.com/getting-started.html


## Q: What are the basic rules of the game?
A: While there are many game modes available, the one I am analyizing is 5v5 ranked Summoner's rift. In each game, a team of 5 players of roughly equivalent skill rating will be placed in a champion select screen where they choose their champions.
![Champion Slect](http://1.bp.blogspot.com/-zBW9ddKa78c/Vjl5J8dqg6I/AAAAAAAA0AA/-YjBuRpdMdI/s1600/bluepick.jpg)  
Each player has an assigned role, or lane, that determines in general what their job is for the particular game. As such, there are typically selected champions for each role. There are often better or worse champions depending on what other people are playing. Since champions are picked in a draft format, players often see some of the champions they will be playing with and against and can therefore determine what champion they want to play with this information. A surprising amount of advantage can be gained by knowing the appropriate champion to play in a given situation.

## Q: Why address this projet at all? Aren't there plenty of websites that aggregate LoL data and determine various counters?
A: Yes, but this project is not for selling. I'm doing this project for a number of reasons:  
-- I'm building a portfolio for employment. I desperately needed some SQL database management examples to show potential employers as this was a skill I picked up but never officially used before.  
-- I felt like I had almost enough knowledge to make something like this work. This to me means that this is a perfect project to spend some idle time on between my heavier projects (https://github.com/lehmkudc/magic-image-classification, https://www.kaggle.com/lehmkudc as examples of things that are more intensive for me).  
-- This is the type of program that I would personally use, and as such I have some things that I would do differently if I were making it for myself.  

## Q: You mentioned needing to be clever when calling the Riot API. What do you mean specifically?
A: The current Riot API only allows for match data to be called if you have the particular match ID for it. While you could theoretically call every number with at least 10 digits, you will likely hit dead links, non-ranked games, games outside of the patch you are studying, and overall call way more matches than you or Riot would like you to. Unfortunately if there is a master table of ranked match ID's for the current patch played by players of Platinum rating or above, I haven't found it yet. However, match ID's are able to be fetched from a player's recent match history. This allows me to take a seeded player who is guaranteed to play at least one ranked game at plat+, gather all the recent game Id's from that player, then determine the player IDs from each of those matches, and crawl through matches until a sufficient number of games have been collected.

## Q: So how does your code accomplish this?
A: Currently my code is a series of functions.  
-- get_xxxxxx(): Call the Riot API using some known piece of information.  
-- extract_xxxxxxx(): Take the JSON object from an API call and extact some piece of information from it.  
-- explore_xxxxxxx(): Perform an aggregation step using the above funcitons to take an ID and generate data and more ID's to search.

## Q: How is your data being stored?
A: Currently its all being stored in a "house" list in the R environment as a prototype. I wanted to make sure my functions worked before setting up transations in SQL. Eventually I will have the following data structures:  
-- The target data table, which contains the foreign keys of champions selected for both teams, which team won, and the matchId (pk).  
-- A queue for accountId. this tracks what collected players are left to determine match history.
-- A queue for matchId. this tracks what games need data and players extracted from.
-- Heaps for used accountId's and matchId's. I'm using heaps here so I can easily search if I've used a player or match before (as there is an inherent numerical ordering to both id's).
-- Champion ID table (so i dont need to store strings in my giant data table).

## Q: I like your work and energy. How can I get in contact with you for an Interview?
A: I can be most easily reached at LEHMKUDC@gmail.com or by phone at (317)-410-0780.
