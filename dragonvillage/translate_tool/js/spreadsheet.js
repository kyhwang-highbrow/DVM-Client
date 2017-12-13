const fs = require( "fs" );
const GoogleSpreadsheet = require( "google-spreadsheet" );

module.exports = Spreadsheet;

const cred = require( "./cred.json" );

function Spreadsheet( $spreadsheet )
{
	this.doc = new GoogleSpreadsheet( $spreadsheet );
}

Spreadsheet.prototype.init = function( $callback )
{
	var doc = this.doc;
	doc.useServiceAccountAuth( cred, onInit );

	function onInit()
	{
		doc.getInfo( onInfo );
	}

	function onInfo( $err, $info )
	{
		if( $err )
			throw $err;

		doc.worksheets = $info.worksheets

		$callback( $info );
	}
}

Spreadsheet.prototype.getWorksheet = function( $title )
{
	var doc = this.doc;

	if( doc.worksheets == null )
		return null;

	var i = doc.worksheets.length;
	while( i-- )
	{
		if( doc.worksheets[ i ].title == $title )
			return doc.worksheets[ i ];
	}

	return null;
}

Spreadsheet.prototype.addWorksheet = function( $option, $callback )
{
	this.doc.addWorksheet( $option, onAdd );

	function onAdd( $err, $sheet )
	{
		if( $err )
			throw $err;
		
		$callback( $sheet );
	}
}