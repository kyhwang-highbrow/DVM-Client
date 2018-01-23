const fs = require( "fs" );
const path = require( "path" );
const csv = require( "csv" );
const util = require( "../../js/util" );

module.exports = ExtractFromScenario;

var data = {};
data.length = 0;
function ExtractFromScenario( $directory, $ignoreFiles, $ignoreFolders )
{
	this.directory = $directory + "/";
	this.ignoreFiles = $ignoreFiles;
	this.ignoreFolders = $ignoreFolders;
	data = [];
}

ExtractFromScenario.prototype.collect = function( $callback )
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
		var hearderList = {};
		if( len > 0 )
			header = lines[0];
		else
			header = null;

		for( var i = 0; i < header.length; ++i )
		{
			if( header[i] != "t_char_name" && header[i] != "page" && header[i] != "char" && header[i] != "t_text" && header[i].indexOf("effect_") < 0 )
				continue;
			
			hearderList[ header[i] ] = i;
		}
		
		var i = 1;
		for( i ; i < len ; i++ )
		{
			line = lines[ i ];

			parseLine( line, hearderList );
		}

		$callback();
	} );

	function parseLine( $line, $hearderList )
	{
		var pushHeader = $hearderList;
		var page = $line[ pushHeader.page ];
		var char = $line[ pushHeader.char ];
		//기본으로 t_char_name이지만 대부분 char에 들어있다.
		var t_char_name = $line[ pushHeader.t_char_name ];
		if( t_char_name.length <= 0 && char.length > 0 )
			t_char_name = char;
		var t_text = $line[ pushHeader.t_text ];
		var reg = /[가-힣]+/g;					
		if( t_text.length > 0 && reg.exec( t_text ) != null )
		{
			var basename = path.basename( $path );
			var str = t_text.replace(/\n|\r\n/g, "\\n");
			var tempData = [ basename, page, t_char_name, str ];
			data.push( tempData );
		}				

		//effect_ 시리즈
		var effectIdx = 1;
		var effectHeaderIdx = pushHeader["effect_" + effectIdx];
		while( effectHeaderIdx )
		{
			var effectVal = $line[effectHeaderIdx];
			if( effectVal )
			{
				if( effectVal == "title;귀찮은 작업")
					var a = 0;

				if( effectVal.length > 0 && reg.exec( effectVal ) != null )
				{
					//따로 추가해준다.
					var tokenList = effectVal.split(";");
					for( var i in tokenList )
					{
						var effectText = tokenList[i]
						if( reg.exec( effectText ) != null )
						{
							var basename = path.basename( $path );
							var str = t_text.replace(/\n|\r\n/g, "\\n");
							var tempData = [ basename, page, "", effectText ];
							data.push( tempData );
						}
					}
					
				}
			}

			++effectIdx;
			effectHeaderIdx = pushHeader["effect_" + effectIdx];
		}
		
	}
}
