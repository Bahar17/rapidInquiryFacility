#Margaret Douglass Progress Report

Principal Work Area: **Microsoft SQL server database port** 

###2017

###January
Java related to the MS SQL Server port (+ handover)

######24 January
* Back to Query formatters for a little bit
MSSQLFieldVarianceQueryFormatter: Is that used at all?  I corrected the SQL
MSSQLFunctionCallerQueryFormatter: whether the SQL is valid depends on the user-defined function itself.  Is there an example for how is it used?
MSSQLImportTableFromCSVQueryFormatter: needs to be bulk insert and should use format files (messy)

######9 January
* Taking advantage of being stranded by the tube strike to focus on this code again.
MSSQLCreateIndexQueryFormatter: still uncertain whether there should be checks about whether columns can be indexed, whether they have full text enabled, checked with Kevin what kind of checks he normally does in the Java utliity classes
MSSQLCreatePrimaryKeyQueryFormatter: same problem about which checks to perform, including whether chosen column has any null values
MSSQLCreateTableQueryFormatter: temporary table syntax will be an issue -- names must begin with "#" (or else put them into tempDB tablespace)
MSSQLDeleteIndexQueryFormatter: fixed syntax, but I have not written the database code necessary to check whether index already exists -- easiest done in a user-defined database function instead of line-by-line Java
MSSQLDeleteRowsQueryFormatter: removed all incorrect (inappropriate) join code
MSSQLExportTableToCSVQueryFormatter: takes advantage of a postgres-only functionality, will be difficult to duplicate using SQL Server...
* Talking to Kevin about regexp options in SQL Server that do not require CLR/.NET

###2016

###December
I continued to work (part-time) on the Java utility classes that will be used to connect to Microsoft SQL Server.

######19 December
* Discussed with Kevin, we agreed to delete unused and incorrect functionality in SQL query classes instead of fixing the code.
* Made JUnit tests for MSSQLAggregateValueQueryFormatter (more to prove that I could do JUnit test cases than to really test whether the code for min/max was right)
* MSSQLCountTableRowsQueryFormatter clearly duplicates functions of MSSQLCountQueryFormatter, but included due to backwards compatiblity 

######15 December
* Returning to testing the SQL Query Java classes, now using the Windows laptop
* Now making formal JUnit test cases to be more thorough in my tests.  Using rif_data.sahsuland_cancer and related tables for the tests and answers
* MSSQLCountQueryFormatter: functions for joining 2 tables are very wrong.  Asked Kevin whether he thinks I should delete the functions (not currently called anywhere) or fix them so they can be used correctly in the future.
  - do we really only use 'AND' for multiple where clauses and never 'OR'?  

