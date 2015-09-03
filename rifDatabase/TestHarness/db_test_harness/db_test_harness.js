#!/usr/bin/env node

// ************************************************************************
//
// GIT Header
//
// $Format:Git ID: (%h) %ci$
// $Id: 7ccec3471201c4da4d181af6faef06a362b29526 $
// Version hash: $Format:%H$
//
// Description:
//
// Rapid Enquiry Facility (RIF) - Node.js test harness
//
// Copyright:
//
// The Rapid Inquiry Facility (RIF) is an automated tool devised by SAHSU 
// that rapidly addresses epidemiological and public health questions using 
// routinely collected health and population data and generates standardised 
// rates and relative risks for any given health outcome, for specified age 
// and year ranges, for any given geographical area.
//
// Copyright 2014 Imperial College London, developed by the Small Area
// Health Statistics Unit. The work of the Small Area Health Statistics Unit 
// is funded by the Public Health England as part of the MRC-PHE Centre for 
// Environment and Health. Funding for this project has also been received 
// from the Centers for Disease Control and Prevention.  
//
// This file is part of the Rapid Inquiry Facility (RIF) project.
// RIF is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// RIF is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with RIF. If not, see <http://www.gnu.org/licenses/>; or write 
// to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, 
// Boston, MA 02110-1301 USA
//
// Author:
//
// Peter Hambly, SAHSU
//
// Usage: test_harness [options] -- [test run class]
//
// Version: 0.1
//
// RIF 4.0 Database test harness.
//
// Options:
//  -d, --debug     RIF database PL/pgsql debug level      [default: 0]
//  -D, --database  name of Postgres database              [default: "sahsuland_dev"]
//  -U, --username  Postgres database username             [default: "pch"]
//  -P, --port      Postgres database port                 [default: 5432]
//  -H, --hostname  hostname of Postgres database          [default: "wpea-rif1"]
//  -F, --failed    re-run failed tests                    [default: false]
//  --help          display this helpful message and exit  [default: false]
//
// E.g.
//
// node db_test_harness.js -H wpea-rif1 -D sahsuland_dev -U pch -d 1
//
// Connects using Postgres native driver (not JDBC) as rif40.
//
// Uses:
//
// https://github.com/brianc/node-postgres
// https://github.com/substack/node-optimist
//
// See: Node Makefile for build instructions
//
	
/* 
 * Function: 	pg_default()
 * Parameters: 	Postgres variable name
 * Returns:		Defaulted value
 * Description: Setup postgres defaults (i.e. use PGDATABASE etc from env or set sensible default
 *				Used by optimist
 */
function pg_default(p_var) {
	var p_def;
	
	if (p_var == "PGDATABASE") {
		p_def="sahsuland_dev";
	}
	else if (p_var == "PGHOST") {
		p_def="localhost";
	}
	else if (p_var == "PGUSER") {
		p_def=process.env["USERNAME"];
		if (p_def === undefined) {
			p_def=process.env["USER"];
			if (p_def === undefined) {
				p_def="";
			}
		}
	}	
	else if (p_var == "PGPORT") {
		p_def=5432;
	}
	
	if (process.env[p_var]) { 
		return process.env[p_var];
	} 
	else { 
		return p_def;
	}
}

//
// Will eventually support SQL server as well
//
var pg = require('pg'),
	optimist  = require('optimist');
	
/* 
 * Function: 	main()
 * Parameters: 	ARGV
 * Returns:		Nothing
 * Description: Create control database connecton, then run rif40_startup()
 *				Then _rif40_sql_test_log_setup() ...
 */	
