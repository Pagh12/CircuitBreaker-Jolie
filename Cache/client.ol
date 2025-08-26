from console import Console
from .db import DB, DBAPI
from .cache import Cache
from time import Time
from string_utils import StringUtils


from types.Binding import Binding
// ---------- Test service to check Cache-----------------
//      default settings for Cache : 
//             - max age of key = 50000 
//             - auto purge expired keys = false
//             - cache limit = 10000 (size of cache)
// 
// config.json should be reconfigured for a database in case of usage

// ---------- Refigure cache ---------
//       max age = setPurgeTime(time : int)(time : int)
//       auto purge = autoPurgeKeys(autoPurge : bool)(autoPurge : bool)
//       cache size = limitKeys(limit : int )( limit: int) -> if full, go to db
//       key popularity = keyPopularity(key : string popularity : bool )(popularity : bool )  -> tracks how popular a key is
//       auto refresh a key = autoRefreshKey(key : string autoRefresh : bool)(autoRefresh : bool)
//       set an age for a key = setAgeKey(key : string age : int )( age : int) 
//       
// --------------User
//          - All functions will perform effects on a tree in cache | if no tree is present, it will make one
// -------------
//        performs check every 1 minute 
//            - auto purge check    
//            - Key popularity check
//            - auto refresh key check
//            - custom age check

service Test  {
  embed Console as console
  embed Time as time
  embed Cache as cache
  embed StringUtils as stringUtils

  main {
    clear@cache()()
    put@cache( {key = "banan" value = 2} ) (response)
    get@cache({key = "banan"})()
    //keyPopularity@cache({key = "banan" popularity = true})()

    // autoRefreshKey@cache({key = "banan" autoRefresh = true})(response)

    // get@cache({key = "banan"})()
    // del@cache({key = "banan"})(response)
    // put@cache( {key = "æble" value = 2} ) (response)
    // autoPurgeKeys@cache({autoPurge = true})(response)
    // setPurgeTime@cache({time= 500})(reponse)
    // sleep@time(600)()
    // get@cache({key = "banan"})()

    // // test setAge - writing out
    // put@cache( {key = "æble" value = 2} ) (response)
    // setAgeKey@cache({key = "æble" age = 100})()
    // sleep@time(200)()
    // get@cache({key = "æble"})()
  }
}