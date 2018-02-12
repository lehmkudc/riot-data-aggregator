rm( list=ls())

# Overall things to keep in workspace
APIKEY <- "RGAPI-30df3d36-a154-46c9-8965-4343c45a0abe"
setwd( "C://Users/Dustin/Dropbox/My Dropbox/Stat Work/Riot fun")
library(rjson)
options(stringsAsFactors = FALSE)
options(scipen=99)
# =============================================================

seed_player <- 'LibertyV VGraves'
patch_live <- Sys.time() - as.difftime(6,unit='days')
current_time <- Sys.time() - as.difftime(1,unit='hours')

begintime <- patch_live; endtime <- current_time

get_seedId <- function(name){
   # From a player name, call API, get accountId
   get_summoner <- "https://na1.api.riotgames.com/lol/summoner/v3/summoners/by-name/"
   query <- paste0(get_summoner,name,'?api_key=',APIKEY)
   account <- fromJSON( file = query )
   return(account$accountId)
}

get_recent <- function(accountId , begintime, endtime){
   # From accountId, call API, get recent_games json
   get_recent <- 'https://na1.api.riotgames.com/lol/match/v3/matchlists/by-account/'
   
   recent <- fromJSON(file= paste0(get_recent,accountId,'?endTime=',round(as.numeric(endtime)*1000),
                                   '&beginTime=',round(as.numeric(begintime)*1000),
                                   '&queue=420&season=11&api_key=',APIKEY) )
   return(recent)
}

get_match <- function(matchId){
   # From matchId, call API, get match json
   g_match <- 'https://na1.api.riotgames.com/lol/match/v3/matches/'
   query = paste0( g_match, matchId, '?api_key=',APIKEY )
   return( fromJSON(file=query) )
}

ext_players <- function(match){
   # From match json, extract all accountIds and highest season tier
   m <- match$participantIdentities
   n <- match$participants
   p <- list()
   p[[1]] <- list(m[[1]]$player$accountId , n[[1]]$highestAchievedSeasonTier)
   p[[2]] <- list(m[[2]]$player$accountId , n[[2]]$highestAchievedSeasonTier)
   p[[3]] <- list(m[[3]]$player$accountId , n[[3]]$highestAchievedSeasonTier)
   p[[4]] <- list(m[[4]]$player$accountId , n[[4]]$highestAchievedSeasonTier)
   p[[5]] <- list(m[[5]]$player$accountId , n[[5]]$highestAchievedSeasonTier)
   
   p[[6]] <- list(m[[6]]$player$accountId , n[[6]]$highestAchievedSeasonTier)
   p[[7]] <- list(m[[7]]$player$accountId , n[[7]]$highestAchievedSeasonTier)
   p[[8]] <- list(m[[8]]$player$accountId , n[[8]]$highestAchievedSeasonTier)
   p[[9]] <- list(m[[9]]$player$accountId , n[[9]]$highestAchievedSeasonTier)
   p[[10]]<- list(m[[10]]$player$accountId, n[[10]]$highestAchievedSeasonTier)
   return(p)
}

ext_accountId <- function( players , allowed = c('PLATINUM','DIAMOND','MASTER','CHALLENGER') ){
   out <- c()
   for (p in players){
      if (p[[2]] %in% allowed){
         out <- c(out, p[[1]] )
      }
   }
   return(out)
}

