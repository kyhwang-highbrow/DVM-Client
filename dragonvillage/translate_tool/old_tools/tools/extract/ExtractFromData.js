const fs = require( "fs" );
const path = require( "path" );
const csv = require( "csv" );
const util = require( "../../js/util" );

module.exports = ExtractFromData;

var data = {};
data.length = 0;
function ExtractFromData( $directory, $ignoreFiles, $ignoreFolders )
{
	this.directory = $directory + "/";
	this.ignoreFiles = $ignoreFiles;
	this.ignoreFolders = $ignoreFolders;
	data = {};
	data.length = 0;
}

ExtractFromData.prototype.collect = function( $callback )
{
	var option = {};
	option.ignoreFiles = this.ignoreFiles;
	option.ignoreExtensions = [ ".bak", ".proto", ".svn-base" ];	
	option.ignoreFolders = this.ignoreFolders;

	if(fs.existsSync(this.directory) == false )
	{
		$callback( data );
		return;
	}

	var allFiles = util.file.getAllFiles( this.directory, option );

	getNextStr();

	function getNextStr()
	{
		if( allFiles.length == 0 )
		{
			$callback( data );

			return;
		}
		var file = allFiles.shift();

		if( path.extname( file ) == ".csv" )
			getStr( file, getNextStr );
		else
			getNextStr();
	}
}

function getStr( $path, $callback )
{
	var text = fs.readFileSync( $path, "utf-8" ).toString();
	var header;
	csv.parse( text, function( $err, $data )
	{
		var lines = $data;		
		var len = lines.length;
		var line;
		if( len > 0 )
			header = lines[0];
		else
			header = null;

		var i = 1;
		for( i ; i < len ; i++ )
		{
			line = lines[ i ];

			parseLine( line );
		}

		$callback();
	} );

	function parseLine( $line )
	{
		var i = 0;
		var len = $line.length;
		var str;
		for( i ; i < len ; i++ )
		{
			str = $line[ i ];
			
			//t_ 붙은것만
			if( header[i].indexOf("t_") < 0 )
				continue;

			var reg = /[가-힣]+/g;
			if( reg.exec( str ) == null )
				continue;
			
			//str = str.replace(/\n|\s\n/g, "\\n");
			str = str.replace(/\n|\r\n/g, "\\n");			

			if( data[ str ] == null )
				data[ str ] = { hints : [] };

			var basename = path.basename( $path );

			if( data[ str ].hints.indexOf( basename ) == -1 )
			{
				data[ str ].hints.push( basename );
				data.length++;
			}
		}
	}
}

function splitToArray( $text, $count )
{
	var arr = $text.split( "," );
	var list = [];
	var i = 0;
	var len = $count - 1;
	for( i ; i < len ; i++ )
	{
		list[ i ] = arr.shift();
	}

	list[ len ] = arr.join( "," );

	return list;
}
