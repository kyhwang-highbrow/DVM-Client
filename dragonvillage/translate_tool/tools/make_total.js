const Total = require( "./total" );
const sheetName = process.argv[ 2 ];
const spreadsheet_id = process.argv[ 3 ];
const localeList = process.argv[ 4 ].split(";");

console.log( sheetName, spreadsheet_id, localeList.toString() );

new Total( sheetName, spreadsheet_id, localeList );