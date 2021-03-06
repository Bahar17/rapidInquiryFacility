package rifDataLoaderTool.dataStorageLayer.ms;

import rifDataLoaderTool.businessConceptLayer.DataLoaderToolSettings;
import rifDataLoaderTool.businessConceptLayer.DatabaseConnectionsConfiguration;
import rifGenericLibrary.system.RIFServiceException;
import rifGenericLibrary.dataStorageLayer.SQLGeneralQueryFormatter;
import rifGenericLibrary.dataStorageLayer.ms.MSSQLCreateDatabaseQueryFormatter;
import rifGenericLibrary.dataStorageLayer.ms.MSSQLDropDatabaseQueryFormatter;
import rifGenericLibrary.dataStorageLayer.ms.MSSQLQueryUtility;
import rifGenericLibrary.system.RIFServiceExceptionFactory;

import java.io.*;
import java.sql.*;
import java.util.Properties;
import java.util.Scanner;
import java.util.ArrayList;

/**
 * This is a mostly undeveloped class. Its intent was to help RIF managers
 * initially create the database that the Data Loader Tool will use to 
 * transform data.
 * 
 * <p>
 * I originally wanted to just read in a text file and execute it through a
 * single PostgreSQL call. But I ran into trouble with this.  Functions
 * like <code>addBasicCleaningProcedures()</code> where functionality is 
 * specified through concatenated strings - well there MUST be a better 
 * alternative to this and we need to look at it more.
 * </p>
 *
 * <hr>
 * Copyright 2017 Imperial College London, developed by the Small Area
 * Health Statistics Unit. 
 *
 * <pre> 
 * This file is part of the Rapid Inquiry Facility (RIF) project.
 * RIF is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * RIF is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with RIF.  If not, see <http://www.gnu.org/licenses/>.
 * </pre>
 *
 * <hr>
 * Kevin Garwood
 * @author kgarwood
 */

/*
 * Code Road Map:
 * --------------
 * Code is organised into the following sections.  Wherever possible, 
 * methods are classified based on an order of precedence described in 
 * parentheses (..).  For example, if you're trying to find a method 
 * 'getName(...)' that is both an interface method and an accessor 
 * method, the order tells you it should appear under interface.
 * 
 * Order of 
 * Precedence     Section
 * ==========     ======
 * (1)            Section Constants
 * (2)            Section Properties
 * (3)            Section Construction
 * (7)            Section Accessors and Mutators
 * (6)            Section Errors and Validation
 * (5)            Section Interfaces
 * (4)            Section Override
 *
 */

public class MSSQLDatabaseSetupUtility {

	// ==========================================
	// Section Constants
	// ==========================================

	// ==========================================
	// Section Properties
	// ==========================================
	private DatabaseConnectionsConfiguration dbParameters;
	
	// ==========================================
	// Section Construction
	// ==========================================

	public MSSQLDatabaseSetupUtility() {

	}

	// ==========================================
	// Section Accessors and Mutators
	// ==========================================
	public void initialiseDB(
		final DataLoaderToolSettings dataLoaderToolSettings,
		final File initialisationScriptFile,
		final String userID,
		final String password) {
		
		try {
			
			dbParameters 
				= dataLoaderToolSettings.getDatabaseConnectionParameters();
			createDatabase(userID, password);				
			
			addFunctionsToDatabase(userID, password);
			
			
			//Contains all the functions needed to make the database
			//feaures work
			String[] sqlQueries
				= readDBInitialisationScript(initialisationScriptFile);
		
		}
		catch(Exception exception) {
			exception.printStackTrace(System.out);
		}
	}
	
