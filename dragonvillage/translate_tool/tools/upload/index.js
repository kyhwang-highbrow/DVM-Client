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
	//번역이 필요한 언어별로 header(컬럼)을 만든다.
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
		//_backup시트를 가져와서 겹치는거 제거
		var totalSheet = spreadsheet.getWorksheet( sheetName + "_backup" );

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

		var last = 0;
		var n = 0;
		function uploadNext()
		{
			var from = last + 1;
			var to = Math.min( last + 1000, totalData.length );
		
			last = to;
			var param = {};
			param[ "min-row" ] = 1 + from;
			param[ "max-row" ] = 1 + to;
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
				for( i ; i < len ; i++, n++ )
				{
					row = Math.floor( n / col_count );
					col = n % col_count;
	
					var value = totalData[ row ][ col ];		
					if( value == null )
						console.log("===value is null : " + "row : " + row + ", col : " + col);		
					if( value.indexOf( "''" ) == 0 )
						value = value.substr( 1 );
	
					$cells[ i ].value = "'" + value;
				}

				sheet.bulkUpdateCells( $cells, function( $err )
				{
					if( $err )
						throw $err;
		
					if( last >= totalData.length )
					{
						console.log( parseInt( 100 * to / totalData.length ) + "%" );
						
						onUpdate();
					}
					else
					{
						console.log( parseInt( 100 * to / totalData.length ) + "%" );
		
						uploadNext()
					}
				})					
			}
		}
			
		uploadNext();
	}

	function onUpdate()
	{
		log( "complete : " + sheetName + " (" + totalData.length + ")" );
	}

}