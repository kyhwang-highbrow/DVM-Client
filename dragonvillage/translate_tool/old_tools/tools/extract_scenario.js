const fs = require( "fs" );
const path = require( "path" );
const util = require( "../js/util" );
const log = util.log;

const ExtractFromScenario = require( "./extract/ExtractFromScenario" );
const Upload = require( "./upload_scenario" );

const ignoreFiles = [
	"table_ban_word_chat.csv",
	"table_ban_word_naming.csv",
	"scenario_resource.csv",
	"scenario_sample.csv"
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

log( "Start Scenario Extract" );
log( "Project root : " + hod_root );

var spreadsheet_id = process.argv[ 3 ];
var sheetName = process.argv[ 2 ] ;	
var locale = process.argv[ 4 ];	
if( isDebug )
{		
	spreadsheet_id = "1s3m5A7rl4JHngXFknMd3MTkbf0vVaAIPoRx3GPHJvoo";
	locale = "en;jp;zhtw";
	sheetName = "test_onlyscenario";
}
var localeList = locale.split(';');	
new ExtractFromScenario( hod_root + "/../data/scenario", ignoreFiles ).collect( collectFromData );

function collectFromData( $data )
{
	var fromData = $data;
	addData( fromData );
	list.sort( function( a, b )
	{
		//파일이름
		//scene_ 붙은거면 _로 파싱해서 마지막 s 와 e 정렬
		if( a[0].indexOf("scen_") > -1 && b[0].indexOf("scen_") > -1 )
		{
			var aList = a[0].split("_");
			var bList = b[0].split("_");			
			if( Number( aList[1] ) < Number( bList[1] ) ) return -1;
			if( Number( aList[1] ) > Number( bList[1] ) ) return 1;

			if( Number( aList[2] ) < Number( bList[2] ) ) return -1;
			if( Number( aList[2] ) > Number( bList[2] ) ) return 1;

			if( aList[3] > bList[3] ) return -1;
			if( aList[3] < bList[3] ) return 1;
		}
		else
		{
			if( a[ 0 ] < b[ 0 ] ) return -1;
			if( a[ 0 ] > b[ 0 ] ) return 1;
		}

		//page
		if( Number( a[ 1 ] ) < Number( b[ 1 ] ) ) return -1;
		if( Number( a[ 1 ] ) > Number( b[ 1 ] ) ) return 1;


		return 0;
	} );

	log( "Total strings : " + count );
	log( "\t CSV - " + list.length );

	startUpload(list);
}

function startUpload($fromData)
{	
	log("Upload Start : " + spreadsheet_id);
	log("localeList : "  + localeList.toString());
	new Upload( sheetName, spreadsheet_id, $fromData, localeList );
}

var data = {};
var list = [];
var count = 0;

function addData( $data )
{
	const date_str = util.string.timeToFormat( Date.now() );
	var i = 0;
	for( i; i < $data.length; ++i )
	{
		//fileName, page, char, str
		var tempData = $data[i];
		var newData = [ tempData[0], tempData[1], tempData[2] ];
		var localeIdx = 0;
		for(; localeIdx < localeList.length; ++localeIdx)
		{
			newData.push("");			
		}
		newData.push( tempData[3] );
		localeIdx = 0;
		for(; localeIdx < localeList.length; ++localeIdx)
		{
			newData.push("");			
		}

		newData.push( date_str );
		list.push( newData );

		++count;
	}
}
