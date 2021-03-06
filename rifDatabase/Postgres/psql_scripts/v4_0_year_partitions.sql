-- *************************************************************************************************
--
-- CVS/RCS Header
--
-- $Author: peterh $
-- $Date: 2014/02/27 11:29:40 $
-- Type: Postgres PSQL script
-- $RCSfile: v4_0_year_partitions.sql,v $
-- $Source: /home/EPH/CVS/repository/SAHSU/projects/rif/V4.0/database/postgres/psql_scripts/v4_0_year_partitions.sql,v $
-- $Revision: 1.2 $
-- $Id$
-- $State: Exp $
-- $Locker:  $
--
-- Description:
--
-- Rapid Enquiry Facility (RIF) - Partition all tables with study_id as a column
--
-- Copyright:
--
-- The RIF is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation; either version 2, or (at your option) any later
-- version.
--
-- The RIF is distributed in the hope that it will be useful, but WITHOUT ANY
-- WARRANTY; without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this file; see the file LICENCE.  If not, write to:
--
-- UK Small Area Health Statistics Unit,
-- Dept. of Epidemiology and Biostatistics
-- Imperial College School of Medicine (St. Mary's Campus),
-- Norfolk Place,
-- Paddington,
-- London, W2 1PG
-- United Kingdom
--
-- The RIF uses Oracle 11g, PL/SQL, PostGres and PostGIS as part of its implementation.
--
-- Oracle11g, PL/SQL and Pro*C are trademarks of the Oracle Corporation.
--
-- All terms mentioned in this software and supporting documentation that are known to be trademarks
-- or service marks have been appropriately capitalised. Imperial College cannot attest to the accuracy
-- of this information. The use of a term in this software or supporting documentation should NOT be
-- regarded as affecting the validity of any trademark or service mark.
--
-- Summary of functions/procedures:
--
-- To be added
--
-- Error handling strategy:
--
-- Output and logging procedures do not HANDLE or PROPAGATE errors. This makes them safe to use
-- in package initialisation and NON recursive.
--
-- References:
--
-- 	None
--
-- Dependencies:
--
--	Packages: None
--
-- 	<This should include: packages, non packages procedures and functions, tables, views, objects>
--
-- Portability:
--
--	Linux, Windows 2003/2008, Oracle 11gR1
--
-- Limitations:
--
-- Change log:
--
-- $Log: v4_0_year_partitions.sql,v $
-- Revision 1.2  2014/02/27 11:29:40  peterh
--
-- About to test isolated code tree for trasnfer to Github/public network
--
-- Revision 1.1  2014/02/14 17:18:41  peterh
--
-- Clean build. Issue with ST_simplify(), intersection code and UK geography (to be resolved)
-- Fully commented (and check now works)
--
-- Stubs for range/hash partitioning added
--
-- Revision 1.1  2013/03/14 17:35:39  peterh
-- Baseline for TX to laptop
--
--
\set ECHO all
\set ON_ERROR_STOP ON
\timing

\echo Range partition all tables with study_id as a column...
--
-- Check user is rif40
--
--\set ON_ERROR_STOP OFF
\set VERBOSITY terse
--\set VERBOSITY verbose
DO LANGUAGE plpgsql $$
DECLARE
--
	rif40_sql_pkg_functions 	VARCHAR[] := ARRAY['rif40_range_partition',
							'_rif40_range_partition_create',
							'_rif40_common_partition_create',
							'_rif40_common_partition_create_setup',
							'_rif40_range_partition_create_insert',
							'_rif40_common_partition_create_complete',
							'rif40_method4',
							'rif40_ddl'];
	l_function 			VARCHAR;
--
	c1 CURSOR FOR
		WITH d AS (
			SELECT ARRAY_AGG(a.tablename) AS table_list
			  FROM pg_tables a, pg_attribute b, pg_class c
	 		 WHERE c.oid        = b.attrelid
			   AND c.relname    = a.tablename
  		       AND c.relkind    = 'r' /* Relational table */
		       AND c.relpersistence IN ('p', 'u') /* Persistence: permanent/unlogged */ 
		       AND b.attname    = 'study_id'
		       AND a.schemaname = 'rif40'	
		)	
		SELECT a.tablename AS tablename, b.attname AS columnname, schemaname AS schemaname	/* Tables */, 
		       d.table_list	/* Tables */, c.relhassubclass
		  FROM pg_tables a, pg_attribute b, pg_class c, d
		 WHERE c.oid        = b.attrelid
		   AND c.relname    = a.tablename
		   AND c.relkind    = 'r' /* Relational table */
		   AND c.relpersistence IN ('p', 'u') /* Persistence: permanent/unlogged */ 
		   AND b.attname    = 'year'
		   AND a.schemaname = 'rif_data'
		 ORDER BY 1;
--
	c1_rec RECORD;
--
	sql_stmt VARCHAR[];
BEGIN
--
-- Check user is rif40
--
	IF user = 'rif40' THEN
		RAISE INFO 'v4_0_year_partitions.sql: User check: %', user;	
	ELSE
		RAISE EXCEPTION 'v4_0_year_partitions.sql: C209xx: User check failed: % is not rif40', user;	
	END IF;

--
-- Turn on some debug
--
	PERFORM rif40_log_pkg.rif40_log_setup();
	PERFORM rif40_log_pkg.rif40_send_debug_to_info(TRUE);
--
-- Enabled debug on select rif40_sm_pkg functions
--
	FOREACH l_function IN ARRAY rif40_sql_pkg_functions LOOP
		RAISE INFO 'Enable debug for function: %', l_function;
		PERFORM rif40_log_pkg.rif40_add_to_debug(l_function||':DEBUG1');
	END LOOP;
--
	FOR c1_rec IN c1 LOOP
--
-- Check if partitioned already
--
		IF c1_rec.relhassubclass THEN
			RAISE NOTICE 'v4_0_year_partitions.sql: Table %.% is already partitioned', 
				c1_rec.schemaname::VARCHAR, c1_rec.tablename::VARCHAR;
		ELSE
			PERFORM rif40_sql_pkg.rif40_range_partition(c1_rec.schemaname::VARCHAR, c1_rec.tablename::VARCHAR, 'year'::VARCHAR, 
				c1_rec.table_list::VARCHAR[]);
		END IF;		
	END LOOP;
--	RAISE EXCEPTION 'v4_0_year_partitions.sql: Stop';
END;
$$;

\echo Range partitioning of all tables with year as a column complete.
--
-- Eof
