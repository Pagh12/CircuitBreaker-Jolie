from .db import DBAPI
from time import Time
from console import Console
from string_utils import StringUtils

type autoPurgeKeysRequest { autoPurge : bool }
type autoPurgeKeysResponse { autoPurge : bool }

type setPurgeTimeRequest { time : int }
type setPurgeTimeResponse { time : int }

type limitKeysRequest { limit : int }
type limitKeysResponse { limit : int }

type keyPopularityRequest { key : string popularity : bool }
type keyPopularityResponse { popularity : bool }

type autoRefreshKeyRequest { key : string autoRefresh : bool }
type autoRefreshKeyResponse { autoRefresh : bool }

type setAgeKeyRequest { key : string age : int }
type setAgeKeyResponse { age : int }



from scheduler import Scheduler
//needs to set default : jobname and groupname
type SchedulerCallBackRequest: void {
    jobName: string
    groupName: string
    }

interface CacheAPI {
    requestResponse:
        //automatically purging expired keys - 
        autoPurgeKeys(autoPurgeKeysRequest)(autoPurgeKeysResponse),
        // Sets expiry times in ms
        setPurgeTime(setPurgeTimeRequest)(setPurgeTimeResponse),
        // limit the number of keys in the cache
        limitKeys(limitKeysRequest)(limitKeysResponse),
        // tracks popularity of certain key
        keyPopularity(keyPopularityRequest)(keyPopularityResponse),
        // autorefreshes a key 
        autoRefreshKey(autoRefreshKeyRequest)(autoRefreshKeyResponse),
        // set an age for a key instead of default
        setAgeKey(setAgeKeyRequest)(setAgeKeyResponse),
    OneWay:
        //updates program every 1 minute
        schedulerCallback( SchedulerCallBackRequest )
}



service Cache {
    execution: concurrent
    embed Time as time
    embed StringUtils as stringUtils
    embed Console as console
    embed Scheduler as scheduler
    outputPort db {
        location: "auto:json:db.location:file:config.json"
        protocol: sodep
        interfaces: DBAPI
    }

    inputPort input {
        location: "local"
        protocol: sodep
        interfaces: CacheAPI
        aggregates: db
    }

    init {
        global.default_MAX_AGE = 50000
        global.default_key_limit = LIMIT_KEYS
        global.auto_purge_keys = false
        global.cacheCounter = 0
        global.cacheLimit = 1000000000 // high number to simulate infinite
        setCallbackOperation@scheduler( { operationName = "schedulerCallback" }) 
        setCronJob@scheduler( {
            //defaults
            jobName = "myjobname"
            groupName = "myGroupName"
            //time
            cronSpecs << {
                    second = "0"
                    minute = "0/1"
                    hour = "*"
                    dayOfMonth = "1/1"
                    month = "*"
                    dayOfWeek = "?"
                    year = "*"
            }
        })()
        enableTimestamp@console( true )()
    }

    courier input {
        [get(request)(response) {
            getCurrentTimeMillis@time()(ms)
            cache_entry << global.cache.entries.(request.key)

            // if last entry of the key is above max age or if cache is not defined we get it from DB
            if (!is_defined(cache_entry.data) || (ms - cache_entry.timestamp) > global.default_MAX_AGE) {
                // not in cache
                println@console("forwarded to db")()
                forward(request)(response)
                // update cache
                global.cache.entries.(request.key) << {
                    data = response.data,
                    timestamp = ms
                }
                }
             else {
                // Increment hitcount if popularity is turned on
                if (global.cache.entries.(request.key).popularity == true) {
                    global.cache.entries.(request.key).hitcount = global.cache.entries.(request.key).hitcount + 1
                }
                valueToPrettyString@stringUtils(global.cache)(str)
                println@console(str)()
                response.value = cache_entry.data
            }
        }
    
        ]

        [put(request)(response) {
            if (global.cacheCounter < global.cacheLimit){
                // initialize all fields for cache
                    global.cache.entries.(request.key) << {
                        data = request.value,
                        timestamp = getCurrentTimeMillis@time()
                        popularity = false
                        autoRefresh = false
                        age = global.default_MAX_AGE
                    }
            }
            global.cacheCounter = global.cacheCounter + 1
            forward(request)(response)
        }]

        [del(request)(response) {
            undef(global.cache.entries.(request.key))
            global.cacheCounter = global.cacheCounter - 1
            forward(request)(response)
        }]

        [clear(request)(response) {
            undef(global.cache)
            global.cacheCounter = 0
            forward(request)(response)
        }]
    }

    main {
        
        // auto purges expired keys
        [autoPurgeKeys(request)(response) {
            global.auto_purge_keys = request.autoPurge
            response.autoPurge = global.auto_purge_keys
        }]

        // sets default purgeTime
        [setPurgeTime(request)(response) {
            global.default_MAX_AGE = request.time
            response.time = global.default_MAX_AGE
        }]

        // limits the number of keys
        [limitKeys(request)(response) {
            global.cacheLimit = request.limit
            response.limit = global.cacheLimit
        }]

        // Turns on key popularity
        [keyPopularity(request)(response) {
            global.cache.entries.(request.key).popularity = request.popularity
            response.popularity =  global.cache.entries.(request.key).popularity
        }]

        // sets on autorefresh
        [autoRefreshKey(request)(response) {
            global.cache.entries.(request.key).autoRefresh = request.autoRefresh
            response.autoRefresh = global.cache.entries.(request.key).autoRefresh  // Key not found, cannot refresh
            
        }]
        // sets an age for a key
        [setAgeKey(request)(response) {
            global.cache.(request.key).age = request.age
            response.age = global.cache.(request.key).age
        }]
        // updates everything
        [schedulerCallback(request)]{
            currentTime = getCurrentTimeMillis@time()
            with (global.cache.entries ) {
                entry = global.cache.entries.(key)
                if(entry.age > default_MAX_AGE){
                    undef(entry)
                }
                if(entry.autoRefresh){
                    entry.timestamp = getCurrentTimeMillis@time()
                }
                if(autoPurgeKeys){
                    if( (currentTime - entry.timestamp ) > default_MAX_AGE){
                        undef(entry)
                    }
                }
            }
        }

        

    }
    }
