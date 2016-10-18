/*
 * SQL statement name: 	create_geometry_table.sql
 * Type:				Common SQL statement
 * Parameters:
 *						1: table; e.g. geometry_cb_2014_us_500k
 *
 * Description:			Create geometry table
 * Note:				%% becomes % after substitution
 */
CREATE TABLE %1 (
	geolevel_id		INTEGER		NOT NULL,
	areaid			VARCHAR		NOT NULL,
	zoomlevel		INTEGER		NOT NULL)