function main() {
	
	var client1 = null; // Client 1: Master; hard to remove 
	var p_debug_level = null;
	
// Process Args using optimist
	var argv = optimist
    .usage("Usage: \033[1mtest_harness\033[0m [options] -- [test run class]\n\n"

+ "Version: 0.1\n\n"
+ "RIF 4.0 Database test harness.")

    .options("d", {
      alias: "debug_level",
      describe: "RIF database PL/pgsql debug level",
	  type: "integer",
      default: 0
    })
    .options("D", {
      alias: "database",
      describe: "name of Postgres database",
	  type: "string",
      default: pg_default("PGDATABASE")
    })
    .options("U", {
      alias: "username",
      describe: "Postgres database username",
	  type: "string",
      default: pg_default("PGUSER") 
    })	
    .options("P", {
      alias: "port",
      describe: "Postgres database port",
	  type: "integer",
      default: pg_default("PGPORT") 
    })		
    .options("H", {
      alias: "hostname",
      describe: "hostname of Postgres database",
	  type: "string",
      default: pg_default("PGHOST")
    })
    .options("F", {
      alias: "failed",
      describe: "re-run failed tests",
	  type: "boolean",
      default: false
    })		
    .options("help", {
      describe: "display this helpful message and exit",
      type: "boolean",
      default: false
    })	
	 .check(function(argv) {
      if (argv.help) return;
    })
    .argv;

	if (argv.help) return optimist.showHelp();
	
//
// This needs to be rewritten to handle the ::1 problem nicely
//

	// Create 2x Postgres clients; one for control, the second for running each test in turn.
	var conString = 'postgres://' + argv["username"] + '@'; // Use PGHOST, native authentication (i.e. same as psql)
	// If host = localhost, use IPv6 numeric notation. This prevent ENOENT errors from getaddrinfo() in Windows
	// when Wireless is disconnected. This is a Windows DNS issue. psql avoids this somehow.
	// You do need entries for ::1 in pgpass
	if (argv["hostname"] == 'localhost') {
		conString=conString + '[::1]';
	}
	else {
		conString=conString + argv["hostname"];
	}
	if (argv["port"] != 5432) {
		conString=conString + ':' + argv["port"];
	}
	conString=conString + '/' + argv["database"] + '?application_name=db_test_harness';

	try {
		client1 = new pg.Client(conString);
		console.log('1: Connect to Postgres using: ' + conString);
		
	}
	catch(err) {
			return console.error('1: Could not create postgres 1st client [master] using: ' + conString, err);
	}

// Notice message event processors
	client1.on('notice', function(msg) {
		  console.log('1: %s', msg);
	});
		
// Connect to Postgres database
	client1.connect(function(err) {
		if (err) {
			return console.error('1: Could not connect to postgres 1st client [master] using: ' + conString, err);
		}
		else {
			p_debug_level=argv["debug_level"];
			if (argv["failed"] && p_debug_level == 0) {
				p_debug_level=1;
			}
// Call rif40_startup; then subsequent functions in an async tree
			rif40_startup(client1, 1, p_debug_level, conString, client1, argv["failed"]);
		} // End of else connected OK 
	}); // End of connect
}

/* 
 * Function: 	rif40_startup()
 * Parameters: 	Client connection, connection number (1 or 2), debug level, connection string, 
                master client (1) connection [may NOT be null], failed flag
 * Returns:		Nothing
 * Description: Run rif40_startup()
 *				Then _rif40_sql_test_log_setup()
 */
function rif40_startup(p_client, p_num, p_debug_level, p_conString, p_client1, p_failed_flag) {
	var sql_stmt;
	
// Check master client (1) connection is NOT undefined	
	if (p_client1 === undefined) {
		console.error(p_num + ': rif40_startup() master client (1) connection is undefined');			
		process.exit(1);	
	}

// Check failed flag is NOT undefined	
	if (p_failed_flag === undefined) {
		console.error(p_num + ': rif40_startup() failed flag is undefined');			
		process.exit(1);	
	}
	
	if (p_num == 1) {
		sql_stmt = 'SELECT rif40_sql_pkg.rif40_startup() AS a';
	}
	else {
		sql_stmt = 'SELECT rif40_sql_pkg.rif40_startup(TRUE /* Do not do checks */) AS a';
	}
		
	// Connected OK, run SQL query
	var query = p_client.query(sql_stmt, function(err, result) {
		if (err) {
			// Error handler
			console.error(p_num + ': Error running query: ' + sql_stmt + ';', err);
			p_client.end();			
			process.exit(1);
		}
		else {	
			query.on('row', function(row) {
				//fired once for each row returned
				result.addRow(row);
			});
			query.on('end', function(result) {
				_rif40_sql_test_log_setup(p_client, p_num, p_debug_level, p_conString, p_client1, p_failed_flag);
				return;
			});	
		}
	});	
}

/* 
 * Function: 	_rif40_sql_test_log_setup()
 * Parameters: 	Client connection, connection number (1 or 2), debug level, connection string, 
                master client (1) connection [may NOT be null], failed flag
 * Returns:		Nothing
 * Description: Run _rif40_sql_test_log_setup()
 *				Then if you are the control connection (1) call init_test_harness()
 *				Otherwise can run_test_harness() using the control connection
 */
