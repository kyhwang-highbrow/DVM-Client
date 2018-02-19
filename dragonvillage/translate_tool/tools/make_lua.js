const fs = require( "fs" );
const path = require( "path" );
const spreadsheet = require( "../js/spreadsheet" );
const util = require( "../js/util" );
const log = util.log;

const Lua = require( "../js/lua" );

var isDebug = false;
var hod_root = process.env.HOD_ROOT;
if( isDebug )
	hod_root = "C:/Work_Perplelab/dragonvillage/res/emulator/translate_tool";

log( "Project root : " + hod_root );

if( !fs.existsSync( hod_root ) )
{
	console.log( "환경변수 HOD_ROOT 가 설정되어 있지 않거나 잘못되었습니다 : " + hod_root );

	return
}

const tmpDir = "./backup/";

make();

function make()
{	
	var sheetNames = process.argv[ 2 ];
	var sheetID = process.argv[ 3 ];
	var locales = process.argv[ 4 ];
	var localeIdx = 0;

	if( isDebug )
	{
		sheetNames ="test_onlyingame;test_onlyscenario";
		sheetID = "1s3m5A7rl4JHngXFknMd3MTkbf0vVaAIPoRx3GPHJvoo";
		locales = "en;jp;zhtw";
	}

	var localeList = locales.split(";");

	function makeLua()
	{		
		if( localeIdx < localeList.length )
		{
			log("Start MakeLua : " + localeList[ localeIdx ] );
			new Lua( sheetNames, localeList[ localeIdx ], sheetID, function( $text )
			{
				saveFile( "lang_" + localeList[ localeIdx ] + ".lua", $text );

				++localeIdx;
				makeLua();
			} )			
		}
	}

	makeLua();
}

function saveFile( $file, $data )
{
	util.file.mkdir( tmpDir );
	util.file.writeFile( tmpDir + $file, $data );
	util.file.writeFile( hod_root + "/../translate/" + $file, $data );
}
