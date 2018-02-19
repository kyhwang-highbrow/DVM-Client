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

const ignoreFolder = [
	"data/scenario"
];

// 1. 프로젝트 루트 설정.
var isDebug = false;	//디버그할때 사용하기 위해서
var hod_root = process.env.HOD_ROOT;
if( isDebug )
	hod_root = "C:/Work_Perplelab/dragonvillage/res/emulator/translate_tool";

if( !fs.existsSync( hod_root ) )
{
	console.log( "환경변수 HOD_ROOT 가 설정되어 있지 않거나 잘못되었습니다 : " + hod_root );

	return
}

log( "Start Extract" );
log( "Project root : " + hod_root );

var spreadsheet_id = process.argv[ 3 ];
var sheetName = process.argv[ 2 ] ;	
var locale = process.argv[ 4 ];	
if( isDebug )
{		
	spreadsheet_id = "1s3m5A7rl4JHngXFknMd3MTkbf0vVaAIPoRx3GPHJvoo";
	locale = "en;jp;zhtw";
	sheetName = "test_onlyingame";
}
var localeList = locale.split(';');	

var fromLua = new ExtractFromLua( hod_root + "/../src", ignoreFiles, ignoreFolder ).collect();	// 2. Lua 파일에서 긁어오기.
var fromUI = new ExtractFromUI( hod_root + "/../res", ignoreFiles, ignoreFolder ).collect();	// 3. UI 파일에서 긁어오기.

var fromSvData;
var fromSvPatchData;
new ExtractFromData( hod_root + "/../../sv_tables", ignoreFiles, ignoreFolder ).collect( collectFromSvData );	// 4. sv_data 파일에서 긁어오기.

function collectFromSvData( $data )
{
	fromSvData = $data;
	new ExtractFromData( hod_root + "/../../sv_tables_patch", ignoreFiles, ignoreFolder ).collect( collectFromSvPatchData );	// 5. sv_data_path 파일에서 긁어오기.
}

function collectFromSvPatchData( $data )
{
	fromSvPatchData = $data;
	new ExtractFromData( hod_root + "/../data", ignoreFiles, ignoreFolder ).collect( collectFromData );	// 6. CSV 파일에서 긁어오기.
}

function collectFromData( $data )
{
	var fromData = $data;

	addData( fromLua );
	addData( fromData );
	addData( fromSvData );
	addData( fromSvPatchData );
	addData( fromUI );
	
	list.sort( function( a, b )
	{
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
	log("Upload Start : " + spreadsheet_id);
	log("localeList : "  + localeList.toString());
	new Upload( sheetName, spreadsheet_id, list, localeList );
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
			var tempData = [str];
			for( locale in localeList)
			{
				tempData.push("");
			}
			tempData.push($data[ str ].hints.join( "," ));
			tempData.push(date_str);

			list.push( tempData )

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