function _rif40_sql_test_log_setup(p_client, p_num, p_debug_level, p_conString, p_client1, p_failed_flag) {
	
// Check master client (1) connection is NOT undefined	
	if (p_client1 === undefined) {
		console.error(p_num + ': _rif40_sql_test_log_setup() master client (1) connection is undefined');			
		process.exit(1);	
	}
		
	var sql_stmt = 'SELECT rif40_sql_pkg._rif40_sql_test_log_setup(' + p_debug_level + ') AS a';
			
	// Connected OK, run SQL query
	var query = p_client.query(sql_stmt, function(err, result) {
		if (err) {
			// Error handler
			console.error(p_num + ': Error running query: ' + sql_stmt + ';', err);
			p_client.end();			
			process.exit(1);
		}
		else {	
			query.on('row', function(row) {
				//fired once for each row returned
				result.addRow(row);
			});
			query.on('end', function(result) {
				if (p_num == 1) { // p_client is master [1]
					// Client 1 [Master] waits after test harness initialisation
					console.log('1: Wait for client 2 initialisation; debug_level: ' + p_debug_level);
					// Create 2nd client(worker thread) for running test cases
					init_test_harness(p_client1, p_debug_level, p_conString, p_failed_flag);
				}
				else { // p_client is slave [2]
					// Client 2 [slave worker] is now initialised so we can run the test harness tests
					console.log('1: Client 2 initialised; debug_level: ' + p_debug_level);
					run_test_harness(p_client1, p_client, p_failed_flag); 
				}
				return;
			});	
		}
	});	
	
}

/* 
 * Function: 	init_test_harness()
 * Parameters: 	Master client (1) connection, debug level, connection string, failed flag
 * Returns:		Nothing
 * Description: Create 2nd client (worker thread) for running test cases
 */
function init_test_harness(p_client1, p_debug_level, p_conString, p_failed_flag) {
	var client2 = null;

// Check master client (1) connection is NOT undefined	
	if (p_client1 === undefined) {
		console.error('1: init_test_harness() master client (1) connection is undefined');			
		process.exit(1);	
	}
	
// Create 2nd client (worker thread) for running test cases
	try {
		console.log('2: Connect to Postgres using: ' + p_conString);		
		client2 = new pg.Client(p_conString);
	}
	catch(err) {
			return console.error('2: Could not create postgres 2nd client [slave] using: ' + p_conString, err);
	}
	client2.on('notice', function(msg) {
// Suppress client 2 (worker thread) initialisation messages; re-enabled in run_test_harness()
//	      console.log('2: %s', msg);
	});
	client2.connect(function(err) {
		if (err) {
			return console.error('2: Could not connect to postgres 2nd client [slave] using: ' + p_conString, err);
		}
		else {	
	        // Call rif40_startup; then subsequent functions in an async tree
			rif40_startup(client2, 2, p_debug_level, p_conString, p_client1, p_failed_flag);
		} // End of else connected OK 
	}); // End of connect
}
	
/* 
 * Function: 	run_test_harness()
 * Parameters: 	Master client (1) connection, worker thread client (2) connection, failed flag
 * Returns:		Nothing
 * Description: Run test harness:
 *
 *              COMMIT; to complete initial on logon transaction
 *              Build SQL statement to display tests per test_run_class, handling -F flag to re-run failed tests only
 *				Display tests per test_run_class, total tests
 * 			    Finally run the tests: function run_test_harness_tests()
 */
function run_test_harness(p_client1, p_client2, p_failed_flag) {
	var total_tests=0;
	// COMMIT; to complete initial on logon transaction
	var end = p_client2.query('COMMIT', function(err, result) {
		if (err) {
			p_client2.end();
			return console.error('2: Error in COMMIT transaction;', err);
		}
		else {
			// Transaction COMMIT OK 
			end.on('end', function(result) {	
				console.log('2: COMMIT transaction;');					
			    // Build SQL statement to display tests per test_run_class, handling -F flag to re-run failed tests only
				var sql_stmt = 'SELECT test_run_class, COUNT(test_run_class) AS tests, MIN(register_date) AS min_register_date\n' +
					'  FROM rif40_test_harness a\n' +
					' WHERE parent_test_id IS NULL /* Ignore dependent tests */\n';
					
				if (p_failed_flag) {
					console.log('1: Processing -F flag to re-run failed tests only');
					sql_stmt = sql_stmt + '  AND pass = FALSE /* Filter on failed tests only */\n';
				}
				sql_stmt = sql_stmt +
					' GROUP BY test_run_class\n' +
					' ORDER BY 3 /* min_register_date */';
						
				// Connected OK, run SQL query
				var query = p_client1.query(sql_stmt, function(err, result) {
					if (err) {
						// Error handler
						console.error('1: Error running query: ' + sql_stmt + ';', err);
						p_client1.end();			
						process.exit(1);
					}
					else {	
						query.on('row', function(row) {
							//fired once for each row returned
							result.addRow(row);
						});
						query.on('end', function(result) {
							// Re-enable client 2 [worker] debug messages
							p_client2.on('notice', function(msg) {
								console.log('2: %s', msg);
							});			
							// End of query processing - process results array - tests per class
							row_count = result.rowCount;
							for (i = 1; i <= row_count; i++) { 
								console.log('2: Class: %s Tests: %s', result.rows[i-1].test_run_class, result.rows[i-1].tests);
								total_tests=total_tests + parseInt(result.rows[i-1].tests, 10);
							}
							console.log('2: Total tests %s', total_tests);
							// Finally run the tests: function run_test_harness_test()
							run_test_harness_tests(p_client1, p_client2, total_tests, p_failed_flag);							
						});	
					}
				});		
			});
		}
	});		
}