	private void createDatabase(
		final String userID,
		final String password) 
		throws Exception {
		
		PreparedStatement dropDatabaseStatement = null;
		PreparedStatement createDatabaseStatement = null;
		Connection connection = null;
		try {
			connection 
				= createConnection(
					dbParameters.getDatabaseServerURL(),
					userID, 
					password);
			
			if (dataLoaderToolDatabaseExists(connection) == true) {
				System.out.println("Database already exists");
				return;
			}
			else {
				System.out.println("Database does not exist yet");
			}
			
			MSSQLDropDatabaseQueryFormatter dropDatabaseQueryFormatter
				= new MSSQLDropDatabaseQueryFormatter(false);
			dropDatabaseQueryFormatter.setDatabaseName(dbParameters.getDatabaseName());
			System.out.println(dropDatabaseQueryFormatter.generateQuery());
			dropDatabaseStatement 
				= connection.prepareStatement(
					dropDatabaseQueryFormatter.generateQuery());
			dropDatabaseStatement.executeUpdate();

			MSSQLCreateDatabaseQueryFormatter createDatabaseQueryFormatter
				= new MSSQLCreateDatabaseQueryFormatter(false);
			createDatabaseQueryFormatter.setDatabaseName(dbParameters.getDatabaseName());
			System.out.println(createDatabaseQueryFormatter.generateQuery());
			createDatabaseStatement
				= connection.prepareStatement(
					createDatabaseQueryFormatter.generateQuery());
			createDatabaseStatement.executeUpdate();	
		}
		finally {
			MSSQLQueryUtility.close(createDatabaseStatement);
			MSSQLQueryUtility.close(dropDatabaseStatement);
			MSSQLQueryUtility.close(connection);
		}
	}
	

	
	private void addFunctionsToDatabase(
		final String userID, 
		final String password) 
		throws RIFServiceException {
	
		Connection connection = null;
		try {
			connection 
				= createConnection(
					dbParameters.getDatabaseURL(),
					userID, 
					password);
			
			createDataLoaderSystemTables(connection);
			addBasicCleaningProcedures(connection);
		}
		catch(Exception exception) {
			RIFServiceExceptionFactory rifServiceExceptionFactory
				= new RIFServiceExceptionFactory();
			throw 
				rifServiceExceptionFactory.createFileReadingProblemException(
					dbParameters.getDatabaseName());
		}
		finally {
			
		}
		
	}
	
	
	private void createDataLoaderSystemTables(
		final Connection connection) 
		throws SQLException, RIFServiceException {
		
		PreparedStatement statement = null;
		try {
			
			/*
			 * #POSSIBLE_PORTING_ISSUE
			 * There may be issues with porting PostgreSQL's use of 
			 * CREATE SEQUENCE and nextval(...) to SQL Server.
			 */
			StringBuilder creationScriptQueries = new StringBuilder();
			creationScriptQueries.append("");
			creationScriptQueries.append("DROP TABLE IF EXISTS data_set_configurations CASCADE; ");
			creationScriptQueries.append("CREATE TABLE data_set_configurations ( ");
			creationScriptQueries.append("	core_data_set_name VARCHAR(50) NOT NULL, ");
			creationScriptQueries.append("	version VARCHAR(30) NOT NULL, ");
			creationScriptQueries.append("	creation_date DATE NOT NULL DEFAULT CURRENT_DATE, ");
			creationScriptQueries.append("	current_workflow_state VARCHAR(20) NOT NULL DEFAULT 'start'); ");
			creationScriptQueries.append("");
			creationScriptQueries.append("DROP SEQUENCE IF EXISTS data_set_sequence; ");
			creationScriptQueries.append("CREATE SEQUENCE data_set_sequence; ");
			creationScriptQueries.append("ALTER TABLE data_set_configurations ADD COLUMN id INTEGER NOT NULL ");
			creationScriptQueries.append("DEFAULT nextval('data_set_sequence'); ");
			creationScriptQueries.append("");
			creationScriptQueries.append("");
			creationScriptQueries.append("");
			creationScriptQueries.append("DROP TABLE IF EXISTS rif_change_log; ");
			creationScriptQueries.append("CREATE TABLE rif_change_log ( ");
			creationScriptQueries.append("	data_set_id INT NOT NULL, ");
			creationScriptQueries.append("	row_number INT NOT NULL, ");
			creationScriptQueries.append("	field_name VARCHAR(30) NOT NULL, ");
			creationScriptQueries.append("	old_value VARCHAR(30) NOT NULL, ");
			creationScriptQueries.append("	new_value VARCHAR(30) NOT NULL, ");
			creationScriptQueries.append("	time_stamp DATE NOT NULL DEFAULT CURRENT_DATE); ");
			creationScriptQueries.append("");
			creationScriptQueries.append("DROP TABLE IF EXISTS rif_failed_val_log; ");
			creationScriptQueries.append("CREATE TABLE rif_failed_val_log ( ");
			creationScriptQueries.append("	data_set_id INT NOT NULL, ");
			creationScriptQueries.append("	row_number INT NOT NULL, ");
			creationScriptQueries.append("	field_name VARCHAR(30) NOT NULL, ");
			creationScriptQueries.append("	invalid_value VARCHAR(30) NOT NULL, ");
			creationScriptQueries.append("	time_stamp DATE NOT NULL DEFAULT CURRENT_DATE); ");
			statement 
				= connection.prepareStatement(creationScriptQueries.toString());
			statement.executeUpdate();
		}
		finally {
			MSSQLQueryUtility.close(statement);			
		}		
	}
	
