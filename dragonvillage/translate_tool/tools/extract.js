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
const hod_root = process.env.HOD_ROOT;

if( !fs.existsSync( hod_root ) )
{
	console.log( "환경변수 HOD_ROOT 가 설정되어 있지 않거나 잘못되었습니다 : " + hod_root );

	return
}

log( "Project root : " + hod_root );

var fromLua = new ExtractFromLua( hod_root + "/../src", ignoreFiles ).collect();	// 2. Lua 파일에서 긁어오기.
var fromUI = new ExtractFromUI( hod_root + "/../res", ignoreFiles ).collect();	// 3. UI 파일에서 긁어오기.

var fromSvData;
new ExtractFromData( hod_root + "/../../sv_tables", ignoreFiles ).collect( collectFromSvData );	// 4. sv_data 파일에서 긁어오기.

function collectFromSvData( $data )
{
	fromSvData = $data;
	new ExtractFromData( hod_root + "/../data", ignoreFiles ).collect( collectFromData );	// 5. CSV 파일에서 긁어오기.
}

function collectFromData( $data )
{
	var fromData = $data;

	addData( fromLua );
	addData( fromData );
	addData( fromSvData );
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
	log( "\t CSV - " + fromData.length );

	startUpload();
}

function startUpload()
{
	var idx = 0;
	var uploadList = [];
	uploadList[0] = {}
	uploadList[0].locale = "en";
	uploadList[0].id = "1TzxlNwZHMZxG4W0LsPokaQfnCsCoCM3qvozAt7tvICg";
	uploadList[1] = {}
	uploadList[1].locale = "jp";
	uploadList[1].id = "1hYRS7hE6OTRNQ-2RJL14O0VmxXxbYoT0wtQ7-rFnAi4";
	uploadList[2] = {}
	uploadList[2].locale = "zh_tw";
	uploadList[2].id = "1Cv2vBmWpnVwK74KN6SnL0QKdTpMoAx8VPYDzOi9yks0";
	function onFinish()
	{
		if( idx < uploadList.length )
		{
			var updata = uploadList[idx];
			new Upload( updata.locale, updata.id, list, onFinish);
			++idx;
		}
	}

	onFinish();

	//new Upload( "en", "1TzxlNwZHMZxG4W0LsPokaQfnCsCoCM3qvozAt7tvICg", list, onFinish );
	//new Upload( "jp", "1hYRS7hE6OTRNQ-2RJL14O0VmxXxbYoT0wtQ7-rFnAi4", list, onFinish );
	//new Upload( "zh_tw", "1Cv2vBmWpnVwK74KN6SnL0QKdTpMoAx8VPYDzOi9yks0", list, onFinish );
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