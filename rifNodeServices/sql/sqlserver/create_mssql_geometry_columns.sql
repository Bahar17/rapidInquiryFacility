-- ************************************************************************
--
-- Description:
--
-- Rapid Enquiry Facility (RIF) - Create geometry_columnns view for SQL Server spatial 
-- as required by QGIS. QGIS (2.14.7) still does not work properly
--
-- from shapefiles simplification
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
-- This script is autogenerated.
--
--
-- MS SQL Server specific parameters
--
-- Usage: sqlcmd -E -b -m-1 -e -r1 -i create_mssql_geomrtry_columns.sql
-- Connect flags if required: -U <username>/-E -S<myServerinstanceName>
--
-- You must set the current schema if you cannot write to the default schema!
-- You need create privilege for the various object and the bulkadmin role
--
-- USE <my database>;
--
SET QUOTED_IDENTIFIER ON;
BEGIN TRANSACTION;
GO

IF OBJECT_ID('geometry_columns', 'U') IS NOT NULL DROP TABLE geometry_columns;
GO

CREATE TABLE geometry_columns (
        f_table_catalog 	VARCHAR(128) 	NOT NULL,
        f_table_schema 		VARCHAR(128) 	NOT NULL,
        f_table_name 		VARCHAR(256) 	NOT NULL,
        f_geometry_column 	VARCHAR(256) 	NOT NULL,
        coord_dimension 	INTEGER 		NOT NULL,
        srid 				INTEGER 		NOT NULL,
        geometry_type 		VARCHAR(30) 	NOT NULL,
		CONSTRAINT [geometry_columns_pk] PRIMARY KEY CLUSTERED (
        f_table_catalog ASC,
        f_table_schema ASC,
        f_table_name ASC,
        f_geometry_column ASC)
);
GO

INSERT INTO geometry_columns
SELECT DISTINCT c.table_catalog,
       c.table_schema AS table_schema,
       c.table_name AS table_name,
       c.column_name AS column_name,
       2 AS coord_dimension,
       4326 AS srid,
      'nu' AS geometry_type
  FROM information_schema.columns c
	JOIN information_schema.tables t ON (c.table_name = t.table_name AND t.table_type IN ('BASE TABLE','VIEW'))
 WHERE c.data_type = 'geometry'
 ORDER BY c.table_schema, c.table_name; 
GO

DECLARE @l_table_schema NVARCHAR(100);
DECLARE @l_table_name NVARCHAR(100);
DECLARE @l_column_name NVARCHAR(100);
DECLARE @run_sql NVARCHAR(max);
DECLARE @run_update NVARCHAR(max);
DECLARE @Selected_geometry_dimension INTEGER;
DECLARE @Selected_geometry_type NVARCHAR(100);
DECLARE @Selected_geometry_srid INTEGER;
DECLARE @table_geometry_dimension INTEGER;
DECLARE @table_geometry_type NVARCHAR(100);
DECLARE @table_geometry_srid INTEGER;
DECLARE @crlf VARCHAR(2)=CHAR(10)+CHAR(13);

DECLARE c1 CURSOR FOR SELECT f_table_schema, f_table_name, f_geometry_column FROM geometry_columns;
OPEN c1   
FETCH NEXT FROM c1 INTO @l_table_schema, @l_table_name, @l_column_name;

WHILE @@FETCH_STATUS = 0  
BEGIN
	SET @run_sql = 'SELECT TOP 1 ' + @crlf +
           '       @table_geometry_dimension= ' + @l_column_name + '.STDimension(),' + @crlf +
           '       @table_geometry_type=' + @l_column_name + '.STGeometryType(),' + @crlf +
           '       @table_geometry_srid= ' + @l_column_name + '.STSrid' + @crlf +
           '  FROM ' + @l_table_schema + '.' + @l_table_name; 
	EXECUTE sp_executesql @run_sql
        ,N'@table_geometry_dimension INTEGER OUTPUT, @table_geometry_type nvarchar(100) OUTPUT, @table_geometry_srid INTEGER OUTPUT'
        ,@table_geometry_dimension = @Selected_geometry_dimension OUTPUT
        ,@table_geometry_type = @Selected_geometry_type OUTPUT
        ,@table_geometry_srid = @Selected_geometry_srid OUTPUT
	PRINT 'SQL> ' + @run_sql;
	PRINT 'Type=' + @Selected_geometry_type;
	PRINT 'SRID=' + CAST(@Selected_geometry_srid AS VARCHAR);
	PRINT 'Dimension=' + CAST(@Selected_geometry_dimension AS VARCHAR);
--
	UPDATE geometry_columns
	   SET coord_dimension = @Selected_geometry_dimension,
           srid 		   = @Selected_geometry_srid,
		   geometry_type   = @Selected_geometry_type
		WHERE CURRENT OF c1; 
--
	FETCH NEXT FROM c1 INTO @l_table_schema, @l_table_name, @l_column_name;
END;
CLOSE c1;
DEALLOCATE c1;
GO

SELECT * FROM geometry_columns;
GO
 
COMMIT;
GO