const Spreadsheet = require( "./spreadsheet" );
const util = require( "./util" );
const log = util.log;

module.exports = Lua;

function Lua( $sheetNames, $locale, $spreadsheet_id, $callback )
{
	const sheetNameList = $sheetNames.split(";");
	sheetNameList.push("total_dev");
	
	const locale = $locale;
	const spreadsheet_id = $spreadsheet_id;

	log( "convert start : " + locale );

	var spreadsheet = new Spreadsheet( spreadsheet_id );
	spreadsheet.init( onInit );

	var list = [];

	function onInit( $info )
	{
		var idx = 0;
		function onFinish( $data )
		{
			mergeData( $data );
			++idx;
			if( idx < sheetNameList.length )
			{
				loadSheet( sheetNameList[idx], locale, onFinish )
			}
			else
			{
				convert();
			}
		}

		loadSheet( sheetNameList[idx], locale, onFinish );
	}

	function loadSheet( $name, $locale, $callback )
	{
		var sheet = spreadsheet.getWorksheet( $name );
		var locale = $locale;
		var data = [];

		if( sheet == null )
		{
			$callback( data );

			return;
		}

		var param = {};
		param.offset = 1;
		param.limit = sheet.rowCount;

		sheet.getRows( param, function( $err, $rows )
		{
			if( $err )
				throw $err;

			var i = 0;
			var len = $rows.length;
			var row;
			for( i ; i < len ; i++ )
			{
				row = $rows[ i ];

				data.push( [ row.kr, row[ locale ] ] );

				if( row.speakerkr )
					data.push( [ row.speakerkr, row[ "speaker" + locale ] ] );
			}

			$callback( data );
		} )
	}

	function mergeData( $data )
	{
		var n = 0;
		var nLen = $data.length;
		for( n ; n < nLen ; n++ )
		{
			if( hasData( $data[ n ][ 0 ] ) )
				continue;

			list.push( $data[ n ] );
		}

		function hasData( $str )
		{
			var i = list.length;
			while( i-- )
			{
				if( list[ i ][ 0 ] == $str )
					return true;
			}

			return false;
		}
	}

	function convert()
	{
		var text = "return {$}";
		var arr = [];
		var i = 0;
		var len = list.length;
		var row;
		for( i ; i < len ; i++ )
		{
			row = list[ i ];
			arr.push( "['" + quote( row[ 0 ] ) + "']='" + quote( row[ 1 ] ) + "'" );
		}

		text = text.replace( "$", arr.join( ",\n" ) );

		log( "complete " + locale );

		$callback( text );

		function quote( $str )
		{
			var value;
			try
			{
				value = $str.replace( /\'/g, "\\'" ).replace( /\"/g, "\\\"" ).replace( /\\\\n/g, "\\n" );				
			}
			catch( $e )
			{
				console.log( locale + " line : " + i + " = " + row );
				
				throw $e;
			}

			return value
		}
	}
}

