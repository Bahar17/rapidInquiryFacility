/*
 * SQL statement name: 	add_geometry_column.sql
 * Type:				Microsoft SQL Server T/sql anonymous block
 * Parameters:
 *						1: Table name; e.g. cb_2014_us_county_500k
 *						2: column name; e.g. geographic_centroid
 *						3: Column SRID; e.g. 4326
 *						4: Spatial geometry type: e.g. POINT, MULTIPOLYGON
 *
 * Description:			Add *** geography ***  column to table
 * Note:				%%%% becomes %% after substitution
 *
 * May need to be swapped to geometry to be the same datatype as PostGIS (see: add_geometry_column2.sql):
 * ALTER TABLE %1 ADD %2 geometry
 */
ALTER TABLE %1 ADD %2 geography