/* 
 * Function: 	run_test_harness_tests()
 * Parameters: 	Master client (1) connection, worker thread client (2) connection, number of tests, failed flag
 * Returns:		Nothing
 * Description: Run test harness tests:
 *
 *				Build SQL statement to run tests, handling -F flag to re-run failed tests only
 *				Run query, push results data into results array
 *				Run the first test using rif40_sql_test(). 
 *				The rest of the tests are run recursively from rif40_sql_test() from query.on('end', ...) 
 *				so the SQl statements and transactions are run in the correct order.
 */
function run_test_harness_tests(p_client1, p_client2, p_tests, p_failed_flag) {
	// Test arrays; 
	var p_test_run_class = [];
	var p_test_case_title = [];	
	var p_test_stmt = []; 
	var p_results = []; 
	var p_results_xml = []; 
	var p_pg_error_code_expected = []; 
	var p_raise_exception_on_failure = []; 
	var p_test_id = [];
	var p_expected_result = [];

	var p_pass = [];
	var p_time_taken = [];

	// Build SQL statement to run tests, handling -F flag to re-run failed tests only
	var sql_stmt = 'SELECT a.*\n' +
		'  FROM rif40_test_harness a\n' +
		' WHERE a.parent_test_id IS NULL /* Ignore dependent tests */\n';
	if (p_failed_flag) {
		sql_stmt = sql_stmt + '  AND pass = FALSE /* Filter on failed tests only */\n';
	}
	sql_stmt = sql_stmt +
		' ORDER BY a.test_id';
					
	// Connected OK, run SQL query
	var query = p_client1.query(sql_stmt, function(err, test_array) {
		if (err) {
			// Error handler
			console.error('1: Error running query: ' + sql_stmt + ';', err);
			p_client1.end();			
			process.exit(1);
		}
		else {	
			query.on('row', function(row) {
				//fired once for each row returned
				test_array.addRow(row);
			});
			query.on('end', function(test_array) {	
				// End of query processing - process results array
				row_count = test_array.rowCount;
				p_test_run_class = new Array();
				p_test_case_title = new Array(); 
				p_test_stmt = new Array(); 
				p_results = new Array(); 
				p_results_xml = new Array(); 
				p_pg_error_code_expected = new Array(); 
				p_raise_exception_on_failure = new Array(); 
				p_test_id = new Array(); 
				p_expected_result = new Array();
				p_pass = new Array();
				p_time_taken = new Array();
				
				p_rif40_test_harness = {};
				
				if (row_count > 0) {
					// Push results data into results array
					for (j = 0; j <row_count; j++) { 
						p_test_run_class.push(test_array.rows[j].test_run_class /* Deep copy */);
						p_test_case_title.push(test_array.rows[j].test_case_title /* Deep copy */);
						p_test_stmt.push(test_array.rows[j].test_stmt /* Deep copy */);
						p_results.push(test_array.rows[j].results /* Deep copy */);
						p_results_xml.push(test_array.rows[j].results_xml /* Deep copy */);
						p_pg_error_code_expected.push(test_array.rows[j].pg_error_code_expected /* Deep copy */);	
						p_raise_exception_on_failure.push(test_array.rows[j].raise_exception_on_failure /* Deep copy */);
						p_test_id.push(test_array.rows[j].test_id /* Deep copy */);		
						p_expected_result.push(test_array.rows[j].expected_result /* Deep copy */);	
						p_pass.push(undefined);
						p_time_taken.push(undefined);						
					
						if (p_test_case_title[j] === undefined) {
							console.error('1: ' + test + ' run_test_harness_tests() p_test_case_title[' + j + '] is undefined');			
							process.exit(1);							
						}
						p_rif40_test_harness[j] = { 
							test_run_class: test_array.rows[j].test_run_class, 
							test_case_title: test_array.rows[j].test_case_title, 
							test_stmt: test_array.rows[j].test_stmt, 
							results: test_array.rows[j].results,
							results_xml: test_array.rows[j].results_xml,
							pg_error_code_expected: test_array.rows[j].pg_error_code_expected, 
							raise_exception_on_failure: test_array.rows[j].raise_exception_on_failure,
							test_id: test_array.rows[j].test_id,
							expected_result: test_array.rows[j].expected_result,
							pass: undefined,
							time_taken: undefined };	
						if (p_rif40_test_harness[j].test_case_title === undefined) {
							console.error('1: ' + test + ' run_test_harness_tests() p_rif40_test_harness[' + j + '].test_case_title is undefined');			
							process.exit(1);							
						}							
					}
						
					// Run the first test using rif40_sql_test(). 
					// The rest of the tests are run recursively from rif40_sql_test() from query.on('end', ...) 
					// so the SQl statements and transactions are run in the correct order.
					rif40_sql_test(p_client1, p_client2, 1, p_tests, 
							0 /* p_passed */, 0 /* p_failed */, p_failed_flag, p_rif40_test_harness);
				}
				else {
					console.error('1: No tests to run');
					process.exit(1);					
				}
				return;
			});	
		}
	});				
}

