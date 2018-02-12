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
A: League of Legends is a multiplayer MOBA (multiplayer online battle arena) video game developed and published by Riot Games. As of this readme it is the most popular MOBA on the market and has a playerbase of 27 million players daily, with concurrent numbers at 7.5 million. The primary game mode known as "Summoner's Rift" pits two (mostly) random selected teams of 5 against eachother with the goal of destroying the opposing team's base. The players control what are known as "champions" which is the character they play as for the duration of the match. Each champion is different and often have good and bad matchups.

## Q: What are the basic rules of the game?
A: While there are many game modes available, the one I am analyizing is 5v5 ranked Summoner's rift. In each game, a team of 5 players of roughly equivalent skill rating will be placed in a champion select screen where they choose their champions.
![Champion Slect](http://1.bp.blogspot.com/-zBW9ddKa78c/Vjl5J8dqg6I/AAAAAAAA0AA/-YjBuRpdMdI/s1600/bluepick.jpg)  
Each player has an assigned role, or lane, that determines in general what their job is for the particular game. As such, there are typically selected champions for each role. There are often better or worse champions depending on what other people are playing. Since champions are picked in a draft format, players often see some of the champions they will be playing with and against and can therefore determine what champion they want to play with this information. A surprising amount of advantage can be gained by knowing the appropriate champion to play in a given situation.

## Q: Why address this projet at all? Aren't there plenty of websites that aggregate LoL data and determine various counters?
