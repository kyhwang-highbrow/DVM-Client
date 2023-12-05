const util = require( "../util" );

module.exports = function()
{
	var date = new Date();
	var HH = util.string.setDigit( date.getHours(), 2 );
	var MM = util.string.setDigit( date.getMinutes(), 2 );
	var SS = util.string.setDigit( date.getSeconds(), 2 );
	var MS = util.string.setDigit( date.getMilliseconds(), 4 );

	var args = [];
	for( var prop in arguments )
	{
		args[ parseInt( prop ) ] = arguments[ prop ];
	}

	console.log( "\x1b[36m[" + HH + ":" + MM + ":" + SS + "." + MS + "]\x1b[0m " + args.toString() );
}