	private void addBasicCleaningProcedures(
		final Connection connection) 
		throws SQLException, RIFServiceException {
		
		
		PreparedStatement statement = null;
		try {
			StringBuilder buffer = new StringBuilder();
			buffer.append("CREATE OR REPLACE FUNCTION is_numeric(text) ");
			buffer.append("	RETURNS BOOLEAN AS ' ");
			buffer.append("");
			buffer.append("	SELECT $1 ~ ''^[0-9]+$'' ");
			buffer.append("' LANGUAGE 'sql'; ");
			buffer.append("");
			buffer.append("CREATE OR REPLACE FUNCTION clean_icd( ");
			buffer.append("	original_icd_code TEXT) ");
			buffer.append("	RETURNS TEXT AS ");
			buffer.append("$$ ");
			buffer.append("DECLARE ");
			buffer.append("	cleaned_icd_code TEXT; ");
			buffer.append("BEGIN ");
			buffer.append("	cleaned_icd_code := REPLACE(original_icd_code, '.', ''); ");
			buffer.append("	RETURN cleaned_icd_code; ");
			buffer.append("END; ");
			buffer.append("$$   LANGUAGE plpgsql;");
			buffer.append("");
			buffer.append("");
			buffer.append("COMMENT ON FUNCTION clean_icd(original_icd_code TEXT) IS 'Cleans ICD10 Codes';");
			buffer.append("");
			buffer.append("");
			buffer.append("");
			buffer.append("");
			buffer.append("");
			buffer.append("");
			buffer.append("");
			buffer.append("");
			buffer.append("");
			buffer.append("CREATE OR REPLACE FUNCTION clean_year( ");
			buffer.append("	year_value TEXT) ");
			buffer.append("	RETURNS TEXT AS ");
			buffer.append("$$ ");
			buffer.append("DECLARE");
			buffer.append("	result TEXT;");
			buffer.append("BEGIN");
			buffer.append("	IF length(year_value) = 2 THEN ");
			buffer.append("    SELECT to_char(to_date(year_value, 'YY'), 'YYYY') INTO result;");
			buffer.append(" ELSE");
			buffer.append("    result := year_value;");
			buffer.append(" END IF;");
			buffer.append("RETURN result;");
			buffer.append("END;");
			buffer.append("$$   LANGUAGE plpgsql;");
			buffer.append("");
			statement 
				= connection.prepareStatement(buffer.toString());
			statement.executeUpdate();
		}
		finally {
			MSSQLQueryUtility.close(statement);			
		}				
	}
	
