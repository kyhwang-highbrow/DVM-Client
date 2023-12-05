/*
node --max-old-space-size=4096 tools/upload_bundle.js
*/

const fs = require( "fs" );
const path = require( "path" );
const util = require( "../js/util" );
const log = util.log;

const Spreadsheet = require( "../js/spreadsheet" );

const hod_root = process.env.HOD_ROOT;

if( !fs.existsSync( hod_root ) )
{
	console.log( "환경변수 HOD_ROOT 가 설정되어 있지 않거나 잘못되었습니다 : " + hod_root );

	return
}

const date_str = util.string.timeToFormat( Date.now() );

upload( "zh", "1FHycBH3Qm7nIfQr3NJ6zsx8LloiRXvtoaDZJF8zz3OY" );
upload( "th", "1K3JqzQ3YxuPZCyR9R6xBtMdGA9a01sXN21V_5kKqII8" );
upload( "en", "1BDdohPRoMAY_BPjYNpMgrrCwtLYOZS5F22E7MY5Cbe4" );
upload( "ja", "1UikWmuvr1JflcA-BN3rnyA2Gu_AtPW1cI0tBH5ap2Dc" );

function upload( $locale, $spreadsheet_id )
{
	var locale = $locale;
	var spreadsheet_id = $spreadsheet_id;

	var text = fs.readFileSync( hod_root + "/translate/" + $locale + "Map.lua" ).toString( "utf8" );

	var reg = /\['(.*)'\]='(.*)',\n/g

	var list = [];
	var arr;
	while( arr = reg.exec( text ) )
	{
		list.push( [ trim( arr[ 1 ] ), trim( arr[ 2 ] ), "", date_str ] );
	}

	function trim( $str )
	{
		var value = "'" + $str.replace( /\\'/g, "'" ).replace( /\\"/g, "\"" );

		return value;
	}

	var spreadsheet = new Spreadsheet( spreadsheet_id );
	spreadsheet.init( onInit );

	var header = [ "kr", locale, "hints", "date" ];
	var row_count;
	var col_count = header.length;

	var sheet;

	function onInit( $info )
	{
		loadLocale();
	}

	function loadLocale()
	{
		sheet = spreadsheet.getWorksheet( "total" );

		if( sheet == null )
		{
			createSheet();
		}
		else
		{
			resizeSheet();
		}
	}

	function createSheet()
	{
		var option = {};
		option.title = "total";
		option.rowCount = 1;
		option.colCount = col_count;
		option.headers = header;

		spreadsheet.addWorksheet( option, function( $sheet )
		{
			resizeSheet();
		} );
	}

	function resizeSheet()
	{
		var option = {};
		option.rowCount = list.length + 1;

		sheet.resize( option, function( $err )
		{
			if( $err )
				throw $err;

			uploadData();
		} )
	}

	function uploadData()
	{
		var param = {};
		param[ "min-row" ] = 2;
		param[ "max-row" ] = 1 + list.length;
		param[ "min-col" ] = 1;
		param[ "max-col" ] = col_count;
		param[ "return-empty" ] = true;

		sheet.getCells( param, onCells );

		function onCells( $err, $cells )
		{
			if( $err )
				throw $err;

			var i = 0;
			var len = $cells.length;
			var row, col;
			for( i ; i < len ; i++ )
			{
				row = Math.floor( i / col_count );
				col = i % col_count;

				var value = list[ row ][ col ];

				if( value.indexOf( "''" ) == 0 )
					value = value.substr( 1 );

				$cells[ i ].value = "'" + value;
			}

			sheet.bulkUpdateCells( $cells, onUpdate );
		}
	}

	function onUpdate( $err )
	{
		if( $err )
			throw $err;

		log( "complete : " + locale );
	}
}