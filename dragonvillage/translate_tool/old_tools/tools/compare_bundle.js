const fs = require( "fs" );

const HOD_ROOT = process.env.HOD_ROOT;

const dir_translate = HOD_ROOT + "/translate";
const dir_backup = "C:/Users/wooyaggo/Desktop/aaa";

loadTranslate( "en" );

function loadTranslate( $locale )
{
	var a = loadFile( dir_translate + "/" + $locale + "Map.lua" );
	var b = loadFile( dir_backup + "/" + $locale + "Map.lua" );

	var prop;
	for( prop in a )
	{
		if( b[ prop ] == null )
		{
			console.log( prop );
		}
	}

	function loadFile( $file )
	{
		var text = fs.readFileSync( $file ).toString();
		text = text.replace( /\['(.*)'\]='(.*)'/g, "\"$1\":\"$2\"" );
		text = text.replace( "LanguageMap = ", "" );
		text = text.replace( /\\'/g, "'" );
		text = text.replace( /\\(\d)/g, "\\\\$1" );

		var json = JSON.parse( text );

		return json;
	}
}