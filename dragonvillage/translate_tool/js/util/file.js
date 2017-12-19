const fs = require( "fs" );
const fse = require( "fs-extra" );
const path = require( "path" );

exports.getAllFiles = function( $directory, $option )
{
	var fileList = [];

	getFiles( $directory );

	function getFiles( $dir )
	{
		var files = fs.readdirSync( $dir );
		var i, len = files.length;
		var file;
		for( i = 0 ; i < len ; i++ )
		{
			file = files[ i ];

			if( $option )
			{
				if( $option.ignoreFiles && $option.ignoreFiles.indexOf( file ) > -1 )
					continue;

				if( $option.ignoreExtensions && $option.ignoreExtensions.indexOf( path.extname( file ) ) > -1 )
					continue;				
			}

			if( fs.statSync( $dir + file ).isDirectory() )
			{
				var tempPath = $dir + file + "/";
				if( $option.ignoreFolders && tempPath.indexOf($option.ignoreFolders) > -1 )
					continue;
				
				getFiles( $dir + file + "/" );

				continue;
			}

			fileList.push( $dir + file );
		}
	}

	return fileList;
}

exports.mkdir = function( $path )
{
	if( fs.existsSync( $path ) == false )
		fse.mkdirpSync( $path );
}

exports.rmdir = function( $path )
{
	fse.removeSync( $path );
}

exports.writeFile = function( $path, $data )
{
	var option = {};
	option.encoding = "utf-8";
	option.flag = "w";

	fs.writeFileSync( $path, $data, option );
}

exports.copy = function( $target, $destination )
{
	fse.copySync( path.resolve( $target ), path.resolve( $destination ) );
}