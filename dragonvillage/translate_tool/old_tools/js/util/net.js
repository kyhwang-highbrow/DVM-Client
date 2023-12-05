const http = require( "http" );

exports.get = function( $url, $callback )
{
	http.get( $url, function( $res )
	{
		var body = "";
		$res.on( "data", function( $data )
		{
			body += $data;
		} );
		$res.on( "end", function()
		{
			$callback( body );
		} );
	} );
}