ext_champions <- function( match ){
   # From match json, extract all champions played and winning team
   m <- match$participants
   p <- list()
   for (i in 1:10){
      team <- m[[i]]$teamId == '100'
      champ <- m[[i]]$championId
      role <- m[[i]]$timeline$role
      lane <- m[[i]]$timeline$lane
      
      if (lane == 'BOTTOM'){
         if (role == 'DUO_CARRY'){
            lane <- 'BOT'
         } else if (role == 'DUO_SUPPORT'){
            lane <- 'SUPPORT'
         }
      }
      p[[i]] <- c( team, champ, lane )
   }
   p <- data.frame(matrix(unlist(p), nrow = 10,byrow=T))
   out <- rep(NA,12)
   out[1] <- match$gameId
   out[2] <- p$X2[p$X1==T & p$X3=='TOP']
   out[3] <- p$X2[p$X1==T & p$X3=='JUNGLE']
   out[4] <- p$X2[p$X1==T & p$X3=='MIDDLE']
   out[5] <- p$X2[p$X1==T & p$X3=='BOT']
   out[6] <- p$X2[p$X1==T & p$X3=='SUPPORT']
   
   out[7] <- p$X2[p$X1==F & p$X3=='TOP']
   out[8] <- p$X2[p$X1==F & p$X3=='JUNGLE']
   out[9] <- p$X2[p$X1==F & p$X3=='MIDDLE']
   out[10] <- p$X2[p$X1==F & p$X3=='BOT']
   out[11]<- p$X2[p$X1==F & p$X3=='SUPPORT']
   
   t1 <- match$teams[[1]]$teamId
   w1 <- match$teams[[1]]$win
   
   if (t1 =='100'){
      out[12] <- ifelse(w1 =='Win', 1,0)
      }
   if (t1 != '100'){
      out[12] <- ifelse(w1 =='Win',0,1)
   }
   return( as.numeric(out))
}

ext_patch <- function( match ){
   # From match json, extract patch info (useful in debugging)
   p <- list()
   p$patch <- match$gameVersion
   p$create <- match$gameCreation
}

ext_matchId <- function( recent ){
   # From recent_games json, extract matchId's
   m <- recent$matches
   n <- length(m); m_out <- rep(NA,n)
   for (i in 1:n){
      m_out[i] <- m[[i]]$gameId
   }
   return(m_out)
}

init_house <- function(){
   # Build the mostly empty dataframe house
   house <- list()
   house$player_queue <- c( get_seedId(seed_player) )
   house$match_queue <- c()
   house$player_heap <- c()
   house$match_heap <- c()
   house$champ_data <- data.frame( matrix(ncol = 12, nrow =0) )
   colnames(house$champ_data) <- c('matchId','t1_top','t1_jun','t1_mid',
                                   't1_bot','t1_sup','t2_top','t2_jun',
                                   't2_mid','t2_bot','t2_sup','t1_win')
   return( house )
}

explore_player <- function( house ){
   # Takes the first player in the player_queue
   #     Extracts all of their recent matches and dumps them into the match_queue
   #     and removes player from player_queue and into player_heap
   if( length(house$player_queue) == 0 ){
      return( house )
   }
   recent <- get_recent( house$player_queue[1], begintime, endtime )
   new_match <- ext_matchId( recent )
   for (m in new_match){
      if( !(m %in% house$match_heap) ){
         house$match_queue <- c( house$match_queue , m)
      }
   }
   house$player_heap <- c( house$player_heap , house$player_queue[1] )
   house$player_queue <- house$player_queue[-1]
   return(house)
}

explore_match <- function( house ){
   # Takes the first match in the match_queue. If it doesnt follow normal
   #     roles for a game, dump and continue until one does.
   #     Extracts all game data, and player ids and dumps them
   #     and removes matchid from match_queue and into match_heap
   ok <- F
   while (ok == F){
      if( length(house$match_queue) == 0){
         return( house )
      }
      print( house$match_queue )
      match <- get_match( house$match_queue[1] )
      print(match$gameId)
      if('try-error' %in% class( try(ext_champions(match),silent=T) ) ){
         house$match_heap <- c( house$match_heap, house$match_queue[1] )
         house$match_queue <- house$match_queue[-1]
      } else {
         ok <- T
      }
   }
   playerId <- ext_accountId(ext_players(match))
   champ <- ext_champions( match )
   for (p in playerId){
      if( !(p %in% house$player_heap) ){
         house$player_queue <- c(house$player_queue, p)
      }
   }
   house$champ_data[nrow(house$champ_data)+1,] <- champ
   house$match_heap <- c( house$match_heap, house$match_queue[1] )
   house$match_queue <- house$match_queue[-1]
   return( house )
}

house <- init_house()
house <- explore_player(house)
house <- explore_match(house)
house

