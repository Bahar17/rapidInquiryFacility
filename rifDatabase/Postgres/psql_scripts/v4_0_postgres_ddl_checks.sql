-- ************************************************************************
-- *
-- * DO NOT EDIT THIS SCRIPT OR MODIFY THE RIF SCHEMA - USE ALTER SCRIPTS
-- *
-- ************************************************************************
--
-- ************************************************************************
--
-- GIT Header
--
-- $Format:Git ID: (%h) %ci$
-- $Id$
-- Version hash: $Format:%H$
--
-- Description:
--
-- Rapid Enquiry Facility (RIF) - Check all tables, triggers, columns and comments are present, 
--				  objects granted to rif_user/rif_manmger, sequences granted.
--
-- Copyright:
--
-- The Rapid Inquiry Facility (RIF) is an automated tool devised by SAHSU 
-- that rapidly addresses epidemiological and public health questions using 
-- routinely collected health and population data and generates standardised 
-- rates and relative risks for any given health outcome, for specified age 
-- and year ranges, for any given geographical area.
--
-- Copyright 2014 Imperial College London, developed by the Small Area
-- Health Statistics Unit. The work of the Small Area Health Statistics Unit 
-- is funded by the Public Health England as part of the MRC-PHE Centre for 
-- Environment and Health. Funding for this project has also been received 
-- from the Centers for Disease Control and Prevention.  
--
-- This file is part of the Rapid Inquiry Facility (RIF) project.
-- RIF is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- RIF is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with RIF. If not, see <http://www.gnu.org/licenses/>; or write 
-- to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, 
-- Boston, MA 02110-1301 USA
--
-- Author:
--
-- Peter Hambly, SAHSU
--
\set ECHO :echo
\set ON_ERROR_STOP ON
\set VERBOSITY :verbosity

--
-- Check user is rif40
--
DO LANGUAGE plpgsql $$
BEGIN
	IF user = 'rif40' THEN
		RAISE INFO 'v4_0_postgres_ddl_checks.sql: DDL01: User check: %', user;	
	ELSE
		RAISE EXCEPTION 'v4_0_postgres_ddl_checks.sql: DDL02: User check failed: % is not rif40', user;	
	END IF;
END;
$$;

--
-- Check database is sahsuland, sahsuland_dev or sahsuland_empty
--
DO LANGUAGE plpgsql $$
BEGIN
	IF current_database() IN ('sahsuland', 'sahsuland_dev', 'sahsuland_empty') THEN
		RAISE INFO 'v4_0_postgres_ddl_checks.sql: DDL03: Database check: %', current_database();	
	ELSE
		RAISE EXCEPTION 'v4_0_postgres_ddl_checks.sql: DDL04: Database check failed: % is not sahsuland/sahsuland_dev/sahsuland_empty', current_database();	
	END IF;
END;
$$;

\echo Checking all tables, triggers, columns and comments are present, objects granted to rif_user/rif_manmger, sequences granted...

DO LANGUAGE plpgsql $$
BEGIN
        PERFORM rif40_log_pkg.rif40_send_debug_to_info(TRUE);
        PERFORM rif40_sql_pkg.rif40_ddl_checks();
EXCEPTION
	WHEN others THEN NULL; /* Ignore errors */
END;
$$;

\echo Checked all tables, triggers, columns and comments are present, objects granted to rif_user/rif_manmger, sequences granted.

--
-- Eof