/* 
 * Function: 	rif40_sql_test()
 * Parameters: 	Master client (1) connection, worker thread client (2) connection, test number, number of tests, 
 *              number passed, number failed, failed flag, test harness results array
 * Returns:		Nothing
 * Description:
 */
function rif40_sql_test(p_client1, p_client2, p_j, p_tests, 
				p_passed, p_failed, p_failed_flag, p_rif40_test_harness) {	

	var test='[' + p_j + '/' + p_tests + ']: ' + p_rif40_test_harness[p_j-1].test_run_class + '] ' + 
			p_rif40_test_harness[p_j-1].test_case_title;

	// Check failed flag is NOT undefined	
	if (p_failed_flag === undefined) {
		console.error('1: ' + test + ' rif40_sql_test() failed flag is undefined');			
		process.exit(1);	
	}
	// Check p_rif40_test_harness object of arrays is NOT undefined	
	if (p_rif40_test_harness === undefined) {
		console.error('1: ' + test + ' rif40_sql_test() p_rif40_test_harness object of arrays is undefined');			
		process.exit(1);	
	}
	if (p_rif40_test_harness[p_j-1] === undefined) {
		console.error('2: ' + test + ' rif40_sql_test() p_rif40_test_harness[' + p_j-1 + '] is undefined');			
		process.exit(1);							
	}		
	if (p_rif40_test_harness[p_j-1].test_stmt === undefined) {
		console.error('2: ' + test + ' rif40_sql_test() p_rif40_test_harness[' + p_j-1 + '].p_test_stmt is undefined');			
		process.exit(1);							
	}
	
	var start_time=Date.now();
	var begin = p_client2.query('BEGIN', function(err, result) {
		var next=p_j+1;
		if (err) {
			p_client2.end();
			console.error('2: Error in BEGIN transaction;', err);
			p_client1.end();			
			process.exit(1);
		}
		else {
			// Transaction start OK 
			begin.on('end', function(result) {			
				console.log('1: ' + test);			
				console.log('2: BEGIN transaction: ' + test);		

				// Run test
				var sql_stmt = 'SELECT rif40_sql_pkg._rif40_sql_test(' + '\n' + 
						'$1::VARCHAR 	/* test_stmt */,' + '\n' + 
						'$2::VARCHAR 	/* test_case_title */,' + '\n' + 
						'$3::Text[][] 	/* results */,' + '\n' + 
						'$4::XML 		/* results_xml */,' + '\n' +
						'$5::VARCHAR 	/* pg_error_code_expected */,' + '\n' +
						'$6::BOOLEAN 	/* raise_exception_on_failure */,' + '\n' +
						'$7::INTEGER 	/* test_id */) AS rbool';

				var run = p_client2.query({
							text: sql_stmt, 
							values: [p_rif40_test_harness[p_j-1].test_stmt,
									 p_rif40_test_harness[p_j-1].test_case_title, 
									 p_rif40_test_harness[p_j-1].results, 
								     p_rif40_test_harness[p_j-1].results_xml,
									 p_rif40_test_harness[p_j-1].pg_error_code_expected,
									 p_rif40_test_harness[p_j-1].raise_exception_on_failure,
									 p_rif40_test_harness[p_j-1].test_id]}, 
						function(err, result) {
					if (err) {
						console.error('2: Error in run test; SQL> ' + sql_stmt + 
				'*\n* [Parameter 1: p_test_stmt                 VARCHAR]\nSQL>>>' + p_rif40_test_harness[p_j-1].test_stmt + ';\n' + 
				'* [Parameter 2: p_test_case_title              VARCHAR]  ' + p_rif40_test_harness[p_j-1].test_case_title + '\n' + 
				'* [Parameter 3: p_results                      TEXT[][]] ' + p_rif40_test_harness[p_j-1].results + '\n' + 
				'* [Parameter 4: p_results_xml                  XML]      ' + p_rif40_test_harness[p_j-1].results_xml + '\n' + 
				'* [Parameter 5: p_pg_error_code_expected       VARCHAR]  ' + p_rif40_test_harness[p_j-1].pg_error_code_expected + '\n' + 
				'* [Parameter 6: p_raise_exception_on_failure   BOOLEAN]  ' + p_rif40_test_harness[p_j-1].raise_exception_on_failure + '\n' + 
				'* [Parameter 7: p_test_id                      INTEGER]  ' + p_rif40_test_harness[p_j-1].test_id + '\n' + 
				'*\n' + '*****************************************************************************\n', err);	
						console.error('2: ROLLBACK transaction: ' + test);
						var end = p_client2.query('ROLLBACK', function(err, result) {
							if (err) {
								console.error('2: Error in ROLLBACK transaction after error;', err);							
								p_client2.end();
								p_client1.end();			
								process.exit(1);			
							}
							else {	
								p_client2.end();
								p_client1.end();							
								process.exit(1);
							}	
						});
					}
					else {
						// Test OK 
							run.on('row', function(row) {
								//fired once for each row returned
								result.addRow(row);
							});
						// End of run processing - process results 					
						run.on('end', function(result) {
							row_count = result.rowCount;	
//							console.log('rbool: ' + result.rows[0].rbool + '; p_expected_result[p_j-1]: ' + 
//								p_rif40_test_harness[p_j].expected_result);
							if (row_count != 1) {
									console.error('2: Test FAILED: (' + row_count + ') rows ' + test + '\n' + 'SQL> ' + sql_stmt);	
									p_failed++;			
							}
							else if (result.rows[0].rbool == false)   /* Test failed */ {
								if (p_rif40_test_harness[p_j-1].expected_result == true) /* It was expected to pass */ {
									test_result(false, '2: Test FAILED, expected to PASS: ' + test, sql_stmt,
											p_rif40_test_harness, p_j-1);
									p_rif40_test_harness[p_j-1].pass = false;
									p_failed++;
								}
								else {
									test_result(true, '2: Test FAILED as expected: ' + test, sql_stmt,
											p_rif40_test_harness, p_j-1);
									p_rif40_test_harness[p_j-1].pass = true;
									p_passed++; 										
								}
							}
							else { /* Test passed */
								if (p_rif40_test_harness[p_j-1].expected_result == true) /* It was expected to pass */ {								
									test_result(true, '2: Test OK: ' + test, sql_stmt,
											p_rif40_test_harness, p_j-1);
									p_rif40_test_harness[p_j-1].pass = true;
									p_passed++;
								}
								else {
									test_result(false, '2: Test PASSED, expected to FAIL: ' + test, sql_stmt,
											p_rif40_test_harness, p_j-1);
									p_rif40_test_harness[p_j-1].pass = false;										
									p_failed++;									
								}
							}
							p_rif40_test_harness[p_j-1].time_taken = (Date.now()-start_time)/1000;
							
							var end = p_client2.query('ROLLBACK', function(err, result) {
								if (err) {
									p_client2.end();
									console.error('2: Error in ROLLBACK transaction;', err);
									p_client1.end();			
									process.exit(1);			
								}
								else {
									// Transaction ROLLBACK OK 
									end.on('end', function(result) {	
										console.log('2: ROLLBACK transaction: ' + test);
										if (p_j === p_tests) {
											end_test_harness(p_client1, p_client2, p_passed, p_failed, p_tests, 1, p_failed_flag, 
													p_rif40_test_harness); 
										}
										else {
											console.log('1: Recurse; next: ' + next);
											rif40_sql_test(p_client1, p_client2, next, p_tests, 
													p_passed, p_failed, p_failed_flag, p_rif40_test_harness);
										}													
									});
								}
							});	
						});
					}
				});					
			});			
		}
	});

}

