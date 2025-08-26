type GetRequest { key: string }
type GetResponse { value?: undefined }
type PutRequest  { key: string value: undefined hasChanged? : void oldValue? : void }
type PutResponse { hasChanged? : bool oldValue? : undefined }
type DelRequest  { key: string hasChanged? : void oldValue? : void }
type DelResponse { hasChanged? : bool oldValue? : undefined }
type KeysResponse { key*: string }

from console import Console
interface DBAPI {
  requestResponse: 
    get( GetRequest )( GetResponse ),
    put( PutRequest )( PutResponse ),
    del( DelRequest )( DelResponse ),
    clear( void )( void )
}
from values import Values

service DB {
  execution: concurrent
  embed Values as values
  embed Console as console

  inputPort input {
    location: "socket://localhost:8080"
    protocol: sodep
    interfaces: DBAPI
  }

  main {
    [ get( request )( response ){
      if ( is_defined( global.db.( request.key ) ) )
        println@console("hej")()
        response.value -> global.db.( request.key )
    } ]
    [ put( request )( response ){
      present = is_defined( global.db.( request.key ) )
      value -> global.db.( request.key )
      if ( is_defined( request.oldValue ) && present )
        response.oldValue << value
      if ( is_defined( request.hasChanged ) )
        response.hasChanged = !present || !equals@values( { fst -> value snd -> request.value } )
      global.db.( request.key ) << request.value 
    } ]
    [ del( request )( response ){      
      present = is_defined( global.db.( request.key ) )
      if ( is_defined( request.oldValue ) && present )
        response.oldValue << global.db.( request.key )
      if ( is_defined( request.hasChanged ) )
        response.hasChanged -> present
      undef( global.db.( request.key ) )
    } ]
    [ clear()() { undef(global.db) } ]
  }
}