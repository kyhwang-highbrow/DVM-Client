exports.timeToFormat = function( $milliseconds )
{
	var date = new Date( $milliseconds );
	var str = date.getFullYear() + "."
		 + exports.setDigit( date.getMonth() + 1, 2 ) + "."
		 + exports.setDigit( date.getDate(), 2 ) + " "
		 + exports.setDigit( date.getHours(), 2 ) + ":"
		 + exports.setDigit( date.getMinutes(), 2 ) + ":"
		 + exports.setDigit( date.getSeconds(), 2 );

	return str;
}

exports.setDigit = function( $str, $digit )
{
	var str = "";

	var i = 0;
	for( i ; i < $digit ; i++ )
	{
		str += "0";
	}

	str += $str;

	var result = str.substr( -$digit, $digit );

	return result;
}


exports.compareVersion = function( $a, $b )
{
	var aList = $a.toString().split( "." );
	var bList = $b.toString().split( "." );

	var i = 1;
	var len = Math.max( aList.length, bList.length );
	var a, b;
	for( i ; i < len + 1 ; i++ )
	{
		a = parseInt( aList[ i - 1 ] ) || 0;
		b = parseInt( bList[ i - 1 ] ) || 0;

		if( a > b )
			return -i;

		if( a < b )
			return i;
	}

	return 0;
}