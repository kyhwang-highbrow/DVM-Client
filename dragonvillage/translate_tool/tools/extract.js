const fs = require( "fs" );
const path = require( "path" );
const util = require( "../js/util" );
const log = util.log;

const ExtractFromLua = require( "./extract/ExtractFromLua" );
const ExtractFromData = require( "./extract/ExtractFromData" );
const ExtractFromUI = require( "./extract/ExtractFromUI" );
const Upload = require( "./upload" );

const ignoreFiles = [
	"table_ban_word_chat.csv",
	"table_ban_word_naming.csv"
];

// 1. 프로젝트 루트 설정.
var isDebug = false;
//const hod_root = "C:/Work_Perplelab/dragonvillage/res/emulator/translate_tool";//process.env.HOD_ROOT;
var hod_root = process.env.HOD_ROOT;
if( isDebug )
	hod_root = "C:/Work_Perplelab/dragonvillage/res/emulator/translate_tool";

if( !fs.existsSync( hod_root ) )
{
	console.log( "환경변수 HOD_ROOT 가 설정되어 있지 않거나 잘못되었습니다 : " + hod_root );

	return
}

log( "Project root : " + hod_root );

var fromLua = new ExtractFromLua( hod_root + "/../src", ignoreFiles ).collect();	// 2. Lua 파일에서 긁어오기.
var fromUI = new ExtractFromUI( hod_root + "/../res", ignoreFiles ).collect();	// 3. UI 파일에서 긁어오기.

var fromSvData;
var fromSvPatchData;
new ExtractFromData( hod_root + "/../../sv_tables", ignoreFiles ).collect( collectFromSvData );	// 4. sv_data 파일에서 긁어오기.

function collectFromSvData( $data )
{
	fromSvData = $data;
	new ExtractFromData( hod_root + "/../../sv_tables_patch", ignoreFiles ).collect( collectFromSvPatchData );	// 5. sv_data_path 파일에서 긁어오기.
}

function collectFromSvPatchData( $data )
{
	fromSvPatchData = $data;
	new ExtractFromData( hod_root + "/../data", ignoreFiles ).collect( collectFromData );	// 6. CSV 파일에서 긁어오기.
}

function collectFromData( $data )
{
	var fromData = $data;

	addData( fromLua );
	addData( fromData );
	addData( fromSvData );
	addData( fromSvPatchData );
	addData( fromUI );

	function isScenFile( $valeList )
	{
		var hintList = $valeList[2].split(',');		
		var i = 0;
		for(i; i < hintList.length; ++i)
		{
			var str = hintList[i];
			if( str.indexOf("scen_") < 0 )
				return false;
		}

		return true;
	}

	list.sort( function( a, b )
	{
		//hints에 scen_이 있으면 하단으로 
		var isScene_a = isScenFile(a);
		var isScene_b = isScenFile(b);
		if( isScene_a == true && isScene_b == false ) return 1;
		if( isScene_b == true && isScene_a == false ) return -1;

		if( a[ 0 ] < b[ 0 ] ) return -1;
		if( a[ 0 ] > b[ 0 ] ) return 1;
		return 0;
	} );

	log( "Total strings : " + count );
	log( "\t Lua - " + fromLua.length );
	log( "\t UI - " + fromUI.length );
	log( "\t SvData - " + fromSvData.length );
	log( "\t SvPatchData - " + fromSvPatchData.length );
	log( "\t CSV - " + fromData.length );

	startUpload();
}

function startUpload()
{
	var locale = process.argv[ 2 ];
	var spreadsheet_id = process.argv[ 3 ];
	if( isDebug )
	{
		locale = "zhtw";
		spreadsheet_id = "1Cv2vBmWpnVwK74KN6SnL0QKdTpMoAx8VPYDzOi9yks0";
	}

	log("Upload Start : " + locale + ", " + spreadsheet_id);
	new Upload( locale, spreadsheet_id, list);
}

var data = {};
var list = [];
var count = 0;
function addData( $data )
{
	const date_str = util.string.timeToFormat( Date.now() );

	var str;
	for( str in $data )
	{
		if( str == "length" )
			continue;

		if( data[ str ] == null )
		{
			data[ str ] = [];
			list.push( [ str, "", $data[ str ].hints.join( "," ), date_str ] )

			count++;
		}

		var hints = $data[ str ].hints;

		var i = hints.length;
		while( i-- )
		{
			var hint = hints[ i ];

			if( data[ str ].indexOf( hint ) == -1 )
				data[ str ].push( hint );
		}
	}
}

function getRoot()
{
	var root = getArgs( 2 );

	if( root == null )
		throw new Error( "Please pass a path of hod root path." );

	root = path.resolve( __dirname + "/" + root );

	return root;
}

function getArgs( index )
{
	if( process.argv.length > index )
		return process.argv[ index ];

	return null;
}