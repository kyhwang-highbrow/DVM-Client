const fs = require( "fs" );
const path = require( "path" );
const util = require( "../../js/util" );

module.exports = ExtractFromUI;

function ExtractFromUI( $directory, $ignoreFiles, $ignoreFolders )
{
	this.directory = $directory + "/";
	this.ignoreFiles = $ignoreFiles;
	this.ignoreFolders = $ignoreFolders;
}

ExtractFromUI.prototype.collect = function()
{
	var option = {};
	option.ignoreFiles = this.ignoreFiles;
	option.ignoreExtensions = [ ".bak", ".proto", ".svn-base" ];
	option.ignoreFolders = this.ignoreFolders;

	var allFiles = util.file.getAllFiles( this.directory, option );

	var i = 0;
	var len = allFiles.length;
	var file;
	for( i ; i < len ; i++ )
	{
		file = allFiles[ i ];

		if( path.extname( file ) != ".ui" )
			continue;

		getStr( file );
	}

	return data;
}

var data = {};
data.length = 0;

function getStr( $path )
{
	var text = fs.readFileSync( $path, "utf-8" ).toString();
	var lines = text.split( "\n" );
	var i = 0;
	var len = lines.length;
	var line;
	for( i ; i < len ; i++ )
	{
		line = lines[ i ];

		if( line.indexOf( "=" ) == -1 )
			continue;

		var reg = /(text|placeholder) = '(.+?)'/
		var arr = reg.exec( line );

		if( arr == null || arr[ 2 ] == null )
			continue;

		var str = arr[ 2 ];

		var reg2 = /[가-힣]/
		if( reg2.exec( str ) == null )
			continue;

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