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
-- Rapid Enquiry Facility (RIF) - Setup EW01 into rif40_geographies, rif40_geolevels ready for setup by rif40_geo_pkg functions
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
\set ECHO all
\set ON_ERROR_STOP ON
\timing

--
-- Check user is rif40
--
DO LANGUAGE plpgsql $$
BEGIN
	IF user = 'rif40' THEN
		RAISE INFO 'User check: %', user;	
	ELSE
		RAISE EXCEPTION 'C20900: User check failed: % is not rif40', user;	
	END IF;
END;
$$;

--
-- Check database is sahsuland_dev
--
DO LANGUAGE plpgsql $$
BEGIN
	IF current_database() = 'sahsuland_dev' THEN
		RAISE INFO 'Database check: %', current_database();	
	ELSE
		RAISE EXCEPTION 'C20901: Database check failed: % is not sahsuland_dev', current_database();	
	END IF;
END;
$$;

--
-- RIF40_GEOGRAPHIES, T_RIF40_GEOLEVELS
--
UPDATE rif40_geographies 
   SET defaultcomparea = NULL
 WHERE geography = 'EW01';
DELETE FROM t_rif40_geolevels WHERE geography = 'EW01';
DELETE FROM rif40_geographies WHERE geography = 'EW01';

--
-- Postcode popualtion tables removed for SAHSULAND tests
--
INSERT INTO rif40_geographies (geography, description, hierarchytable, srid, partition, max_geojson_digits)
VALUES ('EW01', 'England and Wales 2001 (includes WARD2001)', 'EW2001_GEOGRAPHY', 27700, 1, 8);

INSERT INTO t_rif40_geolevels(geography, geolevel_name, geolevel_id, description, lookup_table, lookup_desc_column, centroidxcoordinate_column, centroidycoordinate_column, shapefile, centroidsfile, shapefile_table, shapefile_area_id_column, shapefile_desc_column, st_simplify_tolerance,  centroids_table, centroids_area_id_column, avg_npoints_geom, avg_npoints_opt, file_geojson_len, leg_geom, leg_opt, covariate_table, restricted, resolution, comparea, listing)
VALUES (
'EW01','OA2001',7,'2001 Census output areas (COA2001)','EW2001_COA2001','NAME',NULL,NULL,NULL,NULL,'X_EW01_COA2001','COA2001',NULL,10,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'EW01_COVARIATES_OA2001',1,0,1,0);
INSERT INTO t_rif40_geolevels(geography, geolevel_name, geolevel_id, description, lookup_table, lookup_desc_column, centroidxcoordinate_column, centroidycoordinate_column, shapefile, centroidsfile, shapefile_table, shapefile_area_id_column, shapefile_desc_column, st_simplify_tolerance,  centroids_table, centroids_area_id_column, avg_npoints_geom, avg_npoints_opt, file_geojson_len, leg_geom, leg_opt, covariate_table, restricted, resolution, comparea, listing)
VALUES (
'EW01','SOA2001',6,'2001 Super output areas - lower level (SOA2001)','EW2001_SOA2001','NAME',NULL,NULL,NULL,NULL,'X_EW01_SOA2001','SOA2001',NULL,20,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'EW01_COVARIATES_SOA2001',1,0,1,0);
INSERT INTO t_rif40_geolevels(geography, geolevel_name, geolevel_id, description, lookup_table, lookup_desc_column, centroidxcoordinate_column, centroidycoordinate_column, shapefile, centroidsfile, shapefile_table, shapefile_area_id_column, shapefile_desc_column, st_simplify_tolerance,  centroids_table, centroids_area_id_column, avg_npoints_geom, avg_npoints_opt, file_geojson_len, leg_geom, leg_opt, covariate_table, restricted, resolution, comparea, listing)
VALUES (
'EW01','WARD2001',5,'2001 Census statistical ward','EW2001_WARD2001','NAME','X_COORDINATE','Y_COORDINATE',NULL,NULL,'X_EW01_WARD2001','WARD2001','WARDNAME',30,'X_EW01_WARD2001_CENTROIDS',NULL,NULL,NULL,NULL,NULL,NULL,'EW01_COVARIATES_WARD2001',1,1,1,0);
INSERT INTO t_rif40_geolevels(geography, geolevel_name, geolevel_id, description, lookup_table, lookup_desc_column, centroidxcoordinate_column, centroidycoordinate_column, shapefile, centroidsfile, shapefile_table, shapefile_area_id_column, shapefile_desc_column, st_simplify_tolerance,  centroids_table, centroids_area_id_column, avg_npoints_geom, avg_npoints_opt, file_geojson_len, leg_geom, leg_opt, covariate_table, restricted, resolution, comparea, listing)
VALUES (
'EW01','LADUA2001',4,'2001 local area district/unitary authority','EW2001_LADUA2001','NAME',NULL,NULL,NULL,NULL,'X_EW01_LADUA2001','LADUA2001','LADUANAME',50,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'EW01_COVARIATES_LADUA2001',0,1,1,1);
INSERT INTO t_rif40_geolevels(geography, geolevel_name, geolevel_id, description, lookup_table, lookup_desc_column, centroidxcoordinate_column, centroidycoordinate_column, shapefile, centroidsfile, shapefile_table, shapefile_area_id_column, shapefile_desc_column, st_simplify_tolerance,  centroids_table, centroids_area_id_column, avg_npoints_geom, avg_npoints_opt, file_geojson_len, leg_geom, leg_opt, covariate_table, restricted, resolution, comparea, listing)
VALUES (
'EW01','GOR2001',3,'2001 Government office region','EW2001_GOR2001','NAME',NULL,NULL,NULL,NULL,'X_EW01_GOR2001','GOR2001','GORNAME',100,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,1,1,1);
INSERT INTO t_rif40_geolevels(geography, geolevel_name, geolevel_id, description, lookup_table, lookup_desc_column, centroidxcoordinate_column, centroidycoordinate_column, shapefile, centroidsfile, shapefile_table, shapefile_area_id_column, shapefile_desc_column, st_simplify_tolerance,  centroids_table, centroids_area_id_column, avg_npoints_geom, avg_npoints_opt, file_geojson_len, leg_geom, leg_opt, covariate_table, restricted, resolution, comparea, listing)
VALUES (
'EW01','CNTRY2001',2,'2001 country','EW2001_CNTRY2001','NAME',NULL,NULL,NULL,NULL,'X_EW01_CNTRY2001','CNTRY2001','NAME',100,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,1,1,1);
INSERT INTO t_rif40_geolevels(geography, geolevel_name, geolevel_id, description, lookup_table, lookup_desc_column, centroidxcoordinate_column, centroidycoordinate_column, shapefile, centroidsfile, shapefile_table, shapefile_area_id_column, shapefile_desc_column, st_simplify_tolerance,  centroids_table, centroids_area_id_column, avg_npoints_geom, avg_npoints_opt, file_geojson_len, leg_geom, leg_opt, covariate_table, restricted, resolution, comparea, listing)
VALUES (
'EW01','SCNTRY2001',1,'2001 super country','EW2001_SCNTRY2001','NAME',NULL,NULL,NULL,NULL,'X_EW01_SCNTRY2001','SCNTRY2001','NAME',100,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,1,1,1);

UPDATE rif40_geographies 
   SET defaultcomparea  = 'GOR2001',
       defaultstudyarea = 'WARD2001'
 WHERE geography = 'EW01';

--
-- Eof
