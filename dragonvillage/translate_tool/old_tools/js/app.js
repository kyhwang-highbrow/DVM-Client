const fs = require( "fs" );
const Express = require( "express" );
const app = Express();
const spreadsheet = require( "./spreadsheet" );
const Lua = require( "./lua" );

app.get( "/", function( $req, $res )
{
	var param = {};
	param.result = "OK";
	param.time = Date.now();

	$res.send( param );

	console.log( "requested" );
} )

app.get( "/enMap.lua", function( $req, $res )
{
	Lua( "en", "1BDdohPRoMAY_BPjYNpMgrrCwtLYOZS5F22E7MY5Cbe4", function( $text )
	{
		$res.send( $text );
	} )
} )

app.get( "/zhMap.lua", function( $req, $res )
{
	Lua( "zh", "1FHycBH3Qm7nIfQr3NJ6zsx8LloiRXvtoaDZJF8zz3OY", function( $text )
	{
		$res.send( $text );
	} )
} )

app.get( "/jaMap.lua", function( $req, $res )
{
	Lua( "ja", "1UikWmuvr1JflcA-BN3rnyA2Gu_AtPW1cI0tBH5ap2Dc", function( $text )
	{
		$res.send( $text );
	} )
} )

app.get( "/thMap.lua", function( $req, $res )
{
	Lua( "th", "1K3JqzQ3YxuPZCyR9R6xBtMdGA9a01sXN21V_5kKqII8", function( $text )
	{
		$res.send( $text );
	} )
} )

app.get( "/error.html", function( $req, $res )
{
	const s = require( "google-spreadsheet" );
	var doc = new s( "1FHycBH3Qm7nIfQr3NJ6zsx8LloiRXvtoaDZJF8zz3OY" );
	doc.useServiceAccountAuth( require( "./cred.json" ), function( $err, $info )
	{
		if( $err )
			console.log( $err );

		doc.getInfo( onInfo );
	} )

	function onInfo( $err, $info )
	{
		$res.send( $err.toString() );
		console.log( $info );
	}

} )

app.listen( 1600, function()
{
	console.log( "Translate Server is on." )
} )

// spreadsheet.load( sheetName, workSheet, onLoad );

// function onLoad( $rows, $info )
// {
// 	console.log( JSON.stringify( $info ) );
// 	console.log( JSON.stringify( $rows ) );
// }