/* 
 * Function: 	test_result()
 * Parameters: 	pass or fail flag, test rsult text, SQL statement, test harness results array, index to array
 * Returns:		Nothing
 * Description: Print test results
 */
function test_result(p_pass, p_text, p_sql_stmt, p_rif40_test_harness, p_j) {

	// Check p_rif40_test_harness object of arrays is NOT undefined	
	if (p_rif40_test_harness === undefined) {
		console.error('2: ' + test + ' test_result() p_rif40_test_harness object of arrays is undefined');			
		process.exit(1);	
	}
	if (p_rif40_test_harness[p_j] === undefined) {
		console.error('2: ' + test + ' test_result() p_rif40_test_harness[' + p_j + '] is undefined');			
		process.exit(1);							
	}		
	if (p_rif40_test_harness[p_j].test_stmt === undefined) {
		console.error('2: ' + test + ' test_result() p_rif40_test_harness[' + p_j + '].p_test_stmt is undefined');			
		process.exit(1);							
	}
	
	if (p_pass) {
			console.log('*****************************************************************************\n' + '*\n' +
				p_text + '\n' + 
				'*\n' + '*****************************************************************************\n');
	}
	else {
			console.log('*****************************************************************************\n' + '*\n' +
				p_text + '\n' + 'SQL> ' + p_sql_stmt + ';' + '\n' + 
				'*\n* [Parameter 1: test_stmt                 VARCHAR]\nSQL>>>' + p_rif40_test_harness[p_j].test_stmt + ';\n' + 
				'* [Parameter 2: test_case_title              VARCHAR]  ' + p_rif40_test_harness[p_j].test_case_title + '\n' + 
				'* [Parameter 3: results                      TEXT[][]] ' + p_rif40_test_harness[p_j].results + '\n' + 
				'* [Parameter 4: results_xml                  XML]      ' + p_rif40_test_harness[p_j].results_xml + '\n' + 
				'* [Parameter 5: pg_error_code_expected       VARCHAR]  ' + p_rif40_test_harness[p_j].pg_error_code_expected + '\n' + 
				'* [Parameter 6: raise_exception_on_failure   BOOLEAN]  ' + p_rif40_test_harness[p_j].raise_exception_on_failure + '\n' + 
				'* [Parameter 7: test_id                      INTEGER]  ' + p_rif40_test_harness[p_j].test_id + '\n' + 
				'*\n' + '*****************************************************************************\n');
	}
}

