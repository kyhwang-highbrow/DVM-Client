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

make();

function make()
{
	var sheetName = process.argv[ 2 ];
	var sheetID = process.argv[ 3 ];
	var localeList = process.argv[ 4 ].split(";");
	var localeIdx = 0;

	function makeLua()
	{		
		if( localeIdx < localeList.length )
		{
			new Lua( sheetName, localeList[ localeIdx ], sheetID, function( $text )
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