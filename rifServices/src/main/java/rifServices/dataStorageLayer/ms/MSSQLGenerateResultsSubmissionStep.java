package rifServices.dataStorageLayer.ms;

import rifServices.system.*;
import rifGenericLibrary.dataStorageLayer.*;
import rifGenericLibrary.dataStorageLayer.pg.PGSQLQueryUtility;
import rifGenericLibrary.system.RIFServiceException;
import rifGenericLibrary.system.RIFServiceExceptionFactory;
import rifGenericLibrary.util.RIFLogger;

import java.sql.*;

/**
 *
 *
 * <hr>
 * The Rapid Inquiry Facility (RIF) is an automated tool devised by SAHSU 
 * that rapidly addresses epidemiological and public health questions using 
 * routinely collected health and population data and generates standardised 
 * rates and relative risks for any given health outcome, for specified age 
 * and year ranges, for any given geographical area.
 *
 * <p>
 * Copyright 2017 Imperial College London, developed by the Small Area
 * Health Statistics Unit. The work of the Small Area Health Statistics Unit 
 * is funded by the Public Health England as part of the MRC-PHE Centre for 
 * Environment and Health. Funding for this project has also been received 
 * from the United States Centers for Disease Control and Prevention.  
 * </p>
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
 * @version
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

final class MSSQLGenerateResultsSubmissionStep 
	extends MSSQLAbstractSQLManager {

	
	// ==========================================
	// Section Constants
	// ==========================================

	private static final RIFLogger rifLogger = RIFLogger.getLogger();
	private static String lineSeparator = System.getProperty("line.separator");	
	
	// ==========================================
	// Section Properties
	// ==========================================
	
	// ==========================================
	// Section Construction
	// ==========================================

	/**
	 * Instantiates a new SQLRIF submission manager.
	 */
	public MSSQLGenerateResultsSubmissionStep(
		final RIFDatabaseProperties rifDatabaseProperties) {

		super(rifDatabaseProperties);		
		setEnableLogging(false);
	}

	// ==========================================
	// Section Accessors and Mutators
	// ==========================================
	
	/**
	 * submit rif study submission.
	 *
	 * @param connection the connection
	 * @param user the user
	 * @param rifStudySubmission the rif job submission
	 * @throws RIFServiceException the RIF service exception
	 */	

	public String performStep(
		final Connection connection,
		final String studyID)
		throws RIFServiceException {
				
		String result = null;
		CallableStatement runStudyStatement = null;
		PreparedStatement computeResultsStatement = null;
		PGSQLQueryUtility query=new PGSQLQueryUtility();
		ResultSet runStudyResultSet = null;
		ResultSet computeResultSet = null;
		boolean res;
		int rval=-1;
		String traceMessage = null;
		
		try {
			SQLGeneralQueryFormatter generalQueryFormatter = new SQLGeneralQueryFormatter();		
			//EXECUTE @rval=rif40.rif40_run_study <study id> <debug: 0/1> <rval>
			String stmt = "{call rif40.rif40_run_study(?, ?, ?)}";
			generalQueryFormatter.addQueryLine(1, stmt);

			logSQLQuery(
					"runStudy", 
					generalQueryFormatter,
					studyID);
			
			runStudyStatement
				= createPreparedCall(
					connection,
					stmt); /* This shoud be generalQueryFormatter but more work needs to be done
							  on Kev's layers to support CallableStatement; only String is supported */
			
			runStudyStatement.setInt(1, Integer.valueOf(studyID));
			runStudyStatement.setInt(2, 1);		
			runStudyStatement.registerOutParameter(3, java.sql.Types.INTEGER);
			
			rifLogger.info(this.getClass(), "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" + lineSeparator + 
				generalQueryFormatter.generateQuery() + lineSeparator + 
				"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
			
			res = runStudyStatement.execute();
			if (res) { // OK we has a resultSet
				runStudyResultSet=runStudyStatement.getResultSet();
				rval = runStudyResultSet.getInt(3);
				runStudyResultSet.next(); // No rows returned
			} // Need to handle no resultSet to retrieve rval
			else {
				rval = runStudyStatement.getInt(3);	
			}
		
			result = String.valueOf(rval);	
			
			query.printWarnings(runStudyStatement); // Print output from T-SQL
			
			PGSQLQueryUtility.commit(connection); 	
		}
		catch(SQLException sqlException) {
			//Record original exception, throw sanitised, human-readable version, print warning dialogs
			
			if (result == null) {
				result="NULL [EXCEPTION THROWN BY DB]";
				rval=-3;
			}
			
			traceMessage=query.printWarnings(runStudyStatement); // Print output from T-SQL
			if (traceMessage == null) {
				traceMessage="No trace from T-SQL Statement.";
			}	
			traceMessage = sqlException.getMessage() + lineSeparator + traceMessage; 
				
			logSQLException(sqlException);
			PGSQLQueryUtility.commit(connection);
			
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlRIFSubmissionManager.error.unableToRunStudy",
					studyID);
/* DO NOT RETHROW!
			rifLogger.error(
				MSSQLGenerateResultsSubmissionStep.class, 
				errorMessage, 
				sqlException);
			RIFServiceException rifServiceException
				= new RIFServiceException(
					RIFServiceError.DATABASE_QUERY_FAILED, 
					sqlException.getMessage());
 */		
	
		}
		finally {
		
			//Cleanup database resources			
			PGSQLQueryUtility.close(runStudyStatement);
			PGSQLQueryUtility.close(runStudyResultSet);
			PGSQLQueryUtility.close(computeResultsStatement);
			PGSQLQueryUtility.close(computeResultSet);
					
			if (result == null) {
				RIFServiceException rifServiceException
					= new RIFServiceException(
						RIFServiceError.DATABASE_QUERY_FAILED,
						"Study " + studyID + " had NULL result");
				throw rifServiceException;
			}
			
			if (rval == 1) {
				rifLogger.info(this.getClass(), "XXXXXXXXXX Study " + studyID + " ran OK XXXXXXXXXXXXXXXXXXXXXX");
			}
			else {
				rifLogger.info(this.getClass(), "XXXXXXXXXX Study " + studyID + " failed with code: " + result + 
					" XXXXXXXXXXXXXXXXXXXXXX");

				if (traceMessage == null) {
					traceMessage="No trace from T-SQL Statement.";
				}			
				RIFServiceExceptionFactory rifServiceExceptionFactory
					= new RIFServiceExceptionFactory();
				RIFServiceException rifServiceException = 
					rifServiceExceptionFactory.createExtractException(traceMessage);
				throw rifServiceException;	
			}
			
			return result;			
		}
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
