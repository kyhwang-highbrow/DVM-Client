const fs = require( "fs" );
const path = require( "path" );
const util = require( "../../js/util" );

module.exports = ExtractFromLua;

function ExtractFromLua( $luaDirectory, $ignoreFiles, $ignoreFolders )
{
	this.directory = $luaDirectory + "/";
	this.ignoreFiles = $ignoreFiles;	
	this.ignoreFolders = $ignoreFolders;
}

ExtractFromLua.prototype.collect = function()
{
	var option = {};
	option.ignoreFiles = this.ignoreFiles;
	option.ignoreExtensions = [ ".bak", ".proto", ".svn-base" ];
	option.ignoreFolders = this.ignoreFolders;

	var files = util.file.getAllFiles( this.directory, option );

	var i = 0;
	var len = files.length;
	for( i ; i < len ; i ++ )
	{
		getStr( files[ i ] );
	}

	return data;
}

var data = {};
data.length = 0;

function getStr( $path )
{
	var text = fs.readFileSync( $path, "utf-8" ).toString();
	var reg = /Str\s*\(\s*([\'\"])(.*?)\1/g
	var arr;
	while( (arr = reg.exec( text )) !== null )
	{
		var str = arr[ 2 ];

		// 한글이 하나라도 포함되어야
		if( str.match( /[가-힣]/ ) == null )
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