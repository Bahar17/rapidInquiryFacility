package rifServices.dataStorageLayer;


import java.sql.*;
import java.util.ArrayList;

import rifServices.businessConceptLayer.*;
import rifServices.system.RIFServiceException;
import rifServices.system.RIFServiceMessages;
import rifServices.system.RIFServiceError;













import rifServices.util.FieldValidationUtility;

import java.awt.geom.Rectangle2D;

/**
 *
 * Public methods assume that parameter values are non-null and do not present
 * security concerns.  Error checks focus on the following kinds of errors:
 * <ul>
 * <li>
 * check whether String values conform to regular expressions expected in the
 * database
 * </li>
 * <li>
 * check that parameter objects instantiated from business classes do not have
 * field-level errors or errors caused by combinations of errors
 * </li>
 * <li>
 * check that combinations of parameter values do not exhibit errors
 * </li>
 * </ul>
 * <hr>
 * The Rapid Inquiry Facility (RIF) is an automated tool devised by SAHSU 
 * that rapidly addresses epidemiological and public health questions using 
 * routinely collected health and population data and generates standardised 
 * rates and relative risks for any given health outcome, for specified age 
 * and year ranges, for any given geographical area.
 *
 * Copyright 2014 Imperial College London, developed by the Small Area
 * Health Statistics Unit. The work of the Small Area Health Statistics Unit 
 * is funded by the Public Health England as part of the MRC-PHE Centre for 
 * Environment and Health. Funding for this project has also been received 
 * from the United States Centers for Disease Control and Prevention.  
 *
 * <pre> 
 * This file is part of the Rapid Inquiry Facility (RIF) project.
 * RIF is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * RIF is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with RIF. If not, see <http://www.gnu.org/licenses/>; or write 
 * to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, 
 * Boston, MA 02110-1301 USA
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

class SQLResultsQueryManager extends AbstractSQLManager {

	// ==========================================
	// Section Constants
	// ==========================================

	// ==========================================
	// Section Properties
	// ==========================================
	private SQLRIFContextManager sqlRIFContextManager;
	private SQLDiseaseMappingStudyManager sqlDiseaseMappingStudyManager;
	
	// ==========================================
	// Section Construction
	// ==========================================

	public SQLResultsQueryManager(
		SQLRIFContextManager sqlRIFContextManager,
		SQLDiseaseMappingStudyManager sqlDiseaseMappingStudyManager) {
		
		this.sqlRIFContextManager = sqlRIFContextManager;
		this.sqlDiseaseMappingStudyManager = sqlDiseaseMappingStudyManager;
	}

	// ==========================================
	// Section Accessors and Mutators
	// ==========================================

	public BoundaryRectangle getGeoLevelBoundsForArea(
		final Connection connection,
		final User user,
		final StudyResultRetrievalContext studyResultRetrievalContext,
		final MapArea mapArea)
		throws RIFServiceException {
	
		//Validate parameters
		validateCommonParameters(
			connection,
			user,
			studyResultRetrievalContext);
		mapArea.checkErrors();
		checkMapAreaExists(
			connection, 
			studyResultRetrievalContext,
			mapArea);
		checkMapAreaExistsInStudy(
			connection, 
			studyResultRetrievalContext,
			mapArea);
		
		//Create query
		SQLFunctionCallerQueryFormatter query
			= new SQLFunctionCallerQueryFormatter();
		query.setSchema("rif40_xml_pkg");
		query.setFunctionName("rif40_getgeolevelboundsforarea");
		query.setNumberOfFunctionParameters(3);
		
		//Execute query and generate results
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement
				= connection.prepareStatement(query.generateQuery());
			statement.setString(1, studyResultRetrievalContext.getGeographyName());
			statement.setString(2, studyResultRetrievalContext.getGeoLevelSelectName());
			statement.setString(3, mapArea.getIdentifier());
			resultSet = statement.executeQuery();

			/*
			 * Expecting a result with four columns:
			 * yMax  |   xMax   |  yMax  |  yMin
			 * 
			 * Assumes at least one result returned because
			 * SQL function call will throw an exception if
			 * no results are returned
			 */
			//Assumes at least one result, because function will
			//
			resultSet.next();
			
			double yMax = resultSet.getDouble(1);
			double xMax = resultSet.getDouble(2);
			double yMin = resultSet.getDouble(3);			
			double xMin = resultSet.getDouble(4);
			
			BoundaryRectangle result
				= BoundaryRectangle.newInstance(
					xMin,
					yMin,
					xMax,
					yMax);
			return result;
		}
		catch(SQLException sqlException) {
			sqlException.printStackTrace();
			logSQLException(sqlException);
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.unableToGetBoundsForArea",
					mapArea.getDisplayName(),
					studyResultRetrievalContext.getGeographyName(),
					studyResultRetrievalContext.getGeoLevelSelectName());
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED, 
					errorMessage);
			throw rifServiceException;			
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);
		}		
	}	

	public BoundaryRectangle getGeoLevelFullExtentForStudy(
		final Connection connection,
		final User user,
		final StudyResultRetrievalContext studyResultRetrievalContext)
		throws RIFServiceException {
	
		//Validate parameters
		user.checkErrors();
		validateCommonParameters(
			connection,
			user,
			studyResultRetrievalContext);
		
		//Create query
		SQLFunctionCallerQueryFormatter query
			= new SQLFunctionCallerQueryFormatter();
		query.setSchema("rif40_xml_pkg");
		query.setFunctionName("rif40_getgeolevelfullextentforstudy");
		query.setNumberOfFunctionParameters(3);

		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement
				= connection.prepareStatement(query.generateQuery());			
			statement.setString(1, studyResultRetrievalContext.getGeographyName());
			statement.setString(2, studyResultRetrievalContext.getGeoLevelSelectName());
			statement.setInt(3, Integer.valueOf(studyResultRetrievalContext.getStudyID()));
			
			resultSet = statement.executeQuery();
			
			//Assume there is at least one result because
			//SQL function will generate an exception if 
			//there are no results
			resultSet.next();

			double yMax = resultSet.getDouble(1);
			double xMax = resultSet.getDouble(2);
			double yMin = resultSet.getDouble(3);			
			double xMin = resultSet.getDouble(4);
			
			BoundaryRectangle result
				= BoundaryRectangle.newInstance(
					xMin,
					yMin,
					xMax,
					yMax);
			return result;
		}
		catch(SQLException sqlException) {
			sqlException.printStackTrace();
			logSQLException(sqlException);
			String studyName 
				= getStudyName(
					connection, 
					studyResultRetrievalContext.getStudyID());
			
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.unableToGetBoundsForStudy",
					studyName,
					studyResultRetrievalContext.getGeographyName(),
					studyResultRetrievalContext.getGeoLevelSelectName());
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED, 
					errorMessage);
			throw rifServiceException;
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);
		}		
	}
	
	public BoundaryRectangle getGeoLevelFullExtent(
		final Connection connection,
		final User user,
		final Geography geography,
		final GeoLevelSelect geoLevelSelect)
		throws RIFServiceException {
		
		//Validate parameters
		validateCommonParameters(
			connection,
			user,
			geography,
			geoLevelSelect);		
					
		//Create query
		SQLFunctionCallerQueryFormatter query
			= new SQLFunctionCallerQueryFormatter();
		query.setSchema("rif40_xml_pkg");
		query.setFunctionName("rif40_getgeolevelfullextent");
		query.setNumberOfFunctionParameters(2);		
			
		//Execute query and generate results
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement
				= connection.prepareStatement(query.generateQuery());
			statement.setString(1, geography.getName());
			statement.setString(2, geoLevelSelect.getName());				
			resultSet = statement.executeQuery();
			
			//Assume there is at least one row result
			resultSet.next();
			
			double yMax = resultSet.getDouble(1);
			double xMax = resultSet.getDouble(2);
			double yMin = resultSet.getDouble(3);			
			double xMin = resultSet.getDouble(4);
			
			BoundaryRectangle result
				= BoundaryRectangle.newInstance(
					xMin,
					yMin,
					xMax,
					yMax);
			return result;
		}
		catch(SQLException sqlException) {
			logSQLException(sqlException);
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.unableToGetBoundsForGeoLevel",
					geoLevelSelect.getDisplayName(),
					geography.getDisplayName());
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED, 
					errorMessage);
			throw rifServiceException;
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);
		}		
	}

	public String getTiles(
		final Connection connection,
		final User user,
		final Geography geography,
		final GeoLevelSelect geoLevelSelect,
		final Integer zoomFactor,
		final String tileIdentifier) 
		throws RIFServiceException {

		//Validate parameters
		validateCommonParameters(
			connection,
			user,
			geography,
			geoLevelSelect);		
		
		//Create query
		SQLFunctionCallerQueryFormatter query
			= new SQLFunctionCallerQueryFormatter();
		query.setSchema("rif40_xml_pkg");
		query.setFunctionName("rif40_get_geojson_tiles");
		query.setNumberOfFunctionParameters(2);		
		
		//Execute query and generate results
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement 
				= connection.prepareStatement(query.generateQuery());
			statement.setString(1, geography.getIdentifier());
			statement.setString(2, geoLevelSelect.getIdentifier());
			resultSet = statement.executeQuery();

			//Assume at least one row will be returned
			resultSet.next();
			
			String result = resultSet.getString(1);
			return result;
		}
		catch(SQLException sqlException) {
			logSQLException(sqlException);
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.unableToGetTiles",
					geoLevelSelect.getDisplayName(),
					geography.getDisplayName());
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED,
					errorMessage);
			throw rifServiceException;
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);
		}		
	}


	
	
	//Issue: make sure that the results table has a column 'row' because it's where
	//we associate a BETWEEN X AN Y for start and end index of block
	/**
	 * STUBBED
	 * @param connection
	 * @param user
	 * @param studyResultRetrievalContext
	 * @param calculatedResultTableFieldNames
	 * @param startRowIndex
	 * @param endRowIndex
	 * @return
	 * @throws RIFServiceException
	 */
	public RIFResultTable getCalculatedResultsByBlock(
		Connection connection,
		User user,
		StudyResultRetrievalContext studyResultRetrievalContext,
		String[] calculatedResultTableFieldNames,
		Integer startRowIndex,
		Integer endRowIndex)
		throws RIFServiceException {
			
		//Validate parameters
		user.checkErrors();
		studyResultRetrievalContext.checkErrors();
		//determine whether the data governance permissions even allow
		//a result table to be generated
		checkPermissionsAllowResultsTable(
			connection,
			studyResultRetrievalContext);		
		String calculatedResultTableName
			= getCalculatedResultTableName(
				connection, 
				studyResultRetrievalContext);
		if (calculatedResultTableName == null) {
			//Permissions may allow results table to be generated
			//but the job may not have yet been processed
			
		}
		//check that results table exists
		checkResultsTableExists(
			connection,
			studyResultRetrievalContext,
			calculatedResultTableName);
		for (String calculatedResultTableFieldName : calculatedResultTableFieldNames) {
			checkResultsTableFieldExists(
				connection, 
				studyResultRetrievalContext,
				calculatedResultTableName, 
				calculatedResultTableFieldName);
		}
		
		String startRowPhrase = String.valueOf(startRowIndex);
		String endRowPhrase = String.valueOf(endRowIndex);
		int totalRowsInResultTable 
			= getRowCountForResultTable(
				connection,
				calculatedResultTableName);
				
		if (startRowIndex > totalRowsInResultTable) {
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.error.unrealisticBlockStartRow",
					String.valueOf(startRowIndex),
					studyResultRetrievalContext.getStudyID(),
					String.valueOf(totalRowsInResultTable));
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.UNREALISTIC_RESULT_BLOCK_START_ROW, 
					errorMessage);
			throw rifServiceException;
		}
		
		if (startRowIndex > endRowIndex) {
			//ERROR: start row cannot be greater than end row
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.error.startRowMoreThanEndRow",
					studyResultRetrievalContext.getStudyID(),
					startRowPhrase,
					endRowPhrase);
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.RESULT_BLOCK_START_MORE_THAN_END, 
					errorMessage);
			throw rifServiceException;
		}		

	
		//Create query
		SQLSelectQueryFormatter query
			= new SQLSelectQueryFormatter();
		query.addFromTable(calculatedResultTableName);
		for (String resultTableFieldName : calculatedResultTableFieldNames) {
			query.addSelectField(resultTableFieldName);
		}
		query.addFromTable(calculatedResultTableName);
		query.addWhereBetweenParameter(
			"row", 
			startRowPhrase, 
			endRowPhrase);
		
		int totalRowsInBlock;
		if (endRowIndex > totalRowsInResultTable) {
			//it means the last block of results will not be completely filled
			totalRowsInBlock = endRowIndex - startRowIndex;			
		}
		else {
			totalRowsInBlock = totalRowsInResultTable - startRowIndex;
		}
		
		//Execute query and generate results
		RIFResultTable result = new RIFResultTable();
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement 
				= connection.prepareStatement(
					query.generateQuery());
			resultSet = statement.executeQuery();
			result = generateResultTable(resultSet);
			return result;		
		}
		catch(SQLException sqlException) {
			logSQLException(sqlException);
			String studyName 
				= getStudyName(
					connection, 
					studyResultRetrievalContext.getStudyID());
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.error.unableToGetCalculatedResultsByBlock",
					studyName,
					startRowPhrase, 
					endRowPhrase);
			RIFServiceException rifServiceException	
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED, 
					errorMessage);
			throw rifServiceException;
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);			
		}		
		
	}

	/**
	 * Obtains the name of the table of calculated results that is associated with 
	 * a given study.  The name of the table should appear in the 'map_table' field
	 * of rif40_studies.  Note that this is different from the extract table, which
	 * appears in the 'extract_table' field of the same table.
	 * Assumes that the study exists
	 * @param connection
	 * @param diseaseMappingStudy
	 * @return
	 * @throws RIFServiceException
	 */
	private String getCalculatedResultTableName(
		Connection connection,
		StudyResultRetrievalContext studyResultRetrievalContext)
		throws RIFServiceException {
		
		//Create query
		SQLSelectQueryFormatter query
			= new SQLSelectQueryFormatter();
		query.addSelectField("map_table");
		query.addFromTable("rif40_studies");
		query.addWhereParameter("study_id");
		
		//Execute query and generate results
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement 
				= connection.prepareStatement(query.generateQuery());
			statement.setString(1, studyResultRetrievalContext.getStudyID());
			resultSet = statement.executeQuery();
			//there should be an entry for the study in rif40_studies.
			//However, it may have a blank value for the map table field value
			resultSet.next();
			String result = resultSet.getString(1);
			return result;
		}
		catch(SQLException sqlException) {
			logSQLException(sqlException);
			String studyName 
				= getStudyName(
					connection, 
					studyResultRetrievalContext.getStudyID());
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.error.unableToGetCalculatedResultsTableName",
					studyName);
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED, 
					errorMessage);
			throw rifServiceException;
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);			
		}		
	}

	/**
	 * STUBBED
	 * @param connection
	 * @param user
	 * @param studyResultRetrievalContext
	 * @param geoLevelAttributeSource
	 * @param geoLevelAttribute
	 * @return
	 * @throws RIFServiceException
	 */
	public ArrayList<MapAreaAttributeValue> getMapAreaAttributeValues(
		final Connection connection,
		final User user,
		final StudyResultRetrievalContext studyResultRetrievalContext,
		final GeoLevelAttributeSource geoLevelAttributeSource,
		final String geoLevelAttribute) 
		throws RIFServiceException {
		
		//Validate parameters
		validateCommonParameters(
			connection,
			user,
			studyResultRetrievalContext);
		checkGeoLevelAttributeExists(
			connection,
			studyResultRetrievalContext,
			geoLevelAttribute);
		
		//Create query		
		SQLFunctionCallerQueryFormatter query
			= new SQLFunctionCallerQueryFormatter();
		query.setSchema("rif40_xml_pkg");
		query.setFunctionName("");
		query.setNumberOfFunctionParameters(2);		
		
		//Execute query and generate results
		ArrayList<MapAreaAttributeValue> results
			= new ArrayList<MapAreaAttributeValue>();
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement 
				= connection.prepareStatement(query.generateQuery());
			statement.setString(1, geoLevelAttribute);
			resultSet = statement.executeQuery();
			
			while (resultSet.next()) {
				MapAreaAttributeValue mapAreaAttributeValue
					= MapAreaAttributeValue.newInstance();
				mapAreaAttributeValue.setIdentifier(resultSet.getString(1));
				mapAreaAttributeValue.setAttributeValue(resultSet.getString(2));
				mapAreaAttributeValue.setAttributeName(geoLevelAttribute);
				results.add(mapAreaAttributeValue);
			}
			return results;
		}
		catch(SQLException sqlException) {
			logSQLException(sqlException);
			String studyName 
				= getStudyName(
					connection, 
					studyResultRetrievalContext.getStudyID());
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.unableToGetValuesForMapAreaAttribute",
					geoLevelAttribute,
					studyName,
					studyResultRetrievalContext.getGeographyName(),
					studyResultRetrievalContext.getGeoLevelSelectName());
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED, 
					errorMessage);
			throw rifServiceException;
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);
		}
		
	}
	
	/**
	 * STUBBED
	 * @param connection
	 * @param user
	 * @param studyResultRetrievalContext
	 * @return
	 * @throws RIFServiceException
	 */
	public ArrayList<GeoLevelAttributeSource> getGeoLevelAttributeSources(
		final Connection connection,
		final User user,
		final StudyResultRetrievalContext studyResultRetrievalContext) 
		throws RIFServiceException {
		
		//Validate parameters
		user.checkErrors();
		studyResultRetrievalContext.checkErrors();
		
		//Create query		
		ArrayList<GeoLevelAttributeSource> results
			= new ArrayList<GeoLevelAttributeSource>();
		
		SQLFunctionCallerQueryFormatter query
			= new SQLFunctionCallerQueryFormatter();
		query.setSchema("rif40_xml_pkg");
		query.setFunctionName("");
		query.setNumberOfFunctionParameters(2);
		
		
		//Execute query and generate results
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement 
				= connection.prepareStatement(query.generateQuery());
			statement.setString(1, studyResultRetrievalContext.getGeographyName());
			statement.setString(2, studyResultRetrievalContext.getGeoLevelSelectName());
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				GeoLevelAttributeSource geoLevelAttributeSource
					= GeoLevelAttributeSource.newInstance(resultSet.getString(1));
				results.add(geoLevelAttributeSource);
			}
			return results;
		}
		catch(SQLException sqlException) {
			String studyName 
				= getStudyName(
					connection, 
					studyResultRetrievalContext.getStudyID());
			logSQLException(sqlException);
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.error.unableToGetGeoLevelAttributeSources",
					studyName,
					studyResultRetrievalContext.getGeographyName(),
					studyResultRetrievalContext.getGeoLevelSelectName());
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED, 
					errorMessage);
			throw rifServiceException;
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);
		}				
	}
		
	// -- what function to call go get attribute themes?
	/**
	 * STUBBED
	 * @param connection
	 * @param user
	 * @param geography
	 * @param geoLevelSelect
	 * @return
	 * @throws RIFServiceException
	 */
	public ArrayList<GeoLevelAttributeTheme> getGeoLevelAttributeThemes(
		final Connection connection,
		final User user,
		final StudyResultRetrievalContext studyResultRetrievalContext,
		final GeoLevelAttributeSource geoLevelAttributeSource)
		throws RIFServiceException {

		//Validate parameters
		validateCommonParameters(
			connection,
			user,
			studyResultRetrievalContext);
		
		//Create query		
		ArrayList<GeoLevelAttributeTheme> results
			= new ArrayList<GeoLevelAttributeTheme>();
		
		SQLFunctionCallerQueryFormatter query
			= new SQLFunctionCallerQueryFormatter();
		query.setSchema("rif40_xml_pkg");
		query.setFunctionName("");
		query.setNumberOfFunctionParameters(2);
		
		
		//Execute query and generate results
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement 
				= connection.prepareStatement(query.generateQuery());
			statement.setString(1, studyResultRetrievalContext.getGeographyName());
			statement.setString(2, studyResultRetrievalContext.getGeoLevelSelectName());
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				GeoLevelAttributeTheme geoLevelAttributeTheme
					= GeoLevelAttributeTheme.newInstance(resultSet.getString(1));
				results.add(geoLevelAttributeTheme);
			}
			return results;
		}
		catch(SQLException sqlException) {
			logSQLException(sqlException);
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.unableToGetGeoLevelAttributeThemes",
					studyResultRetrievalContext.getGeographyName(),
					studyResultRetrievalContext.getGeoLevelSelectName());
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED, 
					errorMessage);
			throw rifServiceException;
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);
		}		
	}

	/**
	 * STUBBED
	 * @param connection
	 * @param user
	 * @param studyResultRetrievalContext
	 * @param geoLevelAttributeSource
	 * @param geoLevelAttributeTheme
	 * @return
	 * @throws RIFServiceException
	 */
	public String[] getAllAttributesForGeoLevelAttributeTheme(
		final Connection connection,
		final User user,
		final StudyResultRetrievalContext studyResultRetrievalContext,
		final GeoLevelAttributeSource geoLevelAttributeSource,
		final GeoLevelAttributeTheme geoLevelAttributeTheme)
		throws RIFServiceException {
			
		//Validate parameters
		validateCommonParameters(
			connection,
			user,
			studyResultRetrievalContext);		
		geoLevelAttributeSource.checkErrors();		
		checkGeoLevelAttributeSourceExists(
			connection, 
			studyResultRetrievalContext,
			geoLevelAttributeSource);
		geoLevelAttributeTheme.checkErrors();
		checkGeoLevelAttributeThemeExists(
			connection, 
			studyResultRetrievalContext,
			geoLevelAttributeSource,
			geoLevelAttributeTheme);
		
		//Create query		
		SQLFunctionCallerQueryFormatter query
			= new SQLFunctionCallerQueryFormatter();
		query.setSchema("rif40_xml_pkg");
		query.setFunctionName("");
		query.setNumberOfFunctionParameters(3);
			
		//Execute query and generate results
		String[] results = new String[0];			
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement 
				= connection.prepareStatement(query.generateQuery());
			statement.setString(
				1, 
				studyResultRetrievalContext.getGeographyName());
			statement.setString(
				2, 
				studyResultRetrievalContext.getGeoLevelSelectName());
			statement.setString(
				3, 
				studyResultRetrievalContext.getStudyID());
			statement.setString(4, geoLevelAttributeSource.getName());
			statement.setString(5, geoLevelAttributeTheme.getName());
			resultSet = statement.executeQuery();
			ArrayList<String> attributes = new ArrayList<String>();
			while (resultSet.next()) {
				attributes.add(resultSet.getString(1));
			}
			
			results = attributes.toArray(new String[0]);

			return results;
		}
		catch(SQLException sqlException) {
			logSQLException(sqlException);
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.error.unableToGetAttributesForGeoLevelAttributeTheme",
					geoLevelAttributeTheme.getDisplayName(),
					studyResultRetrievalContext.getGeographyName(),
					studyResultRetrievalContext.getGeoLevelSelectName());
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED,
					errorMessage);
			throw rifServiceException;
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);			
		}		
	}	
	
	//CHECKED -- find out function name
	/**
	 * STUBBED
	 * @param connection
	 * @param user
	 * @param studyResultRetrievalContext
	 * @param geoLevelAttributeSource
	 * @param geoLevelAttributeTheme
	 * @return
	 * @throws RIFServiceException
	 */
	public String[] getNumericAttributesForGeoLevelAttributeTheme(
		Connection connection,
		User user,
		StudyResultRetrievalContext studyResultRetrievalContext,
		GeoLevelAttributeSource geoLevelAttributeSource,
		GeoLevelAttributeTheme geoLevelAttributeTheme) 
		throws RIFServiceException {
			
		//Validate parameters
		validateCommonParameters(
			connection,
			user,
			studyResultRetrievalContext);
		geoLevelAttributeSource.checkErrors();		
		checkGeoLevelAttributeSourceExists(
			connection, 
			studyResultRetrievalContext,
			geoLevelAttributeSource);
		
		geoLevelAttributeTheme.checkErrors();
		checkGeoLevelAttributeThemeExists(
			connection, 
			studyResultRetrievalContext,
			geoLevelAttributeSource,
			geoLevelAttributeTheme);
			
		String[] results = new String[0]; 
			
		//Create query		
		SQLFunctionCallerQueryFormatter query
			= new SQLFunctionCallerQueryFormatter();
		query.setSchema("rif40_xml_pkg");
		query.setFunctionName("");
		query.setNumberOfFunctionParameters(3);
		
		//Execute query and generate results
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement = connection.prepareStatement(query.generateQuery());
			statement.setString(1, studyResultRetrievalContext.getGeographyName());
			statement.setString(2, studyResultRetrievalContext.getGeoLevelSelectName());
			statement.setString(3, geoLevelAttributeTheme.getName());
			
			resultSet = statement.executeQuery();
			ArrayList<String> attributes = new ArrayList<String>();
			while (resultSet.next()) {
				attributes.add(resultSet.getString(1));
			}
			
			results = attributes.toArray(new String[0]);

			return results;
		}
		catch(SQLException sqlException) {
			logSQLException(sqlException);
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.error.unableToGetNumericAttributesForGeoLevelAttributeTheme",
					geoLevelAttributeTheme.getDisplayName(),
					studyResultRetrievalContext.getGeographyName(),
					studyResultRetrievalContext.getGeoLevelSelectName());
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED,
					errorMessage);
			throw rifServiceException;
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);			
		}		
	}
	
	//CHECKED -- assume that result table has the field "row" in it to get 
	//start and end row index	
	/**
	 * STUBBED
	 * @param connection
	 * @param user
	 * @param studyResultRetrievalContext
	 * @param calculatedResultTableFieldNames
	 * @param extractStartRowIndex
	 * @param extractEndRowIndex
	 * @return
	 * @throws RIFServiceException
	 */
	public RIFResultTable getExtractByBlock(
		Connection connection,
		User user,
		StudyResultRetrievalContext studyResultRetrievalContext,
		String[] calculatedResultTableFieldNames,
		Integer extractStartRowIndex,
		Integer extractEndRowIndex)
		throws RIFServiceException {
				
		//Validate parameters
		user.checkErrors();
		studyResultRetrievalContext.checkErrors();
		sqlDiseaseMappingStudyManager.checkDiseaseMappingStudyExists(
			connection, 
			studyResultRetrievalContext.getStudyID());
				
		//Obtain the extract table
		String extractTableName
			= getExtractTableName(
				connection, 
				studyResultRetrievalContext.getStudyID());
		String startRowPhrase = String.valueOf(extractStartRowIndex);
		String endRowPhrase = String.valueOf(extractEndRowIndex);
		int totalRowsInResultTable 
			= getRowCountForResultTable(
				connection,
				extractTableName);
				
		if (extractStartRowIndex > totalRowsInResultTable) {
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.error.unrealisticBlockStartRow",
					String.valueOf(extractStartRowIndex),
					String.valueOf(totalRowsInResultTable));
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.UNREALISTIC_RESULT_BLOCK_START_ROW, 
					errorMessage);
			throw rifServiceException;
		}
		
		if (extractStartRowIndex > extractEndRowIndex) {
			//ERROR: start row cannot be greater than end row
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.error.startRowMoreThanEndRow",
					startRowPhrase,
					endRowPhrase);
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.RESULT_BLOCK_START_MORE_THAN_END, 
					errorMessage);
			throw rifServiceException;
		}		

		//KLG: TODO call database function for this

		//Create query		
		String[] extractTableFieldNames = new String[1];
				
		SQLSelectQueryFormatter query
			= new SQLSelectQueryFormatter();
		for (String extractTableFieldName : extractTableFieldNames) {
			query.addSelectField(extractTableFieldName);
		}
		query.addFromTable(extractTableName);
		query.addWhereBetweenParameter(
			"row", 
			startRowPhrase, 
			endRowPhrase);
		
		int totalRowsInBlock;
		if (extractEndRowIndex > totalRowsInResultTable) {
			//it means the last block of results will not be completely filled
			totalRowsInBlock = extractEndRowIndex - extractStartRowIndex;			
		}
		else {
			totalRowsInBlock = totalRowsInResultTable - extractStartRowIndex;
		}
		
		//Execute query and generate results
		RIFResultTable result = new RIFResultTable();
		result.setFieldNames(extractTableFieldNames);
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement 
				= connection.prepareStatement(
					query.generateQuery());
			resultSet = statement.executeQuery();
			result = generateResultTable(resultSet);
					
			return result;
		}
		catch(SQLException sqlException) {
			logSQLException(sqlException);
			String studyName
				= getStudyName(
					connection, 
					studyResultRetrievalContext.getStudyID());
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.error.unableToGetExtractResultsByBlock",
					studyName,
					startRowPhrase, 
					endRowPhrase);
			RIFServiceException rifServiceException	
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED, 
					errorMessage);
			throw rifServiceException;
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);			
		}		
		
	}

	/**
	 * This is a routine that provides a generic way of transforming rows
	 * returned by the JDBC call into rows that can be easily rendered by clients.
	 * This method needs to know how large the result set is going to be.  
	 * 
	 * <p>
	 * A common way of doing this is to move to the last row of the resultSet and
	 * obtain the row number.  However, this approach is slow.  
	 * It isn't clear how flexible this routine has to be.  If numberOfRows is 
	 * not null, then we will use this value to determine how many rows the result
	 * table should have. 
	 * @param resultSet
	 * @param tableName
	 * @param primaryKeyField
	 * @return
	 * @throws SQLException
	 */
	private RIFResultTable generateResultTable(
		ResultSet resultSet)
		throws SQLException {
		
		RIFResultTable rifResultTable = new RIFResultTable();
		
		//Obtain the total number of rows
		int totalResultRows = 0;
		if (resultSet == null) {
			return rifResultTable;
		}		
		try {
			resultSet.last();
			totalResultRows = resultSet.getRow();
		}
		finally {
			resultSet.beforeFirst();
		}		
		
		//Obtain the column names
		ResultSetMetaData resultSetMetaData
			= resultSet.getMetaData();

		int numberOfColumns = resultSetMetaData.getColumnCount();
		String[] resultFieldNames = new String[numberOfColumns];
		for (int i = 0; i < resultFieldNames.length; i++) {
			resultFieldNames[i] = resultSetMetaData.getColumnName(i+1);
		}
		rifResultTable.setFieldNames(resultFieldNames);
					
		String[][] resultsBlockData
			= new String[totalResultRows][resultFieldNames.length];
		
		int ithRow = 0;
		while (resultSet.next()) {
			for (int i = 1; i < resultFieldNames.length; i++) {
				resultsBlockData[ithRow][i] = resultSet.getString(i + 1);
			}			
			ithRow = ithRow + 1;
		}
		rifResultTable.setData(resultsBlockData);
		
		return rifResultTable;
	}
	
	
	private String getExtractTableName(
		Connection connection,
		String studyID) 
		throws RIFServiceException {
					
		//Create query		
		SQLSelectQueryFormatter query
			= new SQLSelectQueryFormatter();
		query.addSelectField("extract_table");
		query.addFromTable("rif40_studies");
		query.addWhereParameter("study_id");
				
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement 
				= connection.prepareStatement(query.generateQuery());
			resultSet = statement.executeQuery();
			
			if (resultSet.next() == false) {
				/*
				 * In many of the queries in this class, we assume that 
				 * a query will generate a result.  This is not the case
				 * for getting the name of an extract table for a given study.
				 * A study may not have been run yet to produce a results table
				 * It is also the case that permissions problems prevent result
				 * tables from being generated.
				 */
				String studyName
					= getStudyName(
						connection,
						studyID);
				String errorMessage
					= RIFServiceMessages.getMessage(
						"sqlResultsQueryManager.unableToGetExtractTableName",
						studyName);
				RIFServiceException rifServiceException
					= new RIFServiceException(
						RIFServiceError.UNABLE_TO_GET_EXTRACT_TABLE_NAME, 
						errorMessage);
				throw rifServiceException;
			}
			
			String extractTableName = resultSet.getString(1);
			return extractTableName;
		}
		catch(SQLException sqlException) {
			logSQLException(sqlException);
			String studyName
				= getStudyName(connection, studyID);
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.unableToGetExtractTableName",
					studyName);
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED,
					errorMessage);
			throw rifServiceException;
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);			
		}
	}
	
	
	/**
	 * STUBBED
	 * @param connection
	 * @param user
	 * @param diseaseMappingStudy
	 * @return
	 * @throws RIFServiceException
	 */
	public String[] getGeometryColumnNames(
		Connection connection,
		User user,
		DiseaseMappingStudy diseaseMappingStudy)
		throws RIFServiceException {
		
		//Validate parameters
		user.checkErrors();
		diseaseMappingStudy.checkErrors();
		
		//Create query		
		StringBuilder query = new StringBuilder();

		//Execute query and generate results
		String[] results = new String[0];
		//get the name of the calculated results table - ie the map table
		//KLG: TODO - do we need more parameters in the method here?
		String errorMessage
			= RIFServiceMessages.getMessage(
				"sqlResultsQueryManager.error.unableToGetGeometryColumnNames",
				diseaseMappingStudy.getDisplayName());
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement = connection.prepareStatement(query.toString());
			statement.setString(1, diseaseMappingStudy.getIdentifier());
			
			ArrayList<String> columnNames = new ArrayList<String>();
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				columnNames.add(resultSet.getString(1));
			}
			
			if (columnNames.size() == 0) {
				RIFServiceException rifServiceException
					= new RIFServiceException(
						RIFServiceError.UNABLE_TO_GET_GEOMETRY_COLUMN_NAMES, 
						errorMessage);
				throw rifServiceException;				
			}
			
			results = columnNames.toArray(new String[0]);
			return results;
		}
		catch(SQLException sqlException) {
			logSQLException(sqlException);
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED, 
					errorMessage);
			throw rifServiceException;
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);			
		}		
	}
		
	
	/**
	 * STUBBED
	 * @param connection
	 * @param user
	 * @param studyResultRetrievalContext
	 * @param geoLevelAttributeTheme
	 * @param geoLevelAttribute
	 * @param mapAreas
	 * @param year
	 * @return
	 * @throws RIFServiceException
	 */
	public RIFResultTable getResultsStratifiedByGenderAndAgeGroup(
		Connection connection,
		User user,
		StudyResultRetrievalContext studyResultRetrievalContext,
		GeoLevelAttributeSource geoLevelAttributeSource,
		String geoLevelAttribute,
		ArrayList<MapArea> mapAreas,
		Integer year) 
		throws RIFServiceException {
		
		user.checkErrors();
		studyResultRetrievalContext.checkErrors();
		geoLevelAttributeSource.checkErrors();
		for (MapArea mapArea : mapAreas) {
			mapArea.checkErrors();
		}
		
		
		//Create query
		StringBuilder query = new StringBuilder();
		
		//Execute query and generate results
		RIFResultTable result = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement = connection.prepareStatement(query.toString());
			resultSet = statement.executeQuery();
			result = generateResultTable(resultSet);
			
			
		}
		catch(SQLException sqlException) {
			logSQLException(sqlException);
			String errorMessage
				= RIFServiceMessages.getMessage("");
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED, 
					errorMessage);
			throw rifServiceException;
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);			
		}		
		
		
		
		//stub 
		RIFResultTable results = new RIFResultTable();
		return results;		
	}


	/**
	 * STUBBED
	 * @param connection
	 * @param resultTableName
	 * @return
	 * @throws RIFServiceException
	 */
	private int getRowCountForResultTable(
		Connection connection,
		String resultTableName)
		throws RIFServiceException {
		
		return 0;
	}


	
	// ==========================================
	// Section Errors and Validation
	// ==========================================
	private void validateCommonParameters(
		Connection connection,
		User user,
		StudyResultRetrievalContext studyResultRetrievalContext)
		throws RIFServiceException {

		user.checkErrors();
		studyResultRetrievalContext.checkErrors();		
		sqlRIFContextManager.checkGeographyExists(
			connection, 
			studyResultRetrievalContext.getGeographyName());
		
		sqlRIFContextManager.checkGeoLevelSelectExists(
			connection, 
			studyResultRetrievalContext.getGeographyName(),
			studyResultRetrievalContext.getGeoLevelSelectName());		

		sqlDiseaseMappingStudyManager.checkDiseaseMappingStudyExists(
			connection, 
			studyResultRetrievalContext.getStudyID());
	}

	
	private void validateCommonParameters(
		Connection connection,
		User user,
		Geography geography,
		GeoLevelSelect geoLevelSelect)
		throws RIFServiceException {
		
		user.checkErrors();
		geography.checkErrors();	
		geoLevelSelect.checkErrors();
		sqlRIFContextManager.checkGeographyExists(
			connection, 
			geography.getName());
		sqlRIFContextManager.checkGeoLevelSelectExists(
			connection, 
			geography.getName(),
			geoLevelSelect.getName());
	}
	
	
	
	
	/**
	 * Checks whether permissions associated with the table would
	 * prevent results tables from being generated.  We determine the
	 * permissions solely by looking at the value of the 'extract_permitted'
	 * field in the table rif40_studies.  We do *not* consider the value of
	 * 'transfer_permitted', which for now remains an information governance
	 * property that informs documentation rather than influences whether the
	 * middleware returns results or not.
	 * 
	 * <p>
	 * Assumes that the diseaseMappingStudy exists
	 * </p>
	 * @param connection
	 * @param diseaseMappingStudy
	 */
	private void checkPermissionsAllowResultsTable(
		Connection connection,
		StudyResultRetrievalContext studyResultRetrievalContext)
		throws RIFServiceException {
	
		SQLSelectQueryFormatter query
			= new SQLSelectQueryFormatter();
		query.addSelectField("extract_permitted");
		query.addFromTable("rif40_studies");
		query.addWhereParameter("study_id");
				
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String studyName = "";
		try {
			studyName
				= getStudyName(
					connection, 
					studyResultRetrievalContext.getStudyID());
			statement
				= connection.prepareStatement(query.generateQuery());
			statement.setString(1, studyResultRetrievalContext.getStudyID());
			resultSet = statement.executeQuery();
			//We can assume that the table will have an entry for the study
			resultSet.next();
			Boolean extractPermitted = resultSet.getBoolean(1);
			if (extractPermitted == null) {
				String errorMessage
					= RIFServiceMessages.getMessage(
						"sqlResultsQueryManager.error.unableToDetermineExtractPermissionForStudy",
						studyName);
				RIFServiceException rifServiceException
					= new RIFServiceException(
						RIFServiceError.UNABLE_TO_DETERMINE_EXTRACT_PERMISSION_FOR_STUDY, 
						errorMessage);
				throw rifServiceException;				
			}
			else if (extractPermitted == false) {
				String errorMessage
					= RIFServiceMessages.getMessage(
						"sqlResultsQueryManager.error.studyDoesNotAllowExtraction",
						studyName);
				RIFServiceException rifServiceException
					= new RIFServiceException(
						RIFServiceError.EXTRACT_NOT_PERMITTED_FOR_STUDY, 
						errorMessage);
				throw rifServiceException;
			}			
		}
		catch(SQLException sqlException) {
			logSQLException(sqlException);
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.error.unableToDetermineExtractPermissionForStudy",
					studyName);
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED, 
					errorMessage);
			throw rifServiceException;
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);			
		}		
	}

	private void checkResultsTableExists(
		Connection connection,
		StudyResultRetrievalContext studyResultRetrievalContext,
		String resultsTableName)
		throws RIFServiceException {
		
		//Create query/
		SQLRecordExistsQueryFormatter query
			= new SQLRecordExistsQueryFormatter();
		
		//Execute query and generate results
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String studyName = "";
		try {			
			studyName
				= getStudyName(
					connection, 
					studyResultRetrievalContext.getStudyID());
			statement
				= connection.prepareStatement(query.generateQuery());
			statement.setString(1, studyResultRetrievalContext.getStudyID());
			resultSet 
				= statement.executeQuery();
			if (resultSet.next() == false) {
				//the query did not return a result
				String errorMessage
					= RIFServiceMessages.getMessage(
						"sqlResultsQueryManager.error.nonExistentResultTable",
						resultsTableName,
						studyName);
				RIFServiceException rifServiceException
					= new RIFServiceException(
						RIFServiceError.NON_EXISTENT_RESULT_TABLE, 
						errorMessage);
				throw rifServiceException;
			}
		}
		catch(SQLException sqlException) {
			logSQLException(sqlException);
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.error.unableToCheckResultTableExists",
					studyName);
			RIFServiceException rifServiceException
				 = new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED,
					errorMessage);
			throw rifServiceException;
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);			
		}		
	}
	
	private void checkResultsTableFieldExists(
		Connection connection,
		StudyResultRetrievalContext studyResultsRetrievalContext,
		String resultsTableName,
		String resultsTableFieldName)
		throws RIFServiceException {

		
		SQLRecordExistsQueryFormatter query
			= new SQLRecordExistsQueryFormatter();
		
		
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		
		try {
			statement
				= connection.prepareStatement(query.generateQuery());
			resultSet 
				= statement.executeQuery();
			if (resultSet.next() == false) {
				//the query did not return a result
				String errorMessage
					= RIFServiceMessages.getMessage(
						"sqlResultsQueryManager.error.nonExistentResultTableField",
						resultsTableFieldName,
						resultsTableName,
						studyResultsRetrievalContext.getStudyID());
				RIFServiceException rifServiceException
					= new RIFServiceException(
						RIFServiceError.NON_EXISTENT_RESULT_TABLE_FIELD_NAME, 
						errorMessage);
				throw rifServiceException;
			}
		}
		catch(SQLException sqlException) {
			logSQLException(sqlException);
			String studyName
				= getStudyName(
					connection, 
					studyResultsRetrievalContext.getStudyID());
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.error.unableToCheckResultTableFieldExists",
					resultsTableFieldName,
					resultsTableName,
					studyName);
			RIFServiceException rifServiceException	
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED, 
					errorMessage);
			throw rifServiceException;
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);			
		}		
	}
	
	
	//Check what query we need
	private void checkMapAreaExists(
		Connection connection, 
		StudyResultRetrievalContext studyResultRetrievalContext,
		MapArea mapArea) 
		throws RIFServiceException {
		
				
		//Use geo level select to determine the correct
		//resolution lookup table.
	
		//KLG: @TODO - need to implement this method
		//should this check be one that checks if a map area exists in
		//the geography or that it is part of the study?
		
		/**
		String geographyTable = "sahsuland_geography";
		
		
		SQLRecordExistsQueryFormatter query
			= new SQLRecordExistsQueryFormatter();
		query.setFromTable(geographyTable);
		query.
		query.addWhereParameter(geoLevelSelect.getName());
		
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement 
				= connection.prepareStatement(query.generateQuery());
			statement.setString(1, mapArea.getIdentifier());
			resultSet = statement.executeQuery();
		
			if (resultSet.next() == false) {
				//the query did not return a result
				String errorMessage
					= RIFServiceMessages.getMessage(
						"sqlResultsQueryManager.error.nonExistentMapArea",
						mapArea.getDisplayName(),
						geography.getDisplayName(),
						geoLevelSelect.getDisplayName());
				RIFServiceException rifServiceException
					= new RIFServiceException(
						RIFServiceError.NON_EXISTENT_MAP_AREA, 
						errorMessage);
				throw rifServiceException;
			}			
		}
		catch(SQLException sqlException) {
			logSQLException(sqlException);
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.error.unableToCheckMapAreaExists",
					mapArea.getDisplayName(),
					geography.getDisplayName(),
					geoLevelSelect.getDisplayName());
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED, 
					errorMessage);
			throw rifServiceException;
		}
		finally {
			//Cleanup database resources
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);			
		}	
		
		*/
	}

	/**
	 * @TODO - This check determines whether the map area appears
	 * within the map table of the study
	 * @param connection
	 * @param studyResultRetrievalContext
	 * @param mapArea
	 * @throws RIFServiceException
	 */
	private void checkMapAreaExistsInStudy(
		Connection connection, 
		StudyResultRetrievalContext studyResultRetrievalContext,
		MapArea mapArea) 
		throws RIFServiceException {

		
		//@TODO
		
	}
	
	//CHECKED -- find out the name of the function
	private void checkGeoLevelAttributeExists(
		Connection connection,
		StudyResultRetrievalContext studyResultRetrievalContext,
		String geoLevelAttribute) 
		throws RIFServiceException {
		
		SQLFunctionCallerQueryFormatter query
			= new SQLFunctionCallerQueryFormatter();
		query.setSchema("rif40_xml_pkg");
		query.setFunctionName("");
		query.setNumberOfFunctionParameters(3);
		
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {			
			statement 	
				= connection.prepareStatement(query.generateQuery());
			statement.setString(
				1, 
				studyResultRetrievalContext.getGeographyName());
			statement.setString(
				2, 
				studyResultRetrievalContext.getGeoLevelSelectName());
			statement.setString(
				3, 
				geoLevelAttribute);
			resultSet = statement.executeQuery();
			resultSet.next();
			Boolean geoLevelSelectExists = resultSet.getBoolean(1);
			if (geoLevelSelectExists == false) {
				String errorMessage
					= RIFServiceMessages.getMessage(
						"sqlResultsQueryManager.error.nonExistentGeoLevelAttribute",
						geoLevelAttribute,
						studyResultRetrievalContext.getGeographyName(),
						studyResultRetrievalContext.getGeoLevelSelectName());
				RIFServiceException rifServiceException
					= new RIFServiceException(
						RIFServiceError.NON_EXISTENT_GEO_LEVEL_ATTRIBUTE,
						errorMessage);
				throw rifServiceException;
			}
		}
		catch(SQLException sqlException) {
			logSQLException(sqlException);
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.error.unableToCheckGeoLevelAttributeExists",
					geoLevelAttribute,
					studyResultRetrievalContext.getGeographyName(),
					studyResultRetrievalContext.getGeoLevelSelectName());
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED, 
					errorMessage);
			throw rifServiceException;
		}
		finally {
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);
		}
		
	}

	private void checkGeoLevelAttributeSourceExists(
		Connection connection,
		StudyResultRetrievalContext studyResultRetrievalContext,
		GeoLevelAttributeSource geoLevelAttributeSource)
		throws RIFServiceException {
		
	}
	
	private void checkGeoLevelAttributeThemeExists(
		Connection connection, 
		StudyResultRetrievalContext studyResultRetrievalContext,
		GeoLevelAttributeSource geoLevelAttributeSourceName,
		GeoLevelAttributeTheme geoLevelAttributeTheme)
		throws RIFServiceException {

		
		SQLFunctionCallerQueryFormatter query
			= new SQLFunctionCallerQueryFormatter();
		query.setSchema("rif40_xml_pkg");
		query.setFunctionName("");
		query.setNumberOfFunctionParameters(3);
	
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement 	
				= connection.prepareStatement(query.generateQuery());
			statement.setString(
				1, 
				studyResultRetrievalContext.getGeographyName());
			statement.setString(
				2, 
				studyResultRetrievalContext.getGeoLevelSelectName());
			statement.setString(
				3, 
				geoLevelAttributeTheme.getName());
			resultSet = statement.executeQuery();
			resultSet.next();
			
			Boolean geoLevelSelectExists = resultSet.getBoolean(1);
			if (geoLevelSelectExists == false) {
				String errorMessage
					= RIFServiceMessages.getMessage(
						"sqlResultsQueryManager.error.nonExistentGeoLevelAttributeTheme",
						geoLevelAttributeTheme.getDisplayName(),
						studyResultRetrievalContext.getGeographyName(),
						studyResultRetrievalContext.getGeoLevelSelectName());
				RIFServiceException rifServiceException
					= new RIFServiceException(
						RIFServiceError.NON_EXISTENT_GEO_LEVEL_ATTRIBUTE_THEME,
						errorMessage);
				throw rifServiceException;
			}
		}
		catch(SQLException sqlException) {
			logSQLException(sqlException);
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.error.unableToCheckGeoLevelAttributeThemeExists",
					geoLevelAttributeTheme.getDisplayName(),
					studyResultRetrievalContext.getGeographyName(),
					studyResultRetrievalContext.getGeoLevelSelectName());
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED, 
					errorMessage);
			throw rifServiceException;
		}
		finally {
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);
		}
		
	}
	
	public RIFResultTable getPyramidData(
		final Connection connection,
		final User user,
		final StudyResultRetrievalContext studyResultRetrievalContext,
		final GeoLevelAttributeSource geoLevelSource,
		final String geoLevelAttribute) 
		throws RIFServiceException {
		
		RIFResultTable result = new RIFResultTable();
		return result;		
	}	
	
	public RIFResultTable getPyramidDataByYear(
		Connection connection,
		User user,
		StudyResultRetrievalContext studyResultRetrievalContext,
		GeoLevelAttributeSource geoLevelSource,
		String geoLevelAttribute,
		Integer year) 
		throws RIFServiceException {
		
		RIFResultTable result = new RIFResultTable();
		
		
		
		return result;
	}
	
	public RIFResultTable getPyramidDataByMapAreas(
		Connection connection,
		User user,
		StudyResultRetrievalContext studyResultRetrievalContext,
		GeoLevelAttributeSource geoLevelSource,
		String geoLevelAttribute,
		ArrayList<MapArea> mapAreas) 
		throws RIFServiceException {
	
		RIFResultTable results = new RIFResultTable();
		
		
		return results;
	}
	
	public String[] getResultFieldsStratifiedByAgeGroup(
		Connection connection,
		User user,
		StudyResultRetrievalContext studyResultRetrievalContext,
		GeoLevelAttributeSource geoLevelAttributeSource)
		throws RIFServiceException {
	
		String[] results = new String[0];
	
		
		return results;
	}
	
	public RIFResultTable getSMRValues(
		Connection connection,
		User user,
		DiseaseMappingStudy diseaseMappingStudy)
		throws RIFServiceException {
	
		diseaseMappingStudy.checkErrors();
		
		RIFResultTable results = new RIFResultTable();
		/*
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		
		try {
			statement 
				= connection.prepareStatement(query.toString());
			resultSet = statement.executeQuery();

	
			//Obtain the column names
			ResultSetMetaData resultSetMetaData
				= resultSet.getMetaData();
			int numberOfColumns = resultSetMetaData.getColumnCount();
			String[] resultFieldNames = new String[numberOfColumns];
			for (int i = 0; i < resultFieldNames.length; i++) {
				resultFieldNames[i] = resultSetMetaData.getColumnName(i+1);
			}
			results.setFieldNames(resultFieldNames);
			
			//Obtain the data
			int totalResultRows = 0;
			String[][] resultsBlockData
				= new String[totalResultRows][resultFieldNames.length];
			
			int ithRow = 0;
			while (resultSet.next()) {
				for (int i = 1; i < resultFieldNames.length; i++) {
					resultsBlockData[ithRow][i] = resultSet.getString(i + 1);
				}			
				ithRow = ithRow + 1;
			}
			results.setData(resultsBlockData);
		}
		catch(SQLException sqlException) {
			String errorMessage
				= RIFServiceMessages.getMessage(
					"");
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED,
					errorMessage);
			throw rifServiceException;
		}
		finally {
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);
		}
		*/
		return results;
	}
	
	
	public RIFResultTable getRRValues(
		Connection connection,
		User user,
		DiseaseMappingStudy diseaseMappingStudy)
		throws RIFServiceException {
				
		diseaseMappingStudy.checkErrors();
		
		RIFResultTable results = new RIFResultTable();
		/*
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		
		try {
			statement 
				= connection.prepareStatement(query.toString());
			resultSet = statement.executeQuery();

	
			//Obtain the column names
			ResultSetMetaData resultSetMetaData
				= resultSet.getMetaData();
			int numberOfColumns = resultSetMetaData.getColumnCount();
			String[] resultFieldNames = new String[numberOfColumns];
			for (int i = 0; i < resultFieldNames.length; i++) {
				resultFieldNames[i] = resultSetMetaData.getColumnName(i+1);
			}
			results.setFieldNames(resultFieldNames);
			
			//Obtain the data
			int totalResultRows = 0;
			String[][] resultsBlockData
				= new String[totalResultRows][resultFieldNames.length];
			
			int ithRow = 0;
			while (resultSet.next()) {
				for (int i = 1; i < resultFieldNames.length; i++) {
					resultsBlockData[ithRow][i] = resultSet.getString(i + 1);
				}			
				ithRow = ithRow + 1;
			}
			results.setData(resultsBlockData);
		}
		catch(SQLException sqlException) {
			String errorMessage
				= RIFServiceMessages.getMessage(
					"");
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED,
					errorMessage);
			throw rifServiceException;
		}
		finally {
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);
		}
		*/
		return results;		
	}

	public RIFResultTable getRRUnadjustedValues(
		Connection connection,
		User user,
		DiseaseMappingStudy diseaseMappingStudy)
		throws RIFServiceException {
				
		diseaseMappingStudy.checkErrors();
		
		RIFResultTable results = new RIFResultTable();
		/*
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		
		try {
			statement 
				= connection.prepareStatement(query.toString());
			resultSet = statement.executeQuery();

	
			//Obtain the column names
			ResultSetMetaData resultSetMetaData
				= resultSet.getMetaData();
			int numberOfColumns = resultSetMetaData.getColumnCount();
			String[] resultFieldNames = new String[numberOfColumns];
			for (int i = 0; i < resultFieldNames.length; i++) {
				resultFieldNames[i] = resultSetMetaData.getColumnName(i+1);
			}
			results.setFieldNames(resultFieldNames);
			
			//Obtain the data
			int totalResultRows = 0;
			String[][] resultsBlockData
				= new String[totalResultRows][resultFieldNames.length];
			
			int ithRow = 0;
			while (resultSet.next()) {
				for (int i = 1; i < resultFieldNames.length; i++) {
					resultsBlockData[ithRow][i] = resultSet.getString(i + 1);
				}			
				ithRow = ithRow + 1;
			}
			results.setData(resultsBlockData);
		}
		catch(SQLException sqlException) {
			String errorMessage
				= RIFServiceMessages.getMessage(
					"");
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED,
					errorMessage);
			throw rifServiceException;
		}
		finally {
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);
		}
		*/
		return results;		
	}
	
	public RIFResultTable getResultStudyGeneralInfo(
		Connection connection,
		User user,
		DiseaseMappingStudy diseaseMappingStudy)
		throws RIFServiceException {
	
		diseaseMappingStudy.checkErrors();
		
		RIFResultTable results = new RIFResultTable();
		
		/*
		PreparedStatement statement = null;
		ResultSet resultSet = null;		
		try {
			
		}
		catch(SQLException sqlException) {
			String errorMessage
				= RIFServiceMessages.getMessage(
					"");
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED,
					errorMessage);
			throw rifServiceException;			
		}
		finally {
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);			
		}
		*/
		return results;
	}

	public ArrayList<AgeGroup> getResultAgeGroups(
		final Connection connection,
		final User user,
		final StudyResultRetrievalContext studyResultRetrievalContext,
		final GeoLevelAttributeSource geoLevelAttributeSource,
		final String geoLevalAttribute)
		throws RIFServiceException {
		
		user.checkErrors();
		studyResultRetrievalContext.checkErrors();
		geoLevelAttributeSource.checkErrors();

		StringBuilder query = new StringBuilder();
		
		
		ArrayList<AgeGroup> results = new ArrayList<AgeGroup>();
		
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement = connection.prepareStatement(query.toString());
			resultSet = statement.executeQuery();
			
			while (resultSet.next()) {
				AgeGroup ageGroup = AgeGroup.newInstance();
				results.add(ageGroup);
			}
		}
		catch(SQLException sqlException) {
			String errorMessage
				= RIFServiceMessages.getMessage("");
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED, 
					errorMessage);
			throw rifServiceException;
		}
		finally {
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);
		}
		
		return results;
	}
		
	private String getStudyName(
		Connection connection,
		String studyID)
		throws RIFServiceException {
		
		SQLSelectQueryFormatter query
			= new SQLSelectQueryFormatter();
		query.addSelectField("study_name");
		query.addFromTable("rif40_studies");
		query.addWhereParameter("study_id");
		
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			statement 
				= connection.prepareStatement(query.generateQuery());
			statement.setInt(
				1, 
				Integer.valueOf(studyID));
			resultSet = statement.executeQuery();
			resultSet.next();
			return resultSet.getString(1);
		}
		catch(SQLException sqlException) {
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlResultsQueryManager.unableToGetStudyName",
					studyID);
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED,
					errorMessage);
			throw rifServiceException;
		}
		finally {
			SQLQueryUtility.close(statement);
			SQLQueryUtility.close(resultSet);
		}
		
	}
	
	
	
	
	// ==========================================
	// Section Interfaces
	// ==========================================

	// ==========================================
	// Section Override
	// ==========================================
}
