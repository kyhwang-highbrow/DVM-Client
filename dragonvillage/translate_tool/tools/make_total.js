const Total = require( "./total" );
const locale = process.argv[ 2 ];
const spreadsheet_id = process.argv[ 3 ];

console.log( locale, spreadsheet_id );

new Total( locale, spreadsheet_id );