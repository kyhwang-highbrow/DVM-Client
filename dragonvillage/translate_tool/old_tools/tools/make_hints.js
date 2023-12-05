const fs = require( "fs" );
const path = require( "path" );
const util = require( "../js/util" );
const Spreadsheet = require( "../js/spreadsheet" );
const log = util.log;

const ExtractFromLua = require( "./extract/ExtractFromLua" );
const ExtractFromData = require( "./extract/ExtractFromData" );
const ExtractFromUI = require( "./extract/ExtractFromUI" );

const ignoreFiles = [
	"hod_table_ban_word_chat.csv",
	"hod_table_ban_word_naming.csv",
	"hod_table_banner.csv",
	"hod_table_package_cn2.csv",
	"hod_table_quest_cn2.csv",
	"server_select.ui",
	"event_cashback_cn2.ui",
	"event_cashback_cn2_list.ui",
	"event_200_cn2.ui",
	"event_2001_cn2.ui",
	"event_211_cn2.ui",
	"event_212_cn2.ui",
	"event_213_cn2.ui",
	"event_226_cn2.ui"
];

const HOD_ROOT = process.env.HOD_ROOT;

const SPREADSHEET_ID = [
						"1FHycBH3Qm7nIfQr3NJ6zsx8LloiRXvtoaDZJF8zz3OY"
						// ,"1K3JqzQ3YxuPZCyR9R6xBtMdGA9a01sXN21V_5kKqII8"
						// ,"1BDdohPRoMAY_BPjYNpMgrrCwtLYOZS5F22E7MY5Cbe4"
						// ,"1UikWmuvr1JflcA-BN3rnyA2Gu_AtPW1cI0tBH5ap2Dc"
						];

var fromLua = new ExtractFromLua( HOD_ROOT + "/src", ignoreFiles ).collect();
var fromUI = new ExtractFromUI( HOD_ROOT + "/res", ignoreFiles ).collect();
var fromData = new ExtractFromData( HOD_ROOT + "/data", ignoreFiles ).collect( collectFromData );

var localData = {};

function collectFromData( $data )
{
	fromData = $data;

	mergeData();
}

function mergeData()
{
	var count = 0;
	function merge( $data )
	{
		var key;
		for( key in $data )
		{
			if( localData[ key ] != null )
			{
				if( localData[ key ].hints != null )
					localData[ key ].hints = localData[ key ].hints.concat( $data[ key ].hints );
				else
					localData[ key ].hints = $data[ key ].hints;
			}
			else
			{
				localData[ key ] = $data[ key ];

				count++;
			}
		}
	}

	merge( fromLua );
	merge( fromUI );
	merge( fromData );

	loadNext();

	function loadNext()
	{
		var spreadsheet_id = SPREADSHEET_ID.pop();

		console.log( "load : " + spreadsheet_id );

		loadTotal( spreadsheet_id, loadComplete );
	}

	function loadComplete()
	{
		if( SPREADSHEET_ID.length == 0 )
		{
			console.log( "all complete" );

			return;
		}

		loadNext();
	}
}

function loadTotal( $spreadsheet_id, $onComplete )
{
	var spreadsheet = new Spreadsheet( $spreadsheet_id );
	spreadsheet.init( onInit );

	var sheet;

	function onInit( $info )
	{
		sheet = spreadsheet.getWorksheet( "total" );

		var param = {};
		param[ "min-row" ] = 2;
		param[ "max-row" ] = sheet.rowCount;
		param[ "min-col" ] = 1;
		param[ "max-col" ] = 4;
		param[ "return-empty" ] = true;

		sheet.getCells( param, onCells );
	}

	function getValue( $value )
	{
		if( $value.indexOf( "''" ) == 0 )
			$value = $value.substr( 1 );

		return "'" + $value;
	}

	function onCells( $err, $cells )
	{
		for( var i = 0 ; i < $cells.length ; )
		{
			var kr = i++;
			var en = i++;
			var hints = i++;
			var date = i++;

			var key = $cells[ kr ].value;

			if( localData[ key ] )
				$cells[ hints ].value = localData[ key ].hints.join( "," );

			$cells[ kr ].value = getValue( $cells[ kr ].value );
			$cells[ en ].value = getValue( $cells[ en ].value );
		}

		sheet.bulkUpdateCells( $cells, onUpdate );
	}

	function onUpdate( $err )
	{
		if( $err )
			throw $err;

		$onComplete();
	}
}