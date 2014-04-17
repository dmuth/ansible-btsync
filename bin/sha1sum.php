#!/usr/bin/env php
<?php
/**
* This script creates SHA1 hashes of files and directories.
* Directories are hashed by concatenating the hashes of the files within 
* them, and then hashing that string.
*/

//
// A global to keep track of our debugging status
//
$debugging = false;

/**
* Print up our syntax and exit.
*/
function print_syntax($argv) {

	printf("Syntax: %s [-v|--verbose] file|dir [ file|dir [ file|dir [ ... ] ] ]\n"
		. "\tfile|dir A file or directory to get the SHA1 sum of.\n"
		. "\t-v, --verbose Run in verbose mode.\n",
		$argv[0]);
	exit(1);

} // End of print_syntax()


/**
* Debugging function.
*/
function debug($str) {

	if ($GLOBALS["debug"]) {
		print "DEBUG: $str\n";
	}

} // End of debug()


/**
* Check to see if a file/directory exists and is readable.
*/
function exists($file) {

	if (!is_file($file) && !is_dir($file) && !is_link($file) ) {
		$error = "File/dir '$file' does not exist!";
		throw new Exception($error);

	} else if (!is_readable($file)) {
		$error = "File/dir '$file	' is not readable!";
		throw new Exception($error);

	}

} // End of exists()


/**
* Parse our arguments.
*
* @return {array} Associative array of data.
*/
function parse_args($argv) {

	$retval = array();
	$retval["files"] = array();

	for ($i=1; $i<count($argv); $i++) {

		$arg = $argv[$i];

		if ($arg == "-h" || $arg == "--help") {
			print_syntax($argv);
		}

		if ($arg == "-v" || $arg == "--verbose") {
			$GLOBALS["debug"] = true;
			debug("Debugging enabled!");

		} else {
			exists($arg);
			$retval["files"][] = $arg;

		}

	}

	return($retval);

} // End of parse_args()


/**
* Our main entry point.
*/
function main($argv) {

	$params = parse_args($argv);

} // End of main()

try {
	main($argv);

} catch (Exception $error) {
	print "ERROR: $error\n";

}