######14 December
* Finishing setting up sahsuland_dev in SQL Server on the Windows laptop, minor changes to the setup scripts to deal with the mismatched default collation problem.
(minor changes with collation clause not uploaded to Github because I don't know whether that is a common setup problem)

######13 December
* Continuing to set up Windows RIF laptop, many problems with Eclipse environment (as usual)

######12 December
* Setting up the Windows RIF laptop with SQL Server, tidying up some installation scripts.
* I discovered that the SQL Server database was created by default with a different collation (character set sorting method) from some of the system tables, consequentially comparing strings causes collation errors.  Easily fixed with "collate database_default" when comparing fields.  
(is it worth making that change in all SQL Server functions/views/trigger code to allow SQL Server to use different collation settings between dbs, or do we assume more sensible defaults than what I have on this laptop?)

######9 December
* Testing comments query formatter code on networked version of SQL Server.  Problems getting permissions right for the test ID.  Must be able to execute stored procedures
grant execute to 
grant alter on schema::rif_data/rif40 to 
* All table and function names need to explicitly state schemas.  AbstractSQLQueryFormatter.getSchemaTableName allows schema to be null/skipped, which is bad. 
* MSSQLAggregateValueQueryFormatter.java  -- code OK except table names need explicit schemas.   
* MSSQLCountQueryFormatter: Why would you ever order a count query with no group by aggregation? Kevin confirms we should remove the "order by" nonsense, I did so for MSSQL.  tables also need schemas.
* MSSQLCountTableRowsQueryFormatter -- repeats functionality already in MSSQLCountQueryFormatter.  OK except for the schema.table issue.  
* MSSQLCreateDatabaseQueryFormatter - Do we really need a generic class for this kind of very rare (I hope) command?  We are not going to be creating many databases in production version.  I added a check that the databaseName is a valid sql server identifier -- should that be a generic function?
* MSSQLCreateIndexQueryFormatter: Should there be error messages if you index data types that are not indexable?

######8 December
* Working on the comments query formatter.  Easiest to put all code into a user-defined MS SQL Server procedure and use Java to call the procedure.

###November
Finally back looking at the RIF code!  (Although still only part time) Focus is on the Java classes that are used to connect to MS SQL Server so the Data Loader will be able to work on SQL Server.
* We can connect from Java to a local MS SQL Server database using the rifGenericLibrary classes
* Testing individual SQL query formatters in rifGenericLibrary and writing extra MS SQL Server functions as needed


##2015

###November
Focus is still on testing (when there is time to work on the RIF).

######10 November
* (Finally) starting to work on porting Peter's super-complicated test harness code from pgsql to T-SQL.

######9 November
* Returning to the automated testing issue.  I compared what Peter has set up for Postgres with the existing SQL Server automated testing tools.  I don't see any SQLS Server tools that would not require explicitly hard-coding every test case, and we don't want that.

###October
Not much time spent on the RIF this month.  I started to set up the standard test harness to enable systematic testing and comparison with the Postgres build.

######21 October
* Creating new database objects necessary to run the test harness

###September
Mostly working on other projects.  I perfomed more testing of the table and view triggers, and I spent some time getting comfortable using Node.js.

######23-30 September
* Lots of struggles to get Node.js working on my computer with all the extra modules for connecting to the different databases.  Also playing around with basic Node scripts to understand how the technology works.

######21 September
* Quick edit to my script to convert Postgres data files into SQL Server data files to use | as the field delimiter, remove all double quotes (plus line breaks in multi-line comments).  This format works well with bulk import.
* More (informal/unstructured) testing of queries.

######18 September
* I finished writing a Perl script to convert data files with quotes around only a few fields + mult-line text in a single cell into something that can be loaded into SQL Server so I can continue loading test data into SQL Server

###August
I plan to finish the view triggers this month and start to test.

######21 August
* Continuing to insert data into tables
* New data loading issue: rif40_triggers.csv need to be preprocessed (comments field needs to have its line breaks removed, also need to remove double quotes/use a different delimiter more consistently)
* The test data for rif40_error_messages is Postgres codes, not the SQL Server custom error codes
* rif40_tables_and_views.csv file still not right format

######20 August
* Back to checking and revising trigger code.  Checked t_rif40_user_projects

######17-19 August
* More checks of the SQL Server database compared to Postgres.  
* Experimenting with clever ways to compare constraints on tables between SQL Server and Postgres.  Confirmed primary keys are on the same columns, foreign keys are between the same tables although I had problems getting column names out of Postgres (table owner issues)

######13 August
* Still importing data into SQL Server tables to test that the tables are set up correctly.  Trigger tests will require more systematic testing later.
* Tidying up and correcting triggers code as I test them and identify issues.  I went through rif40_geographies, t_rif40_geolevels triggers, rif40_tables.

######12 August
* Still setting up basic rif_data tables.  I put the population tables into rif_data instead of separate pop schema
* I updated some raw sahsuland/data files where the column definitions changed.  I also exported tables with data out from Postgres so I could model my SQL Server tests on those data.
* Problem with defining indexes on function-results (substring/truncate) in SQL Server and then problems with bulk inserts with computed columns.  The inelegant solution is to use a view that excludes computed columns.

######11 August
* Working on importing data in an automated way so I can be ready to do proper tests using Peter's test harness.
* Creating tables in the rif_data schema and importing test data.

######10 August
* Continuing view trigger work.  I finished rif40_study_areas, rif40_study_sql, rif40_study_sql, rif40_user_projects triggers.
* And that's it.  View triggers are completed.  (Wow, they were so much easier than table triggers.)  Now to figure out how to test everything sanely.
* Inserting test data from "rifDatabase/Postgres/sahsuland/data", trying to find clever ways to supply full path without hard-coding my setup

######8 August
* More work on view triggers.  I finished the rif40_inv_conditions, rif40_inv_coviarates, rif40_investigations, rif40_parameters, rif40_results, rif40_studies triggers.

######7 August
* Started on view triggers.  I finished the rif40_comparison_areas, rif40_contextual_stats, rif40_fdw_tables triggers.
* I fixed the typo in the t_rif40_contextual_stats table where "total_comparison_population" was spelled "total_comparisIon_population" and updated the view code.  (typo still in Postgres version so this may cause later confusion)

######3 August
* I finished the t_rif40_studies trigger!  All table triggers are now completed.  Next the view triggers.

######2 August
* Still not enjoying t_rif40_studies trigger code.  I wrote more of it, but then I decided I needed another break.  It is awful.

######1 August
* Defeated by the evilness of the t_rif40_studies trigger.  Must... get... this... done...

###July
I plan to finish the table trigger work that I began last month and begin to set up a proper test suite to verify that everything has been set up correctly.  Also continue work on simple batch installation scripts so I can easily re-create the latest version of the sahsuland_dev database.

######31 July
* Finished t_rif40_results, t_rif40_study_areas, t_rif40_study_sql, and t_rif40_study_sql_log triggers.  The only table trigger left is t_rif40_studies trigger.

######30 July
* Finished t_rif40_investigations trigger.  Next is t_rif40_results.  (Almost finished table triggers!)

######29 July
* Almost finished t_rif40_investigations trigger, but I got stuck in the last section.  I will plan to be more clever tomorrow.

######27 July
* Finished the t_rif40_inv_covariates trigger, although with a cursor + dynamic SQL, which will probably perform badly.  Started t_rif40_investigations trigger.

######24 July
* More work on t_rif40_inv_covariates trigger.  The end is in sight, but there is some tricky dynamic SQL to sort out (/try to find clever ways to avoid).

######23 July
* Finished t_rif40_geolevels, t_rif40_inv_conditions triggers
* Working on t_rif40_inv_covariates trigger. 

######22 July
* Finished rif40_table_outcomes, rif40_error_messages, rif40_geographies, t_rif40_contextual_stats triggers
* Worked on the more complex t_rif40_comparison_areas trigger.  The code is syntactically correct/accepted by the database, but I need to check it with test data to make certain it is doing the correct thing.

######21 July
* Wrote functions rif40_db_name_check and rif40_check_table_values necessary for rif40_tables trigger.  
* Finished rif40_tables trigger

######20 July
* Back to triggers.  Working on rif40_tables_trigger.

######16 July
* Adding more fields to the fake cancer dataset and inserting more typical errors.  Sent Kevin a copy for his thoughts.

######15 July
* Finishing up the fake cancer data.  Verifying with Kevin that it is what he wants before copying it over to Github.
* Making some actual progress on triggers.  Finished rif40_covariates_triggers.sql

######14 July
* Creating fake cancer data for Kevin to practice 'loading' and which can be aggregated to form the current sahsuland_cancer table (so we don't break existing test code).  Rather slow code since the table must be very large. 
* Back to triggers.  

######6 July
* Working on trigger for rif40_covariates (not finished), correcting/rewriting RH's original with more error handling and logging. 

######2 July
* Wrote batch strict to set up completed triggers (I did not install ones from RH that I have not gone through to verify and add logging/error handling)
* Finally returning to my work on the epic t_rif40_studies trigger.sql.  Then I lost heart and left it incomplete and worked on something smaller.

######1 July
* Working on the batch installation scripts to set up logging, error handling, and all the custom error messages.  Cleaning up the error handling code and related functions.
* As part of installation, check if custom error codes are already used by another program.  Currently checking if any custom errors exist -- should that be changed to only the specific error codes we are going to use?
* It is stupid that you cannot call a stored procedure from inside a function in SQL Server.  That breaks my logging, unless I manually insert rows into a log table (ick).

---
###June
The goal for this month is to complete all triggers (including logging and error handling) for the rif40 tables and views.  I got sidetracked into creating batch installation scripts due to a change in test servers, and so the triggers are still a work in progress.

######30 June
* Working on installation script for views, fixing up errors in the create table scripts.
* Something strange going on with rif40_num_denom_errors.sql: create view script fails if I add comments but runs fine if the view is created in one script and the comments are added in a separate script.  Needed a 'GO'.
* Still need to deal with setting up custom error messages, error handling functions, and logging.  Then I can return to triggers.

######29 June
* Still working on installation batch scripts to set up new sahsuland_dev database.  Views script caused tons of errors that I need to sort through.

######26 June
* A different Windows server has been found, and so the sahsuland_dev database must be entirely rebuilt.  
* Working on putting together installation scripts.

######18-25 June
* Many delays in getting the Windows test server fixed, so no code could be tested or further developed.
* Instead lots of time was spent discussing the Data Loader tool and related design decisions.

######17 June
* Working on laptop (no access to SQL Server) while I wait for the Windows test server with SQL Server to be rebuilt.
* Worked more on the trigger for t_rif40_studies, stopped at IG part

######15 June
* Problems with the Windows server running the SQL Server test system.  Still needs to be sorted.  
* Wrote more trigger code, but code could not be tested because of server problems.
* Some error messages need to be corrected (misspelled table name)

######12 June
* Slowly sorting out more of the t_rif40_studies_trigger code. 

######11 June
* More trigger work.  Still working on t_rif40_studies_trigger

######10 June
* Finished rif40_study_shares_trigger.  Tested it by inserting data into it and related tables, correcting table definitions and other code as I encounter errors.
* Onto next trigger: t_rif40_studies_trigger.sql, another complicated one.

######9 June
* Triggers: working on rif40_study_shares_trigger code, have not completed the delete part  

######8 June
* Set up basic logging function.  Messages are not saved at present, but the log procedure can be used in triggers.
* Updated error handling function to experiment with adding better logging.
* More work on triggers.  Went through rif40_user_projects, now incorporating error handling and logging.  Started on rif40_study_areas triggers.

######5 June
* Things finally are working for error handling, and I know more options for logging.  SQL Server does not have autonomous transactions for logging.  I will be careful with where to call rollbacks.
* Fixed rif40_version triggers to have the correct error handling.  

######4 June
* Looking more at T-SQL error handling in order to improve the error handling in the SQL Server trigger code.  RAISERROR code should be replaced with THROW code.  Rollbacking transactions is removing existing error handling logs. 
* Still trying to get proper logging in the simple rif40_version trigger, but I have not succeeded yet.

######3 June
* Still reviewing existing trigger code in both SQL Server and Postgres to understand how it works. 
* Looking at the differences between SQL Server and Postgres trigger code: no "before" triggers in SQL Server, must deal with all changed rows together without cursors in SQL Server whereas Postgres can process each row separately.
* Wrote some basic trigger-related code for rif40_version to get used to the SQL Server code.
* Custom error messages from RH need to be updated.  I wrote a procedure to remove old custom error messages.

######2 June
* Finished updating and commenting all tables and views.
* Experimented with running batch SQL on rif3 with "sqlcmd -d sahsuland_dev -i H:\SAHSU\rif_test.sql".
* Onto triggers.  Now focusing on understanding what is in Postgres and what RH completed to understand how much needs to be done.
* There are 65 triggers in Postgres.  RH implemented 15, but naming is inconsistent so it is not obvious which of the Postgres triggers have been implemented.  I suspect RH combined several Postgres triggers into one single trigger per table.  None of RH's triggers has been checked.

######1 June
* Still fixing up the tables and views to have the correct columns, data types, and comments as in the current Postgres version.
* Finished almost all the tables.  About half of the views have comments.

---
###May
This month is dedicated to completing scripts necessary to create all tables and views in the rif40 schema (+ the required functions and objects needed for the creation of tables and views). 

######29 May
* Working more on adding comments to all tables and views in rif40 schema + checking that the object definitions are still the same in Peter's Postgres database.
* Experimenting with how to identify, drop, disable foreign keys and constraints for rebuilding tables that have references to others in SQL Server
* There is no built-in function to get current value of a sequence in SQL Server (really?), so I had to write my own in order to easily set default column definitions to current value of sequences
* Study_id datatype has changed, and that is a field used in many foreign keys.  Messy.  Still working my way through all the tables that have wrong study_id type.  stopped at t_rif40_investigations
(select * FROM [sahsuland_dev].[INFORMATION_SCHEMA].[COLUMNS] where column_name='study_id' and data_type != 'int')
 
######28 May
* All views are now done!  Finished rif40_num_denom, corrected typos in rif40_numerator_outcome_columns, wrote rif40_num_denom_errors and rif40_parameters
* Completed draft functions needed for rif40_num_denom (no logging or good error handling): 
	rif40_object_resolve, rif40_num_denom_validate, rif40_auto_indirect_checks
* Reviewed how SQL Server deals with cursors.
* Started going through the tables to add comments, and I have found several tables that have been changed significantly since we began porting the database.  I need an easy way to compare all of Peter's tables/columns to mine in order to spot the differences.  Stopped commenting at rif40_outcomes

Still to do: logs/error handling, more comments

######27 May
* Continuing to work on new views: rif40_numerator_outcome_columns (done), rif40_num_denom (still in progress)
* All the functions needed for rif40_num_denom are rather complicated.  I put together a draft of rif_is_object_resolvable that will be refined once I sort out logging and error handling.
* Experimenting with customized error messages and how RH handled errors.  She added new customized error messages to the SQL Server master system tables.  There does not appear to be a way to have schema-level customized error messages.  Are system-wide customized error messages wise?  (what if other tools in db were already using those codes?)
* Looking into logging options.  Custom logging seems to be an SSIS thing, not standard T-SQL/SQL Server.  Take the easy approach of manually inserting rows into a rif40_log table?  But then database rollbacks would also rollback log of what went wrong.

To do: decide how to deal with logs and error messages to be consistent with what the middleware expects and what Peter produces in Postgres

######26 May
* Finished new views: rif40_inv_conditions, rif40_projects, rif40_studies.  Starting rif40_num_denom
* Discovered that table t_rif40_inv_conditions definition was out-of-date and required creation of sequence objects
* Experimented with comments in SQL Server.  I will need to spend a boring afternoon porting that code for all the existing rif40 objects.
	(ex. sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Username' , @level0type=N'SCHEMA',@level0name=N'rif40', @level1type=N'VIEW',@level1name=N'rif40_investigations', @level2type=N'COLUMN',@level2name=N'username'
		fn_listextendedproperty (NULL, 'schema', 'rif40', 'view', 'rif40_investigations', 'column', 'inv_id'))

Additional To do: add comments to tables and views in the extended properties fields
	
######21 May
* Finished adapting RH's old view code to my new database, but that is only 10 out of 19 views needed for the rif40 schema.  All her code is now integrated the sahsuland_dev new version.
* Added new views: rif40_user_version, rif40_geolevels (flagged question to discuss with Peter)

To do: write code for remaining views, trigger code for tables that had not been written, all trigger code for views 

######20 May
* Finally moved all my current code onto Github and reorganized Raunaque's old code so it can be out of the way while still accessible.
* Added remaining missing tables: rif40_columns, rif40_tables_and_views, rif40_triggers
* Started on adapting Raunaque's view code.  No view triggers have been written yet.
  - missing views (not ported by RH): rif40_geolevels, rif40_inv_conditions, rif40_num_denom, rif40_num_denom_errors, 
  rif40_numerator_outcome_columns, rif40_projects, rif40_studies, rif40_user_version
  
---
###April
I am working on creating a clean set of scripts to build the sahsuland_dev database on SQL Server, based on the work that Raunaque did last year and on the Postgres code from Peter.

All work I have done so far is on the rif40 schema.  Code is being tested on the internal rif3 server.

To do:
- 3 tables are missing: rif40_columns, rif40_tables_and_views, rif40_triggers
- Table triggers are missing on: rif40_predefined_groups, rif40_tables, t_rif40_comparison_areas, t_rif40_inv_conditions, t_rif40_study_sql_log, t_rif40_study_sql
- I have not started to work on the views and view triggers

Known issues: 
- Logging and error handling are inconsistent in the triggers.  
- The functionality of the existing triggers must be tested.  Raunaque left comments in some of the trigger code saying that she was not certain whether parts were correct.