	private boolean dataLoaderToolDatabaseExists(final Connection connection) 
		throws Exception {
		
		PreparedStatement statement = null;
		SQLGeneralQueryFormatter queryFormatter = new SQLGeneralQueryFormatter();
		ResultSet resultSet = null;
		try {
			queryFormatter.addQueryLine(0, "SELECT");
			queryFormatter.addQueryLine(1, "datname");
			queryFormatter.addQueryLine(0, "FROM");
			queryFormatter.addQueryLine(1, "pg_catalog.pg_database");
			queryFormatter.addQueryLine(0, "WHERE");
			queryFormatter.addQueryLine(1, "lower(datname) = lower(?)");

			System.out.println("========");
			System.out.println(queryFormatter.generateQuery());
			System.out.println("========");
			
			statement 
				= connection.prepareStatement(queryFormatter.generateQuery());
			statement.setString(1, dbParameters.getDatabaseName());
			System.out.println("TestDBInit 1");
			resultSet = statement.executeQuery();
			System.out.println("TestDBInit 2");
	
			if (resultSet.next()) {
				System.out.println("result=="+resultSet.getString(1)+"==");
				return true;
			}
			else {
				return false;
			}			
		}
		finally {
			MSSQLQueryUtility.close(statement);
		}
	}
	
	
	private String[] readDBInitialisationScript(
		final File dbInitialisationScriptFile) 
		throws RIFServiceException {
		
		Scanner scanner = null;
		try {
			scanner = new Scanner(dbInitialisationScriptFile).useDelimiter(";");
			ArrayList<String> queries = new ArrayList<String>();
			while (scanner.hasNext()) {
				String currentQuery = scanner.next() + ";";
				queries.add(currentQuery);
			}
			
			scanner.close();
			
			return queries.toArray(new String[0]);
		}
		catch(IOException ioException) {
			RIFServiceExceptionFactory rifExceptionFactory
				= new RIFServiceExceptionFactory();
			throw rifExceptionFactory.createFileReadingProblemException(
				dbInitialisationScriptFile.getName());
		}
	}
	
	
	public void createDatabase(
		final Connection connection,
		final DatabaseConnectionsConfiguration dbParameters) 
		throws SQLException {

		/*
		 * #POSSIBLE_PORTING_ISSUE
		 * One thing that would be useful is to have a DROP statement,
		 * but perhaps DROP IF EXISTS is something that presents a porting
		 * issue.
		 */		
		MSSQLDropDatabaseQueryFormatter dropDatabaseQueryFormatter
			= new MSSQLDropDatabaseQueryFormatter(false);
		dropDatabaseQueryFormatter.setDatabaseName(dbParameters.getDatabaseName());

		MSSQLCreateDatabaseQueryFormatter createDatabaseQueryFormatter
			= new MSSQLCreateDatabaseQueryFormatter(false);
		createDatabaseQueryFormatter.setDatabaseName(dbParameters.getDatabaseName());

		PreparedStatement dropDatabaseStatement = null;
		PreparedStatement createDatabaseStatement = null;
		try {
			dropDatabaseStatement 
				= connection.prepareStatement(
					dropDatabaseQueryFormatter.generateQuery());
			dropDatabaseStatement.executeQuery();
			createDatabaseStatement
				= connection.prepareStatement(
					createDatabaseQueryFormatter.generateQuery());
			dropDatabaseStatement.executeQuery();					
		}
		finally {
			createDatabaseStatement.close();
		}
				
		/*
		String databaseName = dbParameters.getDatabaseName();
		StringBuilder dropDatabaseQueryText = new StringBuilder();
		dropDatabaseQueryText.append("DROP DATABASE IF EXISTS ");
		dropDatabaseQueryText.append(dbParameters.getDatabaseName());
		dropDatabaseQueryText.append(";");
		
		StringBuilder createDatabaseQueryText = new StringBuilder();
		*/
		
	}
	
	
	private Connection createConnection(
		final String connectionURL,
		final String userID,
		final String password)
		throws Exception {
		
		Properties databaseProperties = new Properties();
			
		if (userID != null) {
			databaseProperties.setProperty("user", userID);
			databaseProperties.setProperty("password", password);
		}
		//databaseProperties.setProperty("ssl", "true");
		//databaseProperties.setProperty("logUnclosedConnections", "true");
		databaseProperties.setProperty("prepareThreshold", "3");
		//KLG: @TODO this introduces a porting issue
		//int logLevel = org.postgresql.Driver.DEBUG;
		//databaseProperties.setProperty("loglevel", String.valueOf(logLevel));
		System.out.println("TestDBInitialiser createConnection connection string=="+connectionURL+"==");
		System.out.println("TestDBInitialiser createConnection class=="+dbParameters.getDatabaseDriverClassName()+"==");
		Class.forName(dbParameters.getDatabaseDriverClassName());

		
		Connection connection
			= DriverManager.getConnection(
				connectionURL, 
				databaseProperties);
		connection.setReadOnly(false);				
		//connection.setAutoCommit(true);

		return connection;

	}

	
	// ==========================================
	// Section Errors and Validation
	// ==========================================

	// ==========================================
	// Section Interfaces
	// ==========================================

	// ==========================================
	// Section Override
	// ==========================================

}


