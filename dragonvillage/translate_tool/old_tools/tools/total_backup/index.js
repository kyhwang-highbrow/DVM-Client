const Spreadsheet = require( "../../js/spreadsheet" );
const util = require( "../../js/util" );
const log = util.log;

module.exports = TotalBackup;

function TotalBackup( $sheetName, $spreadsheet_id, $localeList, $isScenario )
{
	this.sheetName = $sheetName;
	this.spreadsheet_id = $spreadsheet_id;
	this.localeList = $localeList;
	this.isScenario = $isScenario;

	this.loadSheet();
}

TotalBackup.prototype.loadSheet = function()
{
	var spreadsheet_id = this.spreadsheet_id;
	var sheetName = this.sheetName;
	var localeList = this.localeList;
	var isScenario = this.isScenario;

	var spreadsheet = new Spreadsheet( spreadsheet_id );
	spreadsheet.init( onInit );

	var sheetWork;
	var sheetTotal;
	var addData = [];
	var totalData = [];
	var header;
	//var header = [ "kr", locale, "hints", "date" ];
	if( isScenario )
	{
		header = [ "fileName", "page", "speaker_kr" ];
		var i = 0;
		for( ; i < localeList.length; ++i )
		{
			header.push( "speaker_" + localeList[i] );
		}	
		header.push( "kr" );
		i = 0;
		for( ; i < localeList.length; ++i )
		{
			header.push( localeList[i] );
		}	
		header.push( "date" );
	}
	else
	{
		header = ["kr"];
		for(var i = 0; i < localeList.length; ++i )
		{
			header.push( localeList[i] );
		}
		header.push("hints");
		header.push("date");
	}



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
			setSheetData($rows, addData);			
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
			setSheetData($rows, addData);
			loadTotal();
		} );
	}

	function setSheetData($sheet, $outData)
	{		
		var i = 0;
		var len = $sheet.length;;
		var row;						
		for( i ; i < len ; i++ )
		{
			row = $sheet[ i ];
			var tempRow = [];
			if (isScenario)
			{
				//fileName	page	speaker_kr	speaker_en	speaker_jp	speaker_zhtw	kr	en	jp	zhtw	date
				tempRow[0] = row.filename;
				tempRow[1] = row.page;
				tempRow[2] = row.speakerkr;
				var localeIdx = 0;
				for( ; localeIdx < localeList.length; ++localeIdx )
				{				
					tempRow.push( row[ "speaker" + localeList[localeIdx] ] );
				}	
				tempRow.push( row.kr );
				localeIdx = 0;
				for( ; localeIdx < localeList.length; ++localeIdx )
				{
					tempRow.push( row[ localeList[localeIdx] ] );
				}				
				tempRow.push( row.date );
			}
			else
			{
				tempRow.push( row.kr );
				for(var localeIdx = 0; localeIdx < localeList.length; ++localeIdx )
				{
					tempRow.push( row[ localeList[localeIdx] ] );
				}
				tempRow.push( row.hints );
				tempRow.push( row.date );
			}			
			
			$outData.push( tempRow );
		}
	}

	function createTotal()
	{
		var option = {};
		option.title = sheetName + "_backup";
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
		if( addData.length <= 0 )
		{
			onUpdate();
			return;
		}

		sheetTotal = spreadsheet.getWorksheet( sheetName + "_backup" );

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
			setSheetData($rows, totalData);
			checkDuplicateData();			
			resizeTotal();
		} );
	}

	//add에 total에 중복있는거 있는지 검사해서 삭제
	function checkDuplicateData()
	{
		var i = 0;
		var len = addData.length;				
		var row;
		var removeList = [];
		if( isScenario )
		{
			for( i ; i < len ; i++ )
			{				
				if( isDataFromTotalScenario(addData[i]) == true )
				{
					removeList.push(i);
				}
			}
			
			var removeLen = removeList.length;
			while( removeLen > 0 )
			{
				addData.splice( removeList[removeLen-1], 1 );
				--removeLen;
			}
		}
		else
		{
			for( i ; i < len ; i++ )
			{
				row = addData[i];
				var kr = row[0];
				if( getDataFromToal( kr ) )
				{
					removeList.push(i);
				}		
			}	

			var removeLen = removeList.length;
			while( removeLen > 0 )
			{
				addData.splice( removeList[removeLen-1], 1 );
				--removeLen;
			}
		}

	}

	//total아래에 add를 넣는다.
	function mergeData()
	{
		var i = 0;
		var len = addData.length;				
		var row;
		for( i ; i < len ; i++ )
		{
			row = addData[i];
			var kr = row[0];
			if( getDataFromToal( kr ) == null )
			{
				totalData.push( row );
			}		
		}		
	}
	
	function getDataFromToal( $kr )
	{
		var i = totalData.length;
		while( i-- )
		{
			if( totalData[ i ][ 0 ] == $kr )
				return totalData[ i ]
		}

		return null;
	}

	function isDataFromTotalScenario($data)
	{		
		var i = totalData.length;			
		var isExistName = false;
		var isExistString = false;
		var speaker = $data[2];
		var msg = $data[6];				
		if(speaker == "" )
		{
			isExistName = true;
		}
		else
		{
			while( i-- )
			{
				var total_speaker = totalData[i][2];				
				//이름 찾기
				if( total_speaker == speaker )
				{
					isExistName = true;
					//찾은거 혹시모르니 넣어준다.
					var localeIdx = 0;
					for( ; localeIdx < localeList.length; ++localeIdx )
					{
						var locale_speaker = "speaker" + localeList[localeIdx];
						var locale_speaker_idx = 2 + localeIdx + 1;
						$data[locale_speaker_idx] = totalData[i][locale_speaker];
					}	
					break;
				}				
			}
		}

		i = totalData.length;
		while( i-- )
		{
			//텍스트 찾기
			var total_msg = totalData[i][6];				
			if( total_msg == msg )
			{
				isExistString = true;				
				//찾은거 혹시모르니 넣어준다.
				var localeIdx = 0;
				for( ; localeIdx < localeList.length; ++localeIdx )
				{
					var locale_msg = localeList[localeIdx];
					var locale_msg_idx = 6 + localeIdx + 1;
					$data[locale_msg_idx] = totalData[i][locale_msg];
				}	
				break;
			}	
		}

		return isExistName && isExistString;		
	}

	function resizeTotal()
	{
		var option = {};
		option.rowCount = totalData.length + addData.length + 1;

		sheetTotal.resize( option, function( $err )
		{
			if( $err )
				throw $err;

			uploadData();
		} );
	}

	function uploadData()
	{
		var last = totalData.length;
		var total_len = totalData.length + addData.length;
		var n = 0;

		function uploadNext()
		{
			var from = last + 1;
			var to = Math.min( last + 500, total_len );

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

					var value = addData[ row ][ col ];

					if( value.indexOf( "''" ) == 0 )
						value = value.substr( 1 );

					$cells[ i ].value = "'" + value;
				}

				sheetTotal.bulkUpdateCells( $cells, function( $err )
				{
					if( $err )
						throw $err;

					if( last >= total_len )
					{
						console.log( parseInt( 100 * to / total_len ) + "%" );
						
						onUpdate();
					}
					else
					{
						console.log( parseInt( 100 * to / total_len ) + "%" );

						uploadNext()
					}
				})
			} );
		}

		uploadNext();
	}

	function onUpdate()
	{
		mergeData();
		backup(totalData);

		log( "complete total : " + localeList.toString() );
	}

	function backup( $data )
	{
		var date = new Date();
		var file_name = date.getFullYear() + "." + two( date.getMonth() + 1 ) + "." + two( date.getDate() ) + "_" + two( date.getHours() ) + "." + two( date.getMinutes() ) + "_" + sheetName +".json";

		function two( $value )
		{
			var str = util.string.setDigit( $value, 2 );

			return str;
		}

		util.file.mkdir( "./backup/" );
		util.file.writeFile( "./backup/" + file_name, JSON.stringify( $data, null, "\t" ) );
	}
}