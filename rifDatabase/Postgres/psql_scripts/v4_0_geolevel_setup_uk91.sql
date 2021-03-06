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
-- Rapid Enquiry Facility (RIF) - Setup UK91 into rif40_geographies, rif40_geolevels ready for setup by rif40_geo_pkg functions
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
 WHERE geography = 'UK91';
DELETE FROM t_rif40_geolevels WHERE geography = 'UK91';
DELETE FROM rif40_geographies WHERE geography = 'UK91';

--
-- Postcode popualtion tables removed for SAHSULAND tests
--
INSERT INTO rif40_geographies (geography, description, hierarchytable, srid, partition, max_geojson_digits)
VALUES ('UK91', 'England and Wales 1991', 'UK91_GEOGRAPHY', 27700, 1, 8);

INSERT INTO t_rif40_geolevels(geography, geolevel_name, geolevel_id, description, lookup_table, lookup_desc_column, centroidxcoordinate_column, centroidycoordinate_column, shapefile, centroidsfile, shapefile_table, shapefile_area_id_column, shapefile_desc_column, st_simplify_tolerance,  centroids_table, centroids_area_id_column, avg_npoints_geom, avg_npoints_opt, file_geojson_len, leg_geom, leg_opt, covariate_table, restricted, resolution, comparea, listing)
VALUES (
'UK91','ED91',7,'Enumeration districts 1991','UK91_ED91','NAME','X_COORDINATE','Y_COORDINATE',NULL,NULL,'X_UK91_ED91','ED91',NULL,10,'X_UK91_CEN_ED91',NULL,NULL,NULL,NULL,NULL,NULL,'UK91_COVARIATES_ED91',1,0,1,0);
INSERT INTO t_rif40_geolevels(geography, geolevel_name, geolevel_id, description, lookup_table, lookup_desc_column, centroidxcoordinate_column, centroidycoordinate_column, shapefile, centroidsfile, shapefile_table, shapefile_area_id_column, shapefile_desc_column, st_simplify_tolerance,  centroids_table, centroids_area_id_column, avg_npoints_geom, avg_npoints_opt, file_geojson_len, leg_geom, leg_opt, covariate_table, restricted, resolution, comparea, listing)
VALUES (
'UK91','WARD91',6,'Wards 1991','UK91_WARD91','NAME',NULL,NULL,NULL,NULL,'X_UK91_WARD91','WARD91','WARD91_NAM',30,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UK91_COVARIATES_WARD91',1,1,1,0);
INSERT INTO t_rif40_geolevels(geography, geolevel_name, geolevel_id, description, lookup_table, lookup_desc_column, centroidxcoordinate_column, centroidycoordinate_column, shapefile, centroidsfile, shapefile_table, shapefile_area_id_column, shapefile_desc_column, st_simplify_tolerance,  centroids_table, centroids_area_id_column, avg_npoints_geom, avg_npoints_opt, file_geojson_len, leg_geom, leg_opt, covariate_table, restricted, resolution, comparea, listing)
VALUES (
'UK91','DISTRICT91',5,'Districts 1991','UK91_DISTRICT91','NAME',NULL,NULL,NULL,NULL,'X_UK91_DISTRICT91','DISTRICT91','NAME',50,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,1,1,1);
INSERT INTO t_rif40_geolevels(geography, geolevel_name, geolevel_id, description, lookup_table, lookup_desc_column, centroidxcoordinate_column, centroidycoordinate_column, shapefile, centroidsfile, shapefile_table, shapefile_area_id_column, shapefile_desc_column, st_simplify_tolerance,  centroids_table, centroids_area_id_column, avg_npoints_geom, avg_npoints_opt, file_geojson_len, leg_geom, leg_opt, covariate_table, restricted, resolution, comparea, listing)
VALUES (
'UK91','COUNTY91',4,'Counties 1991','UK91_COUNTY91','NAME',NULL,NULL,NULL,NULL,'X_UK91_COUNTY91','COUNTY91','NAME',100,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,1,1,1);
INSERT INTO t_rif40_geolevels(geography, geolevel_name, geolevel_id, description, lookup_table, lookup_desc_column, centroidxcoordinate_column, centroidycoordinate_column, shapefile, centroidsfile, shapefile_table, shapefile_area_id_column, shapefile_desc_column, st_simplify_tolerance,  centroids_table, centroids_area_id_column, avg_npoints_geom, avg_npoints_opt, file_geojson_len, leg_geom, leg_opt, covariate_table, restricted, resolution, comparea, listing)
VALUES (
'UK91','REGION91',3,'Regions 1991','UK91_REGION91','NAME',NULL,NULL,NULL,NULL,'X_UK91_REGION91','REGION91','REGION_NAM',100,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,1,1,1);
INSERT INTO t_rif40_geolevels(geography, geolevel_name, geolevel_id, description, lookup_table, lookup_desc_column, centroidxcoordinate_column, centroidycoordinate_column, shapefile, centroidsfile, shapefile_table, shapefile_area_id_column, shapefile_desc_column, st_simplify_tolerance,  centroids_table, centroids_area_id_column, avg_npoints_geom, avg_npoints_opt, file_geojson_len, leg_geom, leg_opt, covariate_table, restricted, resolution, comparea, listing)
VALUES (
'UK91','COUNTRY91',2,'Countries 1991','UK91_COUNTRY91','NAME',NULL,NULL,NULL,NULL,'X_UK91_COUNTRY91','COUNTRY91','COUNTRY_NA',100,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,1,1,1);
INSERT INTO t_rif40_geolevels(geography, geolevel_name, geolevel_id, description, lookup_table, lookup_desc_column, centroidxcoordinate_column, centroidycoordinate_column, shapefile, centroidsfile, shapefile_table, shapefile_area_id_column, shapefile_desc_column, st_simplify_tolerance,  centroids_table, centroids_area_id_column, avg_npoints_geom, avg_npoints_opt, file_geojson_len, leg_geom, leg_opt, covariate_table, restricted, resolution, comparea, listing)
VALUES (
'UK91','SCOUNTRY91',1,'Super countries 1991','UK91_SCOUNTRY91','NAME',NULL,NULL,NULL,NULL,'X_UK91_SCOUNTRY91','SCOUNTRY91','NAME',100,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,1,1,1);

UPDATE rif40_geographies 
   SET defaultcomparea  = 'REGION91',
       defaultstudyarea = 'WARD91'
 WHERE geography = 'UK91';

--
-- Eof
