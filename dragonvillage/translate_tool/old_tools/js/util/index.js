const fs = require( "fs" );
const path = require( "path" );

const dir = __dirname;

var files = fs.readdirSync( dir );
var i = 0;
var len = files.length;
var file;
for( i ; i < len ; i++ )
{
	file = files[ i ];

	if( file.indexOf( ".svn" ) > -1 )
		continue;

	var name = file.split( "." )[ 0 ];

	if( name == "index" )
		continue;
	exports[ name ] = require( __dirname + "/" + file );
}

exports.deepCopy = function( $object )
{
	var object = JSON.parse( JSON.stringify( $object ) );

	return object;
}