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
		
	var header = [ "fileName", "page", "speaker_kr" ];
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

	var row_count;
	var col_count = header.length;

	var spreadsheet = new Spreadsheet( spreadsheet_id );
	spreadsheet.init( onInit );

	var sheet;
	var uploadCount = 0;
	function onInit( $info )
	{
		var totalSheet = spreadsheet.getWorksheet( sheetName + "_backup" );

		var param = {};
		param.offset = 1;
		param.limit = totalSheet.rowCount;

		totalSheet.getRows( param, function( $err, $rows )
		{
			var i = 0;
			var len = data.length;			
			var removeList = [];
			for( i ; i < len ; i++ )
			{				
				if( removeStr(data[i], $rows) == true )
				{
					removeList.push(i);
				}
			}
			
			var removeLen = removeList.length;
			while( removeLen > 0 )
			{
				data.splice( removeList[removeLen-1], 1 );
				--removeLen;
			}
			loadSheet();
		} );

		var krSpeakerIdx = 2;
		var krMsgIdx = 3 + localeList.length;
		function removeStr( $data, $rows )
		{
			var i = $rows.length;			
			var isExistName = false;
			var isExistString = false;
			var speaker = $data[krSpeakerIdx];
			var msg = $data[krMsgIdx];				
			if(speaker == "" )
			{
				isExistName = true;
			}
			else
			{
				while( i-- )
				{
					//이름 찾기
					if( $rows[i].speakerkr == speaker )
					{
						isExistName = true;
						//찾은거 혹시모르니 넣어준다.
						var localeIdx = 0;
						for( ; localeIdx < localeList.length; ++localeIdx )
						{
							var locale_speaker = "speaker" + localeList[localeIdx];
							var locale_speaker_idx = 2 + localeIdx + 1;
							$data[locale_speaker_idx] = $rows[i][locale_speaker];
						}	
						break;
					}				
				}
			}

			i = $rows.length;
			while( i-- )
			{
				//텍스트 찾기
				if( $rows[i].kr == msg )
				{
					isExistString = true;
					//찾은거 혹시모르니 넣어준다.
					var localeIdx = 0;
					for( ; localeIdx < localeList.length; ++localeIdx )
					{
						var locale_msg = localeList[localeIdx];
						var locale_msg_idx = 6 + localeIdx + 1;
						$data[locale_msg_idx] = $rows[i][locale_msg];
					}	
					break;
				}	
			}

			return isExistName && isExistString;
		}
		/*
		function removeStr( $row )
		{
			var i = data.length;
			var kr = $row.kr;			
			var isExistName = false;
			var isExistString = false;
			while( i-- )
			{
				//이름 찾기
				if( data[i][2] == kr )
				{
					isExistName = true;
					break;
				}				
			}

			i = data.length;
			while( i-- )
			{
				//텍스트 찾기
				if( data[i][6] == kr )
				{
					isExistString = true;
					break;
				}	
			}

			//if( data[i][2] == kr && data[i][6] == kr )
			if( isExistName && isExistString )
			{
				data.splice( i, 1 );				
			}
		}
		*/

		function setFromTotal( $row )
		{
			var i = data.length;
			var kr = $row.kr;
			while( i-- )
			{
				//이름 찾기
				if( data[i][2] == kr )
				{
					var localeIdx = 0;
					for( ; localeIdx < localeList.length; ++localeIdx )
					{
						data[i][2 + localeIdx + 1] = $row[ localeList[localeIdx] ];
					}
				}
				
				//대사 찾기
				if( data[i][6] == kr )
				{
					var localeIdx = 0;
					for( ; localeIdx < localeList.length; ++localeIdx )
					{
						data[i][6 + localeIdx + 1] = $row[ localeList[localeIdx] ];
					}
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
		//fileName	page	speaker_kr	speaker_en	speaker_jp	speaker_zhtw	kr	en	jp	zhtw	date
		for( i ; i < len ; i++ )
		{
			row = $rows[ i ];
			var oldData = [];
			oldData[0] = row.filename;
			oldData[1] = row.page;
			oldData[2] = row.speakerkr;
			var localeIdx = 0;
			for( ; localeIdx < localeList.length; ++localeIdx )
			{				
				oldData.push( row[ "speaker" + localeList[localeIdx] ] );
			}	
			oldData.push( row.kr );
			localeIdx = 0;
			for( ; localeIdx < localeList.length; ++localeIdx )
			{
				oldData.push( row[ localeList[localeIdx] ] );
			}				
			oldData.push( row.date );

			totalData.push( oldData )
			//setData( row, localeList);
		}

		mergeData();
		resizeWorksheet();

		function mergeData()
		{
			var i = 0;
			var krMsgIdx = 3 + localeList.length;	//filename, page, speaker_kr
			var krSpeakerIdx = 2;					//filename, page
			for( ; i < data.length; ++i )
			{
				var thisData = data[i];
				if( isExistTotalData( thisData[krMsgIdx], krMsgIdx ) == false || isExistTotalData( thisData[krSpeakerIdx], krSpeakerIdx) == false )
					totalData.push( thisData );
			}

			function isExistTotalData( $str, $checkIdx )
			{
				var total_i = totalData.length;
				while( total_i-- )
				{
					if( totalData[total_i][$checkIdx] == $str )
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
			var thisFileName = $row.filename;
			var thisPage = $row.page;
			var thisSpeaker = $row.speakerkr;
			var thisStr = $row.kr;			
			var thisDate = $row.date;
			var localeCount = $localeList.length;
			for( i ; i < len ; i++ )
			{
				list = data[ i ];
				if( list[ 0 ] == thisFileName && list[ 1 ] == thisPage )
				{
					var localeIdx = 0;
					for(; localeIdx < localeCount; ++localeIdx)
					{
						var speaker = $row[ "speaker" + $localeList[localeIdx] ];
						var str = $row[ $localeList[localeIdx] ];
						if( speaker.length > 0 )
							list[ 3 + localeIdx ] = speaker;
						if( str.length > 0 )
							list[ 3 + localeIdx + localeCount + 1 ] = str;
					}

					list[ 3 + (localeCount * 2) + 1 ] = thisDate;
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

		updateSameStr( totalData, localeList );

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

					if( value.substr(0,1) == '=' )
						$cells[ i ].value = value;
					else
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

	function onUpdate( $err )
	{
		log( "complete : " + sheetName + " (" + totalData.length + ")" );
	}

	function updateSameStr( $data, $localeList )
	{
		var i = 0 ;		
		var checkedList = [];
		var nameIdx = 2;
		var strIdx = nameIdx + $localeList.length + 1;
		var dataList = $data;
		for( i; i < dataList.length; ++i )
		{			
			var tempData = dataList[i];
			//이름 체크
			var orgName = tempData[nameIdx];
			if( orgName.length > 0 && checkedList.indexOf( orgName ) < 0 )
			{
				setSameStr( orgName, i, nameIdx );
				checkedList.push( orgName );
			}
			
			//대사 체크
			var orgStr = tempData[strIdx];
			if( orgStr.length > 0 && checkedList.indexOf( orgStr ) < 0 )
			{
				setSameStr( orgStr, i, strIdx );
				checkedList.push( orgStr );
			}
		}

		function setSameStr( $str, $findIdx, $strIdx )
		{			
			var j = $findIdx + 1;
			var col = "a".charCodeAt(0);			
			for( j; j < dataList.length; ++j )
			{
				var findData = dataList[j];
				if( findData[$strIdx] == $str )
				{
					for( var k = 0; k < $localeList.length; ++k )
					{
						if( findData[$strIdx + 1 + k] == "" )
							findData[$strIdx + 1 + k] = "=" + String.fromCharCode(col + $strIdx + 1 + k) + String($findIdx + 2);
					}
				}
			}
		}
	}
}