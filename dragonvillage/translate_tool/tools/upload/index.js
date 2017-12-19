const Spreadsheet = require( "../../js/spreadsheet" );
const util = require( "../../js/util" );
const log = util.log;

module.exports = Upload;

function Upload( $sheetName, $spreadsheet_id, $data, $localeList )
{
	this.sheetName = $sheetName;
	this.spreadsheet_id = $spreadsheet_id;
	this.data = util.deepCopy( $data );
	this.localeList = $localeList;

	this.loadSheet();
}

Upload.prototype.loadSheet = function()
{
	var spreadsheet_id = this.spreadsheet_id;
	var sheetName = this.sheetName;
	var data = this.data;
	var localeList = this.localeList;	
	var totalData = [];

	//var header = [ "kr", locale, "hints", "date" ];
	var header = [ "kr" ];
	var i = 0;
	for( ; i < localeList.length; ++i )
	{
		header.push( localeList[i] );
	}
	header.push( "hints" );
	header.push( "date" );

	var row_count;
	var col_count = header.length;

	var spreadsheet = new Spreadsheet( spreadsheet_id );
	spreadsheet.init( onInit );

	var sheet;
	var uploadCount = 0;
	function onInit( $info )
	{
		var totalSheet = spreadsheet.getWorksheet( "total_dev" );

		var param = {};
		param.offset = 1;
		param.limit = totalSheet.rowCount;

		totalSheet.getRows( param, function( $err, $rows )
		{
			var i = 0;
			var len = $rows.length;
			var row;
			for( i ; i < len ; i++ )
			{
				row = $rows[ i ];

				removeStr( row.kr );
			}

			loadSheet();
		} );

		function removeStr( $str )
		{
			var i = data.length;
			while( i-- )
			{
				if( data[ i ][ 0 ] == $str )
				{
					data.splice( i, 1 );

					return;
				}
			}
		}
	}

	function loadSheet()
	{
		sheet = spreadsheet.getWorksheet( sheetName );

		if( sheet == null )
			createsheet();
		else
			getRows();
	}

	function createsheet()
	{
		var option = {}
		option.title = sheetName;
		option.rowCount = 1;
		option.colCount = col_count;
		option.headers = header;

		spreadsheet.addWorksheet( option, function( $sheet )
		{
			sheet = $sheet;

			getRows();
		} );
	}

	function getRows()
	{
		var param = {};
		param.offset = 1;
		param.limit = sheet.rowCount;

		sheet.getRows( param, function( $err, $rows )
		{
			if( $err )
				throw $err;

			onGetRow( $rows );
		} );
	}

	function onGetRow( $rows )
	{
		row_count = $rows.length;

		var i = 0;
		var len = row_count;
		var row;		
		for( i ; i < len ; i++ )
		{
			row = $rows[ i ];
			var oldData = [];
			oldData[0] = row.kr;
			var localeIdx = 0;
			for(; localeIdx < localeList.length; ++localeIdx)
			{
				oldData.push( row[ localeList[localeIdx] ] );
			}
			oldData.push( row.hints );
			oldData.push( row.date );

			totalData.push( oldData );

			//setData( row, localeList);
		}

		mergeData();

		resizeWorksheet();
		
		function mergeData()
		{
			var i = 0;
			for( ; i < data.length; ++i )
			{
				var thisData = data[i];
				if( isExistTotalData( thisData[0] ) == false )
					totalData.push( thisData );
			}

			function isExistTotalData( $str )
			{
				var total_i = totalData.length;
				while( total_i-- )
				{
					if( totalData[total_i][0] == $str )
						return true;
				}
				return false;
			}
		}

		function setData( $row, $localeList )
		{
			var i = 0;
			var len = data.length;
			var list;
			var thisStr = $row.kr;
			var thisHints = $row.hints;
			var thisDate = $row.date;
			var localeCount = $localeList.length;
			for( i ; i < len ; i++ )
			{

				list = data[ i ];

				if( list[ 0 ] == thisStr )
				{	
					var localeIdx = 0;
					for(; localeIdx < localeCount; ++localeIdx)
					{
						list[ 1 + localeIdx ] = $row[ $localeList[localeIdx] ];
					}
					list[ 1 + localeCount ] = thisHints;
					list[ 1 + localeCount + 1 ] = thisDate;

					return;
				}
			}
		}
	}

	function resizeWorksheet()
	{
		var option = {};
		option.colCount = col_count;
		option.rowCount = Math.max( 2, totalData.length + 1 );

		sheet.clear( function( $err ) 
		{
			if( $err )
				console.log( $err );

			sheet.resize( option, function( $err )
			{
				if( $err )
					console.log( $err );

				sheet.setHeaderRow( header, function( $err )
				{
					if( $err )
						console.log( $err );

					uploadData();
				} );
			} )
		} )
	}

	var requestCount = 0;
	var isFinishOnCell = false;
	function uploadData()
	{
		if( totalData.length == 0 )
		{
			onUpdate();

			return;
		}

		var param = {};
		param[ "min-row" ] = 2;
		param[ "max-row" ] = 1 + totalData.length;
		param[ "min-col" ] = 1;
		param[ "max-col" ] = col_count;
		param[ "return-empty" ] = true;

		sheet.getCells( param, onCells );

		function onCells( $err, $cells )
		{
			var i = 0;
			var len = $cells.length;
			var row, col;
			var tempData = [];
			var tempIdx = 0;
			var tempMaxCount = 1000;			
			for( i ; i < len ; i++ )
			{
				row = Math.floor( i / col_count );
				col = i % col_count;

				var value = totalData[ row ][ col ];		
				if( value == null )
					console.log("===value is null : " + "row : " + row + ", col : " + col);		
				if( value.indexOf( "''" ) == 0 )
					value = value.substr( 1 );

				$cells[ i ].value = "'" + value;

				tempData[ tempIdx ] = $cells[ i ];
				++tempIdx;
				
				if( tempIdx >= tempMaxCount )
				{
					++requestCount;
					sheet.bulkUpdateCells( tempData, onUpdate );		
					tempData = [];
					tempIdx = 0;					
				}
			}
			isFinishOnCell = true;

			if( tempIdx <= 0 )
			{
				onUpdate();
			}
			else
			{
				++requestCount;
				sheet.bulkUpdateCells( tempData, onUpdate );
			}
		}
	}

	function onUpdate( $err )
	{
		if( $err )
			throw $err;

		--requestCount;
		if( isFinishOnCell == true && requestCount <= 0 )
		{
			log( "complete : " + sheetName + " (" + totalData.length + ")" );						
		}
		else		
			log( "onUpdate..." );
	}

}