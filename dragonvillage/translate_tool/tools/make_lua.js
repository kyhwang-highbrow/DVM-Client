const fs = require( "fs" );
const path = require( "path" );
const spreadsheet = require( "../js/spreadsheet" );
const util = require( "../js/util" );
const log = util.log;

const Lua = require( "../js/lua" );

const hod_root = process.env.HOD_ROOT;

log( "Project root : " + hod_root );

if( !fs.existsSync( hod_root ) )
{
	console.log( "환경변수 HOD_ROOT 가 설정되어 있지 않거나 잘못되었습니다 : " + hod_root );

	return
}

const tmpDir = "./backup/";

Lua( "en", "1TzxlNwZHMZxG4W0LsPokaQfnCsCoCM3qvozAt7tvICg", function( $text )
{
	saveFile( "lang_en.lua", $text );
} )
/*
Lua( "jp", "1hYRS7hE6OTRNQ-2RJL14O0VmxXxbYoT0wtQ7-rFnAi4", function( $text )
{
	saveFile( "lang_jp.lua", $text );
} )

Lua( "zh_tw", "1Cv2vBmWpnVwK74KN6SnL0QKdTpMoAx8VPYDzOi9yks0", function( $text )
{
	saveFile( "lang_zh_tw.lua", $text );
} )
*/
function saveFile( $file, $data )
{
	util.file.mkdir( tmpDir );
	util.file.writeFile( tmpDir + $file, $data );
	util.file.writeFile( hod_root + "/../translate/" + $file, $data );
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