/* 
 * Function: 	end_test_harness()
 * Parameters: 	Master client (1) connection, worker thread client (2) connection, tests passed, tests failed, number of tests, 
 *              failed flag, test harness results array 
 * Returns:		Nothing
 * Description: End processing for tes harness. Recursive, called for each test from test 1
 *
 *				Check p_failed_flag, p_rif40_test_harness are defined correctly
 *				For first test:
 *					Summarize run 
 *					BEGIN update transaction
 *				call _end_test_harness() which:
 * 					Do update
 * 					Summarise result
 *					On final test, COMMIT and exit with number of failed tests
 *					Recurse to next test
 */
function end_test_harness(p_client1, p_client2, p_passed, p_failed, p_tests, p_j, p_failed_flag, p_rif40_test_harness) {
					
// Check failed flag is NOT undefined	
	if (p_failed_flag === undefined) {
		console.error('1: end_test_harness() failed flag is undefined');			
		process.exit(1);	
	}
	// Check p_rif40_test_harness object of arrays is NOT undefined	
	if (p_rif40_test_harness === undefined) {
		console.error('1: ' + test + ' end_test_harness() p_rif40_test_harness object of arrays is undefined');			
		process.exit(1);	
	}
	if (p_rif40_test_harness[p_j-1] === undefined) {
		console.error('1: ' + test + ' end_test_harness() p_rif40_test_harness[' + p_j-1 + '] is undefined');			
		process.exit(1);							
	}		
	if (p_rif40_test_harness[p_j-1].pass === undefined) {
		console.error('1: ' + test + ' end_test_harness() p_rif40_test_harness[' + p_j-1 + '].pass is undefined');			
		process.exit(1);							
	}	
	if (p_rif40_test_harness[p_j-1].time_taken === undefined) {
		console.error('1: ' + test + ' end_test_harness() p_rif40_test_harness[' + p_j-1 + '].time_taken is undefined');			
		process.exit(1);							
	}	
	if (p_rif40_test_harness[p_j-1].test_id === undefined) {
		console.error('1: ' + test + ' end_test_harness() p_rif40_test_harness[' + p_j-1 + '].test_id is undefined');			
		process.exit(1);							
	}	
	
	// Summarize run
	if (p_j == 1) {
		if (p_failed_flag) {
				console.log('1: Ran with -F flag to re-run failed tests only');
		}
		if (p_failed > 0) {
			console.error('1: Test harness complete; ' + p_tests + ' tests completed; passed: ' + p_passed +
				'; failed: ' + p_failed);	
		}
		else {
			console.log('1: Test harness complete; ' + p_tests + ' tests completed; passed: ' + p_passed +
				'; none failed.');	
		}
		
		// BEGIN update transaction
		var begin = p_client1.query('BEGIN', function(err, result) {
			if (err) {
				p_client2.end();
				console.error('1: Error in BEGIN transaction: results UPDATE;', err);
				p_client1.end();			
				process.exit(1);
			}
			else {
				// Transaction start OK 
				begin.on('end', function(result) {						
					console.log('1: BEGIN transaction: results UPDATE');
					_end_test_harness(p_client1, p_client2, p_passed, p_failed, p_tests, p_j, p_failed_flag, p_rif40_test_harness);
				});
			}
		});
	}
	else {
		_end_test_harness(p_client1, p_client2, p_passed, p_failed, p_tests, p_j, p_failed_flag, p_rif40_test_harness);
	}
}

