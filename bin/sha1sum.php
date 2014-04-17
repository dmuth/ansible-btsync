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
$debug = false;

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

	//
	// Sanity check
	//
	if (count($retval["files"]) == 0) {
		print_syntax($argv);
	}

	return($retval);

} // End of parse_args()


/**
* Function to recursively get the SHA1 of files and directories.
*
* @return {string} Our SHA1
*/
function get_sha1($file) {

	$retval = "";

	//
	// Make sure the file/directory is readable, or else we come to 
	// a FULL STOP.  I felt this was an appropriate way to handle things, 
	// because you don't want to have the possibility of an unreadable 
	// file throwing off your hash in an unnoticed manner.
	//
	// "We all go home or nobody goes home!"
	//
	exists($file);

	if (!is_dir($file)) {
		debug("File found: $file");
		$contents = file_get_contents($file);
		$retval = sha1($contents);

	} else {
		//
		// If we found a directory, recurse through its contents
		//
		debug("Directory found: $file");

		$hashes = "";
		$fp = opendir($file);

		while ($line = readdir($fp)) {

			if ($line == "." || $line == "..") {
				continue;
			}
			$target = $file . "/" . $line;
			$hash = get_sha1($target);
			$hashes .= $hash . "\n";
			
			debug(sprintf("Hash of %s: %s", $target, $hash));
		}

		debug("Hashes done for directory '$file': $hashes");
		$retval = sha1($hashes);

		closedir($fp);

	}

	return($retval);

} // End of get_sha1()



/**
* Our main entry point.
*/
function main($argv) {

	$params = parse_args($argv);

	foreach ($params["files"] as $key => $value) {
		$sha1 = get_sha1($value);
		printf("SHA1 of %40s: %s\n", $value, $sha1);
		debug("");
		debug("---");
		debug("");

	}

} // End of main()

try {
	main($argv);

} catch (Exception $error) {
	print "ERROR: $error\n";

}


