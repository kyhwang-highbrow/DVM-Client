const Spreadsheet = require( "../../js/spreadsheet" );
const util = require( "../../js/util" );
const log = util.log;

module.exports = Total;

function Total( $sheetName, $spreadsheet_id, $localeList, $isScenario )
{
	this.sheetName = $sheetName;
	this.spreadsheet_id = $spreadsheet_id;
	this.localeList = $localeList;
	this.isScenario = $isScenario;

	this.loadSheet();
}

Total.prototype.loadSheet = function()
{
	var spreadsheet_id = this.spreadsheet_id;
	var sheetName = this.sheetName;
	var localeList = this.localeList;
	var isScenario = this.isScenario;

	var spreadsheet = new Spreadsheet( spreadsheet_id );
	spreadsheet.init( onInit );

	var sheetWork;
	var sheetTotal;
	var totalData = [];

	//var header = [ "kr", locale, "hints", "date" ];
	var header = ["kr"];
	for(var i = 0; i < localeList.length; ++i )
	{
		header.push( localeList[i] );
	}
	header.push("hints");
	header.push("date");
	var row_count;
	var col_count = header.length;

	function onInit( $info )
	{
		if( isScenario )
			loadScenario();
		else
			loadLocale();
	}

	function loadScenario()
	{
		sheetWork = spreadsheet.getWorksheet( sheetName );

		if( sheetWork == null )
		{
			log( sheetName + " worksheet can't find." );

			return;
		}

		var param = {};
		param.offset = 1;
		param.limit = sheetWork.rowCount;

		sheetWork.getRows( param, function( $err, $rows )
		{
			row_count = $rows.length;
			//여기에는 중첩된 텍스트도 있으니 골라서 뽑아야한다.
			//이름
			var i = 0;
			var len = row_count;
			var row;			
			for( i ; i < len ; i++ )
			{
				row = $rows[ i ];
				if( row.speakerkr.length <= 0 )
					continue;

				var tempRow = getData(row.speakerkr);
				if( tempRow )
				{
					var oldHints = tempRow[1 + localeList.length];
					if( oldHints.indexOf( row.filename ) < 0 )
						tempRow[1 + localeList.length] = oldHints + "," + row.filename;
				}
				else
				{
					tempRow = [];
					tempRow.push( row.speakerkr );
					for(var localeIdx = 0; localeIdx < localeList.length; ++localeIdx )
					{
						tempRow.push( row[ "speaker" + localeList[localeIdx] ] );
					}
					tempRow.push( row.filename );
					tempRow.push( row.date );
					totalData.push( tempRow );
				}
			}
			//대사
			i = 0;
			for( i ; i < len ; i++ )
			{
				row = $rows[ i ];
				var tempRow = getData(row.kr);
				if( tempRow )
				{
					var oldHints = tempRow[1 + localeList.length];
					if( oldHints.indexOf( row.filename ) < 0 )
						tempRow[1 + localeList.length] = oldHints + "," + row.filename;
				}
				else
				{
					tempRow = [];
					tempRow.push( row.kr );
					for(var localeIdx = 0; localeIdx < localeList.length; ++localeIdx )
					{
						tempRow.push( row[ localeList[localeIdx] ] );
					}
					tempRow.push( row.filename );
					tempRow.push( row.date );
					totalData.push( tempRow );
				}
			}

			loadTotal();
		} );
	}

	function loadLocale()
	{
		sheetWork = spreadsheet.getWorksheet( sheetName );

		if( sheetWork == null )
		{
			log( sheetName + " worksheet can't find." );

			return;
		}

		var param = {};
		param.offset = 1;
		param.limit = sheetWork.rowCount;

		sheetWork.getRows( param, function( $err, $rows )
		{
			row_count = $rows.length;

			var i = 0;
			var len = row_count;
			var row;						
			for( i ; i < len ; i++ )
			{
				row = $rows[ i ];
				var tempRow = [];
				tempRow.push( row.kr );
				for(var localeIdx = 0; localeIdx < localeList.length; ++localeIdx )
				{
					tempRow.push( row[ localeList[localeIdx] ] );
				}
				tempRow.push( row.hints );
				tempRow.push( row.date );
				totalData.push( tempRow );
			}

			loadTotal();
		} );
	}

	function createTotal()
	{
		var option = {};
		option.title = "total_dev";
		option.rowCount = 1;
		option.colCount = col_count;
		option.headers = header;

		spreadsheet.addWorksheet( option, function( $sheet )
		{
			loadTotal();
		} );
	}

	function loadTotal()
	{
		if( totalData.length <= 0 )
		{
			onUpdate();
			return;
		}

		sheetTotal = spreadsheet.getWorksheet( "total_dev" );

		if( sheetTotal == null )
		{
			createTotal();

			return;
		}

		var param = {};
		param.offset = 1;
		param.limit = sheetTotal.rowCount;

		sheetTotal.getRows( param, function( $err, $rows )
		{
			mergeData( $rows );
		} );
	}

	function mergeData( $rows )
	{
		var i = 0;
		var len = $rows.length;
		var row;
		var data;
		for( i ; i < len ; i++ )
		{
			row = $rows[ i ];
			data = getData( row.kr );			
			if( data == null )
			{	
				data = [];			
				data.push( row.kr );
				for(var localeIdx = 0; localeIdx < localeList.length; ++localeIdx )
				{
					data.push( row[ localeList[localeIdx] ] );
				}
				data.push( row.hints );
				data.push( row.date );				

				totalData.push( data );
			}
			else
			{
				//ingame에는 번역x scenario에서 번역되서 total들어같을경우 같은 경우
				for(var localeIdx = 0; localeIdx < localeList.length; ++localeIdx )
				{
					var locale = localeList[localeIdx];
					if( data[ 1 + localeIdx].length <= 0 && row[ locale ].length > 0 )
						data[ 1 + localeIdx] = row[ locale ];
				}

				var oldHints = data[ 1 + localeList.length ];
				if( oldHints == row.hints )
					data[ 1 + localeList.length ] = row.hints;
				else
					data[ 1 + localeList.length ] = oldHints + row.hints;

				data[ 1 + localeList.length + 1 ] = row.date;
			}
		}

		totalData.sort( function( a, b )
		{
			if( a[ 0 ] < b[ 0 ] ) return -1;
			if( a[ 0 ] > b[ 0 ] ) return 1;
			return 0;
		} );

		backup( totalData );

		resizeTotal();
	}
	
	function getData( $kr )
	{
		var i = totalData.length;
		while( i-- )
		{
			if( totalData[ i ][ 0 ] == $kr )
				return totalData[ i ]
		}

		return null;
	}

	function resizeTotal()
	{
		var option = {};
		option.rowCount = totalData.length + 1;

		sheetTotal.resize( option, function( $err )
		{
			if( $err )
				throw $err;

			uploadData();
		} );
	}

	function uploadData()
	{
		var last = 0;
		var n = 0;

		function uploadNext()
		{
			var from = last + 1;
			var to = Math.min( last + 500, totalData.length );

			last = to;

			var param = {};
			param[ "min-row" ] = 1 + from;
			param[ "max-row" ] = 1 + to;
			param[ "min-col" ] = 1;
			param[ "max-col" ] = col_count;
			param[ "return-empty" ] = true;

			sheetTotal.getCells( param, function( $err, $cells )
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

					if( value.indexOf( "''" ) == 0 )
						value = value.substr( 1 );

					$cells[ i ].value = "'" + value;
				}

				sheetTotal.bulkUpdateCells( $cells, function( $err )
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
			} );
		}

		uploadNext();

		/*
		var param = {};
		param[ "min-row" ] = 2;
		param[ "max-row" ] = 1 + totalData.length;
		param[ "min-col" ] = 1;
		param[ "max-col" ] = col_count;
		param[ "return-empty" ] = true;

		sheetTotal.getCells( param, onCells );

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

				var value = totalData[ row ][ col ];

				if( value.indexOf( "''" ) == 0 )
					value = value.substr( 1 );

				$cells[ i ].value = "'" + value;
			}

			sheetTotal.bulkUpdateCells( $cells, onUpdate );
		}
		*/
	}

	function onUpdate()
	{
		/*
		sheetWork.clear( function( $err )
		{
			var option = {};
			option.rowCount = 1;
			option.colCount = col_count;

			var newheader = header;
			if( isScenario )
			{
				newheader = [ "fileName", "page", "speaker_kr" ];
				var i = 0;
				for( ; i < localeList.length; ++i )
				{
					newheader.push( "speaker_" + localeList[i] );
				}	
				newheader.push( "kr" );
				i = 0;
				for( ; i < localeList.length; ++i )
				{
					newheader.push( localeList[i] );
				}	
				newheader.push( "date" );
			}

			sheetWork.resize( option, function( $err )
			{
				sheetWork.setHeaderRow( newheader, function()
				{
					log( "complete total : " + localeList.toString() );
				} );
			} )
		} );
		*/
		log( "complete total : " + localeList.toString() );
	}

	function backup( $data )
	{
		var date = new Date();
		var file_name = date.getFullYear() + "." + two( date.getMonth() + 1 ) + "." + two( date.getDate() ) + "_" + two( date.getHours() ) + "." + two( date.getMinutes() ) + "_" + "ingame.json";

		function two( $value )
		{
			var str = util.string.setDigit( $value, 2 );

			return str;
		}

		util.file.mkdir( "./backup/" );
		util.file.writeFile( "./backup/" + file_name, JSON.stringify( $data, null, "\t" ) );
	}
}