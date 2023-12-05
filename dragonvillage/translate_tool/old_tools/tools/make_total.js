const TotalBackup = require( "./total_backup" );

var sheetName = process.argv[ 2 ];
var spreadsheet_id = process.argv[ 3 ];
var localeList = process.argv[ 4 ];
var isScenario = process.argv[ 5 ] == 1;

var isDebug = false;
if( isDebug )
{
    //tools/make_total.js test_onlyingame 1s3m5A7rl4JHngXFknMd3MTkbf0vVaAIPoRx3GPHJvoo en;jp;zhtw 0
    //tools/make_total.js test_onlyscenario 1s3m5A7rl4JHngXFknMd3MTkbf0vVaAIPoRx3GPHJvoo en;jp;zhtw 1
    sheetName = "test_onlyingame";
    spreadsheet_id = "1s3m5A7rl4JHngXFknMd3MTkbf0vVaAIPoRx3GPHJvoo";
    localeList = "en;jp;zhtw;th";
    isScenario = false;
}

console.log( sheetName, spreadsheet_id, localeList, isScenario.toString() );

new TotalBackup( sheetName, spreadsheet_id, localeList.split(";"), isScenario );