/* 
 * Function: 	_end_test_harness()
 * Parameters: 	Master client (1) connection, worker thread client (2) connection, tests passed, tests failed, number of tests, 
 *              failed flag, test harness results array 
 * Returns:		Nothing
 * Description: Helper functions for test harness end processing; called from end_test_harness().
 *
 * 				Do update
 * 				Summarise result
 *				On final test, COMMIT and exit with number of failed tests
 *				Recurse to next test
 */
function _end_test_harness(p_client1, p_client2, p_passed, p_failed, p_tests, p_j, p_failed_flag, p_rif40_test_harness) {
// Bindable update statement
	var update_stmt='UPDATE rif40_test_harness\n' +
					'   SET pass       = $1,\n' + 
					'       time_taken = $2,\n' + 
					'       test_date  = statement_timestamp()\n' +
					' WHERE test_id = $3';
					
	// Do update
	var update = p_client1.query({
						text: update_stmt, 
						values: [p_rif40_test_harness[p_j-1].pass,
								 p_rif40_test_harness[p_j-1].time_taken,
								 p_rif40_test_harness[p_j-1].test_id
								]},
				function(err, result) {
					if (err) {
						p_client2.end();
						console.error('1: Error in UPDATE: ' + update_stmt + '; ', err);
						p_client1.end();			
						process.exit(1);			
					}
					else { // UPDATE OK 
						update.on('end', function(result) {	
						    // Summarise result
							console.log('1: [' + p_j + '/' + p_tests + '] ' + p_rif40_test_harness[p_j-1].test_case_title + 
								'; id: ' +  p_rif40_test_harness[p_j-1].test_id + 
								'; pass: ' + p_rif40_test_harness[p_j-1].pass + 
								'; time taken: ' + p_rif40_test_harness[p_j-1].time_taken + ' S');	
								// On final test, COMMIT and exit with number of failed tests
								if (p_j == p_tests) {
										var commit = p_client1.query('COMMIT', function(err, result) {
											if (err) {
												p_client2.end();
												console.error('1: Error in COMMIT transaction;', err);
												p_client1.end();			
												process.exit(1);			
											}
											else {
												// Transaction COMMIT OK 
												commit.on('end', function(result) {	
													console.log('1: COMMIT transaction.');
													
													p_client2.end();
													p_client1.end();	
													
													// Exit point on "normal" run. Fails if any tests are failed
													process.exit(p_failed);
													});
											}
										});
								}
								else {
									// Recurse to next test
									end_test_harness(p_client1, p_client2, p_passed, p_failed, 
											p_tests, p_j + 1, p_failed_flag, p_rif40_test_harness); 
								}
							});
					}
	});		

} 

main();

//
// Eof

