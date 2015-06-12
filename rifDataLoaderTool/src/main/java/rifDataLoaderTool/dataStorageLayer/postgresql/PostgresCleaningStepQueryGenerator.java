package rifDataLoaderTool.dataStorageLayer.postgresql;

import rifDataLoaderTool.businessConceptLayer.*;
import rifDataLoaderTool.system.RIFDataLoaderToolMessages;
import rifDataLoaderTool.system.RIFTemporaryTablePrefixes;
import rifGenericLibrary.dataStorageLayer.SQLDeleteRowsQueryFormatter;
import rifGenericLibrary.dataStorageLayer.SQLDeleteTableQueryFormatter;
import rifGenericLibrary.dataStorageLayer.SQLGeneralQueryFormatter;

import java.util.ArrayList;

/**
 * Contains methods that generate Postgres-specific SQL code that supports
 * the cleaning step.
 *
 * <hr>
 * Copyright 2014 Imperial College London, developed by the Small Area
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

public final class PostgresCleaningStepQueryGenerator 
	implements CleanWorkflowQueryGeneratorAPI {

	// ==========================================
	// Section Constants
	// ==========================================

	// ==========================================
	// Section Properties
	// ==========================================

	// ==========================================
	// Section Construction
	// ==========================================

	public PostgresCleaningStepQueryGenerator() {

	}

	// ==========================================
	// Section Accessors and Mutators
	// ==========================================

	
	/**
	 * This produces the query used for the first part of cleaning -- the part where
	 * error values are subsituted with corrections.  We should get a query that looks
	 * something like this:
	 * 
	 * <pre>
	 * CREATE TABLE tmp_numerator_table AS  
	 * SELECT (
	 *    row_number,
	 *    data_source,
	 *    nhs_number,
	 * 	  birth_date,
	 *    postal_code,
	 *    CASE
	 *       WHEN age="<0" THEN 0
	 *       ELSE age
	 *    END AS age,
	 *    CASE
	 *       WHEN sex='M' THEN 0;
	 *       WHEN sex='male' THEN 0;
	 *       WHEN sex='F' THEN 1;
	 *       WHEN sex='female' THEN 1;
	 *       WHEN sex='U' THEN 2;
	 *       WHEN sex='unknown' THEN 2;
	 *       ELSE sex;
	 * 	  END AS sex,
	 *    level1,
	 *    CASE
	 *       WHEN level2 = 'Man' THEN 'Manchester';
	 *       ELSE level2
	 *    END AS level2,
	 *    level3,
	 *    level4,
	 *    reg_exp(icd_1, ".", "") AS icd_1,
	 *    reg_exp(icd_2, ".", "") AS icd_2,
	 *    opcs_code_1,
	 *    CASE
	 *       WHEN total='unknown' THEN -1
	 *       ELSE total;
	 *    END AS total
	 * FROM
	 *    numerator_table;
	 * 
	 * </pre>
	 * @return
	 */
	
	public String generateSearchReplaceTableQuery(
		final CleanWorkflowConfiguration tableCleaningConfiguration) {
		
		/*
		 * Generates a search and replace table which will make changes according to
		 * one of three policies:
		 * (1) don't clean - preserves the original column field values
		 * (2) use cleaning rules - checks if the original value matches patterns for
		 * various search and replace cleaning rules
		 * (3) use cleaning function - passes original column field values to a routine
		 * 
		 * The resulting table is used in two ways:
		 * (1) It is used by the routine which generates the validation table of the cleaned
		 * data
		 * (2) It is used to produce an audit of fields which were altered.
		 */
		
		/*
		 * CREATE TABLE cln_srch_my_table_2001 AS 
		 * SELECT
		 *    data_source_id,
		 *    row_number,
		 *    address,
		 *    clean_uk_postal_code(postal_code, true) AS postal_code,
		 *    CASE
		 *    	WHEN sex ~ ^[mM] THEN '1'
		 *      WHEN sex ~ ^[fF] THEN '2'
		 *      ELSE sex //no cleaning functions match, pass original value 
		 *    END AS sex
		 * FROM
		 *    load_my_table_2001;
		 */
				
		SQLGeneralQueryFormatter queryFormatter = new SQLGeneralQueryFormatter();
		String commentLine1
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.searchReplaceQuery.comment1");
		queryFormatter.addCommentLine(commentLine1);
		queryFormatter.addUnderline();
		String commentLine2
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.searchReplaceQuery.comment2");
		queryFormatter.addCommentLine(commentLine2);
		String commentLine3
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.searchReplaceQuery.comment3");
		queryFormatter.addCommentLine(commentLine3);
		
		queryFormatter.addQueryPhrase(0, "CREATE TABLE ");
		
		String coreTableName 
			= tableCleaningConfiguration.getCoreTableName();
		String searchReplaceTableName
			= RIFTemporaryTablePrefixes.CLEAN_SEARCH_REPLACE.getTableName(coreTableName);
		queryFormatter.addQueryPhrase(searchReplaceTableName);
		queryFormatter.finishLine(" AS ");
		
		queryFormatter.addQueryLine(1, "SELECT ");
		queryFormatter.addQueryLine(2, "data_source_id,");
		queryFormatter.addQueryPhrase(2, "row_number");
		ArrayList<CleanWorkflowFieldConfiguration> fieldCleaningConfigurations
			= tableCleaningConfiguration.getIncludedFieldCleaningConfigurations();
		
		int numberTableFieldConfigurations = fieldCleaningConfigurations.size();
		
		for (int i = 0; i < numberTableFieldConfigurations; i++) {
			queryFormatter.finishLine(",");
			CleanWorkflowFieldConfiguration currentTableFieldConfiguration
				= fieldCleaningConfigurations.get(i);
			addSearchReplaceQueryFragment(
				queryFormatter,
				2,
				currentTableFieldConfiguration);
		}

		queryFormatter.finishLine();

		queryFormatter.addQueryLine(1, " FROM ");
		String loadTableName
			= RIFTemporaryTablePrefixes.LOAD.getTableName(
				tableCleaningConfiguration.getCoreTableName());
		queryFormatter.addQueryPhrase(2, loadTableName);
		queryFormatter.addQueryPhrase(";");

		
		//add a primary key to the new temporary table
		queryFormatter.addQueryPhrase(0, "ALTER TABLE ");
		queryFormatter.addQueryPhrase(searchReplaceTableName);
		queryFormatter.addQueryPhrase(" ADD PRIMARY KEY (data_source_id, row_number);");
		
		
		return queryFormatter.generateQuery();
	}

	private void addSearchReplaceQueryFragment(
		final SQLGeneralQueryFormatter queryFormatter,
		final int baseIndentationLevel,
		final CleanWorkflowFieldConfiguration fieldCleaningConfiguration) {
			
		String loadTableFieldName
			= fieldCleaningConfiguration.getLoadTableFieldName();
		String cleanedTableFieldName
			= fieldCleaningConfiguration.getCleanedTableFieldName();

		RIFDataTypeInterface rifDataType 
			= fieldCleaningConfiguration.getRifDataType();
		RIFFieldCleaningPolicy rifFieldCleaningPolicy
			= rifDataType.getFieldCleaningPolicy();
		
		
		if (rifFieldCleaningPolicy == RIFFieldCleaningPolicy.NO_CLEANING) {
			//pass the value back as is
			queryFormatter.addQueryPhrase(
				baseIndentationLevel,
				loadTableFieldName);
			queryFormatter.addQueryPhrase(" AS ");
			queryFormatter.addQueryPhrase(cleanedTableFieldName);
		}
		else if (rifFieldCleaningPolicy == RIFFieldCleaningPolicy.CLEANING_RULES) {
			//construct a case statement with an ordered list of cleaning rules
			
			ArrayList<CleaningRule> cleaningRules
				= rifDataType.getCleaningRules();
			if (cleaningRules.isEmpty()) {

				//pass the value back as is
				queryFormatter.addQueryPhrase(
					baseIndentationLevel,
					loadTableFieldName);
				queryFormatter.addQueryPhrase(" AS ");
				queryFormatter.addQueryPhrase(cleanedTableFieldName);
			}
			else {
				queryFormatter.addQueryPhrase(
					baseIndentationLevel,
					"CASE");
				queryFormatter.padAndFinishLine();
				
				for (CleaningRule cleaningRule : cleaningRules) {
					addWhenCleaningRuleAppliesStatement(
						queryFormatter,
						baseIndentationLevel + 1,
						fieldCleaningConfiguration,
						cleaningRule);
				}
				
				//if none of the cleaning rules apply then 
				//pass the original value back unchanged
				queryFormatter.addQueryPhrase(
					baseIndentationLevel + 1, 
					"ELSE ");
				queryFormatter.addQueryPhrase(loadTableFieldName);
				queryFormatter.padAndFinishLine();

				//finish off the CASE statement
				queryFormatter.addQueryPhrase(
					baseIndentationLevel,
					"END AS ");
				queryFormatter.addQueryPhrase(cleanedTableFieldName);
			}
		}
		else {
			//must be a cleaning function
			queryFormatter.addQueryPhrase(
				baseIndentationLevel, 
				rifDataType.getCleaningFunctionName());
			queryFormatter.addQueryPhrase("(");
			//first parameter is always the name of the field with the original value
			queryFormatter.addQueryPhrase(loadTableFieldName);
			queryFormatter.addQueryPhrase(",");
			
			//all subsequent parameters are provided by the data type
			//the method will return a phrase such as
			// ",30" for RIFYearType to indicate that if a two digit year ends in a year
			//of at least 30, it will be part of the 20th century four digit year.
			queryFormatter.addQueryPhrase(rifDataType.getCleaningFunctionParameterValues());
			queryFormatter.addQueryPhrase(") AS ");
			queryFormatter.addQueryPhrase(cleanedTableFieldName);
		}
		
	}
	
	public String generateValidationTableQuery(
		final CleanWorkflowConfiguration tableCleaningConfiguration) {

		/*
		 * Generates a validation table which will either have the original
		 * value in a field or 'rif_error'.  This table is used in two ways:
		 * (1) It is used by the routine used to generate the casting table
		 * (2) It is used to produce audited results of errors that have been
		 * encountered.
		 *
		 * CREATE TABLE cln_val_my_table_2001 AS
		 * SELECT
		 *    data_source_id,
		 *    row_number,
		 *    CASE
		 *       WHEN age ~ '^[0-9]+' THEN age
		 * 	     ELSE 'rif_error'
		 *    END AS age, //using validation rule
		 * 	  is_valid_uk_postal_code(postal_code, true) AS postal_code, //using validation function
		 *    address AS address //no validation
		 * FROM
		 *    cln_srch_my_table_2001   
		 * ALTER TABLE cln_val_my_table_2001 ADD PRIMARY KEY(data_source_id, row_number);
		 *
		 *
		 */
		
		SQLGeneralQueryFormatter queryFormatter = new SQLGeneralQueryFormatter();
		String queryCommentLine1
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.validationQuery.comment1");
		queryFormatter.addCommentLine(queryCommentLine1);
		queryFormatter.addUnderline();
		String queryCommentLine2
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.validationQuery.comment2");
		queryFormatter.addCommentLine(queryCommentLine2);
			
		queryFormatter.addQueryPhrase(0, "CREATE TABLE ");
		
		String coreTableName 
			= tableCleaningConfiguration.getCoreTableName();
		String validationTableName
			= RIFTemporaryTablePrefixes.CLEAN_VALIDATION.getTableName(coreTableName);
		String searchReplaceTableName
			= RIFTemporaryTablePrefixes.CLEAN_SEARCH_REPLACE.getTableName(coreTableName);
		queryFormatter.addQueryPhrase(validationTableName);
		queryFormatter.finishLine(" AS ");
		
		queryFormatter.addQueryLine(1, "SELECT ");
		queryFormatter.addQueryLine(2, "data_source_id,");
		queryFormatter.addQueryPhrase(2, "row_number");
		ArrayList<CleanWorkflowFieldConfiguration> fieldCleaningConfigurations
			= tableCleaningConfiguration.getIncludedFieldCleaningConfigurations();
		
		int numberTableFieldConfigurations = fieldCleaningConfigurations.size();
		
		for (int i = 0; i < numberTableFieldConfigurations; i++) {
			queryFormatter.finishLine(",");
		
			CleanWorkflowFieldConfiguration currentTableFieldConfiguration
				= fieldCleaningConfigurations.get(i);
			addValidationQueryFragment(
				queryFormatter,
				2,
				currentTableFieldConfiguration);
		}	
		queryFormatter.finishLine();
		queryFormatter.addQueryLine(1, "FROM");
		queryFormatter.addQueryPhrase(2, searchReplaceTableName);
		queryFormatter.addQueryPhrase(";");
		queryFormatter.finishLine();
		
		return queryFormatter.generateQuery();		
	}	
	
	private void addValidationQueryFragment(
		final SQLGeneralQueryFormatter queryFormatter,
		final int baseIndentationLevel,
		final CleanWorkflowFieldConfiguration fieldConfiguration) {

		/*
		 * Will produce result of the format
		 * 
		 * CASE
		 * 		WHEN field ~ <validation expression>
		 * 		WHEN field ~ <validation expression>
		 * 		...
		 *  	WHEN field='' THEN field //allow blank values	
		 *  	ELSE 'rif_error'
		 * END
		 *  
		 */
		RIFDataTypeInterface rifDataType = fieldConfiguration.getRifDataType();
		RIFFieldValidationPolicy fieldValidationPolicy
			= rifDataType.getFieldValidationPolicy();
		
		String cleanedFieldName
			= fieldConfiguration.getCleanedTableFieldName();
		if (fieldValidationPolicy == RIFFieldValidationPolicy.NO_VALIDATION) {
			queryFormatter.addQueryPhrase(cleanedFieldName);
			queryFormatter.padAndFinishLine();
		}
		else if (fieldValidationPolicy == RIFFieldValidationPolicy.VALIDATION_FUNCTION) {
			queryFormatter.addQueryPhrase(rifDataType.getValidationFunctionName());
			queryFormatter.addQueryPhrase("(");
			queryFormatter.addQueryPhrase(cleanedFieldName);
			queryFormatter.addQueryPhrase(",");
			queryFormatter.addQueryPhrase(String.valueOf(fieldConfiguration.allowBlankValues()));
			queryFormatter.addQueryPhrase(rifDataType.getValidationFunctionParameterValues());
			queryFormatter.addQueryPhrase(") AS ");
			queryFormatter.addQueryPhrase(cleanedFieldName);
			queryFormatter.padAndFinishLine();
		}
		else if (fieldValidationPolicy == RIFFieldValidationPolicy.VALIDATION_RULES) {
		
			ArrayList<String> validationExpressions
				= rifDataType.getValidationExpressions();
		
			queryFormatter.addQueryPhrase(baseIndentationLevel, "CASE");
			queryFormatter.padAndFinishLine();
		
			if (rifDataType instanceof DateRIFDataType) {
				for (String validationExpression : validationExpressions) {
					queryFormatter.addQueryPhrase(baseIndentationLevel + 1, "WHEN ");
					queryFormatter.addQueryPhrase("is_valid_date(");
					queryFormatter.addQueryPhrase(cleanedFieldName);
					queryFormatter.addQueryPhrase(",");
					queryFormatter.addQueryPhrase("'");
					queryFormatter.addQueryPhrase(validationExpression);
					queryFormatter.addQueryPhrase("') = TRUE THEN ");
					queryFormatter.addQueryPhrase(cleanedFieldName);
					queryFormatter.padAndFinishLine();
				}
			}
			else {
				for (String validationExpression : validationExpressions) {
					queryFormatter.addQueryPhrase(baseIndentationLevel + 1, "WHEN ");
					queryFormatter.addQueryPhrase(cleanedFieldName);
					queryFormatter.addQueryPhrase(" ~ ");
					queryFormatter.addQueryPhrase("'");
					queryFormatter.addQueryPhrase(validationExpression);
					queryFormatter.addQueryPhrase("'");
					queryFormatter.addQueryPhrase(" THEN ");
					queryFormatter.addQueryPhrase(cleanedFieldName);
					queryFormatter.padAndFinishLine();
				}
			}
			
			
			if (fieldConfiguration.allowBlankValues()) {
				queryFormatter.addQueryPhrase(baseIndentationLevel + 1, "WHEN ");
				queryFormatter.addQueryPhrase(cleanedFieldName);
				queryFormatter.addQueryPhrase(" ='' ");
				queryFormatter.addQueryPhrase("THEN ");
				queryFormatter.addQueryPhrase(cleanedFieldName);
				String allowBlankValuesMessage
					= RIFDataLoaderToolMessages.getMessage("sqlQuery.comment.allowBlankValues");
				queryFormatter.addComment(allowBlankValuesMessage);		
				queryFormatter.padAndFinishLine();
			}	
		
			//does not fit any of the regular expressions, therefore is not valid
			queryFormatter.addQueryPhrase(baseIndentationLevel + 1, "ELSE 'rif_error'");
			queryFormatter.padAndFinishLine();

			queryFormatter.addQueryPhrase(baseIndentationLevel, "END AS ");
			queryFormatter.addQueryPhrase(cleanedFieldName);
		}

	}

		
	public String generateDropValidationTableQuery(
		final CleanWorkflowConfiguration tableCleaningConfiguration) {

		SQLDeleteTableQueryFormatter queryFormatter
			= new SQLDeleteTableQueryFormatter();
		String queryCommentLine1
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.dropValidationQuery.comment1");		
		queryFormatter.addCommentLine(queryCommentLine1);
		queryFormatter.addUnderline();
		String queryCommentLine2
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.dropValidationQuery.comment2");
		queryFormatter.addCommentLine(queryCommentLine2);

		String validationTableName
			= RIFTemporaryTablePrefixes.CLEAN_VALIDATION.getTableName(
				tableCleaningConfiguration.getCoreTableName());	
		queryFormatter.setTableToDelete(validationTableName);
			
		return queryFormatter.generateQuery();		
	}
		
	public String generateDeleteAuditsQuery(
		final CleanWorkflowConfiguration tableCleaningConfiguration) {
		
		/*
		 * DELETE FROM rif_audit_table
		 * WHERE
		 *    data_source_id=?;
		 */
		SQLDeleteRowsQueryFormatter queryFormatter = new SQLDeleteRowsQueryFormatter();
		String queryCommentLine1
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.deleteAuditsQuery.comment1");		
		queryFormatter.addCommentLine(queryCommentLine1);
		queryFormatter.addUnderline();
		String queryCommentLine2
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.deleteAuditsQuery.comment2");		
		queryFormatter.addCommentLine(queryCommentLine2);
		
		queryFormatter.setFromTable("rif_audit_table");
		queryFormatter.addWhereParameter("data_source_id");
		
		return queryFormatter.generateQuery();
	}
	
	public String generateAuditChangesQuery(
		final CleanWorkflowConfiguration tableCleaningConfiguration) {
		
		
		/*
		 * We may need a new generic auditing table.  Here's the code
		 * 
		 * CREATE TABLE rif_audit_table (
		 *    data_source_id INT NOT NULL,
		 *    row_number INT NOT NULL,
		 *    event_type VARCHAR(30) NOT NULL,
		 *    field_name VARCHAR(30),
		 *    time_stamp TIMESTAMP DEFAULT current_timestamp);  
		 */
		
		
		/*
		 * We start with a 'with' statement that creates a holder for a table
		 * that records whether changes were made.
		 * 
		 * eg: clean_scores could look like:
		 * 
		 * data_source_id	row_number	age		postal_code		year	...
		 * 1				1			0		0				1
		 * 1				2			1		0				1
		 * 1				3			1		1				0
		 * 1				4			1		1				1
		 * 
		 * notice how the query is designed to only hold audits where at least one
		 * change was made.  Hopefully this means that many of the rows in the data set
		 * will not be included.
		 * 
		 * The goal is to add changes to the table here: 
		 * 
		 * data_source_id	row_number	outcome_type	field_name
		 * 1				1			1				year
		 * 1				2			1				age
		 * 1				2			1				year
		 * 1				3			1				age
		 * 1				3			1				postal_code
		 * 
		 * Here we assume an outcome type of '1' indicates a value was changed
		 * 
		 */
		
		/*
		 * 
		 * WITH changed_scores =
		 * (SELECT
		 *    load_my_table_2001.data_source_id,
		 *    load_my_table_2001.row_number,
		 *    CASE
		 *       WHEN load_my_table_2001.age=cln_srch_my_table_2001.age THEN 0
		 *       ELSE 1
		 *    END AS age,
		 *    CASE
		 *       WHEN load_my_table_2001.postal_code=cln_srch_my_table_2001.postal_code THEN 0
		 *       ELSE 1
		 *    END AS postal_code,
		 *    
		 *    ...
		 *    ...
		 * FROM
		 *    load_my_table_2001,
		 *    cln_val_my_table_2001
		 * WHERE
		 *   load_my_table_2001.data_source_id=cln_val_my_table_2001.data_source_id AND
		 *   load_my_table_2001.row_number=cln_val_my_table_2001.row_number
		 *   
		 *   
		 * INSERT_INTO cln_aud_my_table_2001 
		 * (data_source_id,
		 *  row_number,
		 *  change_type,
		 *  field_name,
		 *  audit_time_stamp)
		 *  FROM
		 *  (SELECT 
		 *     data_source_id,
		 *     row_number,
		 *     1, //value changed
		 *     'age'
		 *   FROM
		 *      changed_scores
		 *   WHERE
		 *      age = 1)
		 *   UNION
		 *   SELECT
		 *      data_source_id,
		 *      row_number,
		 *      1, //value changed
		 *      'postal_code'
		 *   FROM
		 *      changed_scores
		 *   UNION
		 *   ... 
		 *   
		 */   
		
		
		String coreTableName 
			= tableCleaningConfiguration.getCoreTableName();
		String loadTableName
			= RIFTemporaryTablePrefixes.LOAD.getTableName(coreTableName);
		String searchReplaceTableName
			= RIFTemporaryTablePrefixes.CLEAN_SEARCH_REPLACE.getTableName(coreTableName);
		ArrayList<CleanWorkflowFieldConfiguration> fieldConfigurations
			= tableCleaningConfiguration.getIncludedFieldCleaningConfigurations();
		int numberOfFieldConfigurations = fieldConfigurations.size();
		
		SQLGeneralQueryFormatter queryFormatter = new SQLGeneralQueryFormatter();
		
		String queryCommentLine1
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.addChangeAudits.comment1");		
		queryFormatter.addCommentLine(queryCommentLine1);
		queryFormatter.addUnderline();
		String queryCommentLine2
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.addChangeAudits.comment2");		
		queryFormatter.addCommentLine(queryCommentLine2);
		String queryCommentLine3
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.addChangeAudits.comment3");		
		queryFormatter.addCommentLine(queryCommentLine3);
		
		queryFormatter.addQueryPhrase(0, "WITH ");
		//do we need another table prefix????
		queryFormatter.addQueryPhrase("change_indicators AS");
		queryFormatter.padAndFinishLine();
		queryFormatter.addQueryPhrase(1, "(SELECT");
		queryFormatter.padAndFinishLine();
		queryFormatter.addQueryPhrase(2, "loadTable.data_source_id,");
		queryFormatter.finishLine();
		queryFormatter.addQueryPhrase(2, "loadTable.row_number");

		for (CleanWorkflowFieldConfiguration fieldConfiguration : fieldConfigurations) {
			
			/*
			 * This part is adding the query fragment like:
			 * 
			 * ,CASE
			 *    WHEN loadTable.age = searchReplaceTable.age THEN 0
			 *    ELSE 1
			 * END AS age
			 * 
			 */
			
			String loadTableFieldName = fieldConfiguration.getLoadTableFieldName();
			String cleanedTableFieldName = fieldConfiguration.getCleanedTableFieldName();
			
			queryFormatter.finishLine(",");
			queryFormatter.addQueryPhrase(2, "CASE");
			queryFormatter.padAndFinishLine();
			queryFormatter.addQueryPhrase(3, "WHEN ");
			queryFormatter.addQueryPhrase("loadTable.");
			queryFormatter.addQueryPhrase(loadTableFieldName);
			queryFormatter.addQueryPhrase(" = ");
			queryFormatter.addQueryPhrase("searchReplaceTable.");
			queryFormatter.addQueryPhrase(cleanedTableFieldName);
			queryFormatter.addQueryPhrase(" THEN 0");
			queryFormatter.padAndFinishLine();
			queryFormatter.addQueryPhrase(3, "ELSE 1");
			queryFormatter.padAndFinishLine();
			queryFormatter.addQueryPhrase(2, "END AS ");
			queryFormatter.addQueryPhrase(cleanedTableFieldName);
		}
		
		queryFormatter.padAndFinishLine();
		queryFormatter.addQueryPhrase(1, "FROM");
		queryFormatter.padAndFinishLine();
		queryFormatter.addQueryPhrase(2, loadTableName);
		queryFormatter.addQueryPhrase(" loadTable,");
		queryFormatter.finishLine();
		queryFormatter.addQueryPhrase(2, searchReplaceTableName);
		queryFormatter.addQueryPhrase(" searchReplaceTable");
		queryFormatter.padAndFinishLine();
		queryFormatter.addQueryPhrase(1, "WHERE");
		queryFormatter.padAndFinishLine();
		queryFormatter.addQueryPhrase(2, "loadTable.data_source_id = ");
		queryFormatter.addQueryPhrase("searchReplaceTable.data_source_id AND");
		queryFormatter.padAndFinishLine();
		queryFormatter.addQueryPhrase(2, "loadTable.row_number = ");
		queryFormatter.addQueryPhrase("searchReplaceTable.row_number)");
		queryFormatter.padAndFinishLine();
		
		//now that we've created the with table, we can use it.  
		queryFormatter.addQueryPhrase(0, "INSERT INTO ");
		queryFormatter.addQueryPhrase("rif_audit_table (");
		queryFormatter.padAndFinishLine();
		queryFormatter.addQueryLine(1, "data_source_id,");
		queryFormatter.addQueryLine(1, "row_number,");
		queryFormatter.addQueryLine(1, "event_type,");
		queryFormatter.addQueryLine(1, "field_name) (");
		
		for (int i = 0; i < numberOfFieldConfigurations; i++) {
			
			/*
			 * Produces this kind of fragment
			 * 
			 * UNION
			 * SELECT
			 *    data_source_id,
			 *    row_number,
			 *    'value_changed',
			 *    'age'
			 * FROM
			 *    change_indicators
			 * WHERE
			 *    age = 1
			 */
			
			if (i != 0) {
				queryFormatter.addQueryPhrase(1, "UNION");
				queryFormatter.padAndFinishLine();
			}
			
			CleanWorkflowFieldConfiguration fieldConfiguration
				= fieldConfigurations.get(i);
			String cleanTableFieldName
				= fieldConfiguration.getCleanedTableFieldName();
			
			queryFormatter.addQueryPhrase(1, "SELECT");
			queryFormatter.padAndFinishLine();
			queryFormatter.addQueryLine(2, "data_source_id,");
			queryFormatter.addQueryLine(2, "row_number,");
			queryFormatter.addQueryLine(2, "'value_changed' AS event_type,");
			queryFormatter.addQueryPhrase(2, "'");
			queryFormatter.addQueryPhrase(cleanTableFieldName);
			queryFormatter.addQueryPhrase("' AS field_name");
			queryFormatter.padAndFinishLine();
			queryFormatter.addQueryPhrase(1, "FROM");
			queryFormatter.padAndFinishLine();
			queryFormatter.addQueryPhrase(2, "change_indicators");
			queryFormatter.padAndFinishLine();
			queryFormatter.addQueryPhrase(1, "WHERE");			
			queryFormatter.padAndFinishLine();
			queryFormatter.addQueryPhrase(2, cleanTableFieldName);
			queryFormatter.addQueryPhrase(" = 1");
			queryFormatter.padAndFinishLine();
		}
		
		
		queryFormatter.addQueryPhrase(0, ");");
		queryFormatter.finishLine();
		return queryFormatter.generateQuery();
	}
	
	
	public String generateAuditErrorsQuery(
		final CleanWorkflowConfiguration tableCleaningConfiguration) {

		String coreTableName 
			= tableCleaningConfiguration.getCoreTableName();
		String loadTableName
			= RIFTemporaryTablePrefixes.LOAD.getTableName(coreTableName);
		String cleanValidationTableName
			= RIFTemporaryTablePrefixes.CLEAN_VALIDATION.getTableName(coreTableName);
		ArrayList<CleanWorkflowFieldConfiguration> fieldConfigurations
			= tableCleaningConfiguration.getIncludedFieldCleaningConfigurations();
		int numberOfFieldConfigurations = fieldConfigurations.size();
		
		SQLGeneralQueryFormatter queryFormatter = new SQLGeneralQueryFormatter();

		String queryCommentLine1
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.addErrorAudits.comment1");		
		queryFormatter.addCommentLine(queryCommentLine1);
		queryFormatter.addUnderline();
		String queryCommentLine2
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.addErrorAudits.comment2");		
		queryFormatter.addCommentLine(queryCommentLine2);
		String queryCommentLine3
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.addErrorAudits.comment3");		
		queryFormatter.addCommentLine(queryCommentLine3);		
		
		queryFormatter.addQueryPhrase(0, "INSERT INTO ");
		queryFormatter.addQueryPhrase("rif_audit_table (");
		queryFormatter.padAndFinishLine();
		queryFormatter.addQueryLine(1, "data_source_id,");
		queryFormatter.addQueryLine(1, "row_number,");
		queryFormatter.addQueryLine(1, "event_type,");
		queryFormatter.addQueryLine(1, "field_name) (");
		
		for (int i = 0; i < numberOfFieldConfigurations; i++) {
			
			/*
			 * Produces this kind of fragment
			 * 
			 * UNION
			 * SELECT
			 *    data_source_id,
			 *    row_number,
			 *    'error',
			 *    'age'
			 * FROM
			 *    change_indicators
			 * WHERE
			 *    age = 'rif_error'
			 */
			
			if (i != 0) {
				queryFormatter.addQueryPhrase(1, "UNION");
				queryFormatter.padAndFinishLine();
			}
			
			CleanWorkflowFieldConfiguration fieldConfiguration
				= fieldConfigurations.get(i);
			String cleanTableFieldName
				= fieldConfiguration.getCleanedTableFieldName();
			
			queryFormatter.addQueryPhrase(1, "SELECT");
			queryFormatter.padAndFinishLine();
			queryFormatter.addQueryLine(2, "data_source_id,");
			queryFormatter.addQueryLine(2, "row_number,");
			queryFormatter.addQueryLine(2, "'error',");
			queryFormatter.addQueryPhrase(2, "'");
			queryFormatter.addQueryPhrase(cleanTableFieldName);
			queryFormatter.addQueryPhrase("' AS field_name");			
			queryFormatter.padAndFinishLine();
			queryFormatter.addQueryPhrase(1, "FROM");
			queryFormatter.padAndFinishLine();
			queryFormatter.addQueryPhrase(2, cleanValidationTableName);
			queryFormatter.padAndFinishLine();
			queryFormatter.addQueryPhrase(1, "WHERE");			
			queryFormatter.padAndFinishLine();
			queryFormatter.addQueryPhrase(2, cleanTableFieldName);
			queryFormatter.addQueryPhrase(" = 'rif_error'");
			queryFormatter.padAndFinishLine();
		}
				
		queryFormatter.addQueryPhrase(0, ");");
		queryFormatter.finishLine();
		return queryFormatter.generateQuery();
	}
		
	public String generateAuditBlanksQuery(
		final CleanWorkflowConfiguration tableCleaningConfiguration) {

		String coreTableName 
			= tableCleaningConfiguration.getCoreTableName();
		String loadTableName
			= RIFTemporaryTablePrefixes.LOAD.getTableName(coreTableName);
		String cleanValidationTableName
			= RIFTemporaryTablePrefixes.CLEAN_SEARCH_REPLACE.getTableName(coreTableName);
		ArrayList<CleanWorkflowFieldConfiguration> fieldConfigurations
			= tableCleaningConfiguration.getIncludedFieldCleaningConfigurations();
		int numberOfFieldConfigurations = fieldConfigurations.size();

		SQLGeneralQueryFormatter queryFormatter = new SQLGeneralQueryFormatter();
		String queryCommentLine1
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.addBlankAudits.comment1");		
		queryFormatter.addCommentLine(queryCommentLine1);
		queryFormatter.addUnderline();
		String queryCommentLine2
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.addBlankAudits.comment2");		
		queryFormatter.addCommentLine(queryCommentLine2);
		String queryCommentLine3
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.addBlankAudits.comment3");		
		queryFormatter.addCommentLine(queryCommentLine3);		
		
		queryFormatter.addQueryPhrase(0, "INSERT INTO ");
		queryFormatter.addQueryPhrase("rif_audit_table (");
		queryFormatter.padAndFinishLine();
		queryFormatter.addQueryLine(1, "data_source_id,");
		queryFormatter.addQueryLine(1, "row_number,");
		queryFormatter.addQueryLine(1, "event_type,");
		queryFormatter.addQueryLine(1, "field_name) (");
		
		for (int i = 0; i < numberOfFieldConfigurations; i++) {
			
			/*
			 * Produces this kind of fragment
			 * 
			 * UNION
			 * SELECT
			 *    data_source_id,
			 *    row_number,
			 *    'blank',
			 *    'age'
			 * FROM
			 *    change_indicators
			 * WHERE
			 *    age = ''
			 */
			
			if (i != 0) {
				queryFormatter.addQueryPhrase(1, "UNION");
				queryFormatter.padAndFinishLine();
			}
			
			CleanWorkflowFieldConfiguration fieldConfiguration
				= fieldConfigurations.get(i);
			String cleanTableFieldName
				= fieldConfiguration.getCleanedTableFieldName();
			
			queryFormatter.addQueryPhrase(1, "SELECT");
			queryFormatter.padAndFinishLine();
			queryFormatter.addQueryLine(2, "data_source_id,");
			queryFormatter.addQueryLine(2, "row_number,");
			queryFormatter.addQueryLine(2, "'blank',");
			queryFormatter.addQueryPhrase(2, "'");
			queryFormatter.addQueryPhrase(cleanTableFieldName);
			queryFormatter.addQueryPhrase("' AS field_name");			
			queryFormatter.padAndFinishLine();
			queryFormatter.addQueryPhrase(1, "FROM");
			queryFormatter.padAndFinishLine();
			queryFormatter.addQueryPhrase(2, cleanValidationTableName);
			queryFormatter.padAndFinishLine();
			queryFormatter.addQueryPhrase(1, "WHERE");			
			queryFormatter.padAndFinishLine();
			queryFormatter.addQueryPhrase(2, cleanTableFieldName);
			queryFormatter.addQueryPhrase(" = ''");
			queryFormatter.padAndFinishLine();
		}
				
		queryFormatter.addQueryPhrase(0, ");");
		queryFormatter.finishLine();
		return queryFormatter.generateQuery();
	}
	

	
	
	
	
	
	
	
	
	
	
	
	/*
	private void addWhenBlankStatement(
		final SQLGeneralQueryFormatter queryFormatter,
		final int baseIndentationLevel,	
		final TableFieldCleaningConfiguration fieldCleaningConfiguration) {

		StringBuilder queryFragment = new StringBuilder();
		String loadTableFieldName
			= fieldCleaningConfiguration.getLoadTableFieldName();
		
		queryFormatter.addQueryPhrase(baseIndentationLevel + 1, "WHEN ");
		queryFormatter.addQueryPhrase(loadTableFieldName);
		queryFormatter.addQueryPhrase(" ='' ");
		queryFormatter.addQueryPhrase("THEN ");
		queryFormatter.addQueryPhrase(loadTableFieldName);
		
		String allowBlankValuesMessage
			= RIFDataLoaderToolMessages.getMessage("sqlQuery.comment.allowBlankValues");
		queryFormatter.addLineComment(allowBlankValuesMessage);		
		
		
		
		queryFormatter.padAndFinishLine();
	}
	*/

	/*
	private void addWhenValidStatement(
		final SQLGeneralQueryFormatter queryFormatter,
		final int baseIndentationLevel,
		final TableFieldCleaningConfiguration fieldCleaningConfiguration) {
		
		String loadTableFieldName
			= fieldCleaningConfiguration.getLoadTableFieldName();
		
		RIFDataType rifDataType = fieldCleaningConfiguration.getRifDataType();
		if (rifDataType instanceof DateRIFDataType) {
			//follows format of special date format characters that
			//are appropriate for Postgresql functions
			String dateFormat
				= rifDataType.getValidationRegularExpression();

			boolean allowBlankValues
				= fieldCleaningConfiguration.allowBlankValues();
			
			queryFormatter.addQueryPhrase(baseIndentationLevel + 1, "WHEN ");
			queryFormatter.addQueryPhrase("is_valid_date(");
			queryFormatter.addQueryPhrase(loadTableFieldName);
			queryFormatter.addQueryPhrase(",");
			queryFormatter.addQueryPhrase("'");
			queryFormatter.addQueryPhrase(dateFormat);
			queryFormatter.addQueryPhrase("'");
			queryFormatter.addQueryPhrase(",");
			queryFormatter.addQueryPhrase(String.valueOf(allowBlankValues));
			queryFormatter.addQueryPhrase(") = TRUE THEN ");
			queryFormatter.addQueryPhrase(loadTableFieldName);
		}
		else {
			queryFormatter.addQueryPhrase(baseIndentationLevel + 1, "WHEN ");
			queryFormatter.addQueryPhrase(loadTableFieldName);
			queryFormatter.addQueryPhrase(" ~ '");
			queryFormatter.addQueryPhrase(rifDataType.getValidationRegularExpression());		
			queryFormatter.addQueryPhrase("'");
			queryFormatter.addQueryPhrase(" THEN ");
			queryFormatter.addQueryPhrase(loadTableFieldName);
		}
		
		String compliesWithValidationRulesMessage
			= RIFDataLoaderToolMessages.getMessage("sqlQuery.comment.compliesWithValidationRules");
		queryFormatter.addLineComment(compliesWithValidationRulesMessage);		
		
		queryFormatter.padAndFinishLine();
	}
	*/
	
	/*
	private void addElseUnrecognisedStatement(
		final SQLGeneralQueryFormatter queryFormatter,
		final int baseIndentationLevel) {
		queryFormatter.addQueryPhrase(
			baseIndentationLevel, 
			"ELSE ");
		queryFormatter.addQueryPhrase("'");
		
		queryFormatter.addQueryPhrase("rif_error");
		queryFormatter.addQueryPhrase("'");
		
		String failsValidationRulesMessage
			= RIFDataLoaderToolMessages.getMessage("sqlQuery.comment.failsValidationRules");
		queryFormatter.addLineComment(failsValidationRulesMessage);		
		queryFormatter.padAndFinishLine();
	}
	*/


	private void addWhenCleaningRuleAppliesStatement(
		final SQLGeneralQueryFormatter queryFormatter,
		final int baseIndentationLevel,
		final CleanWorkflowFieldConfiguration fieldCleaningConfiguration,		
		final CleaningRule cleaningRule) {
		
		String fieldName
			= fieldCleaningConfiguration.getCleanedTableFieldName();
		
		queryFormatter.addQueryPhrase(baseIndentationLevel, "WHEN ");
		queryFormatter.addQueryPhrase(fieldName);
		
		if (cleaningRule.isRegularExpressionSearch()) {
			//regular expression substitution
			queryFormatter.addQueryPhrase(" ~ ");
			queryFormatter.addQueryPhrase("'");
			queryFormatter.addQueryPhrase(cleaningRule.getSearchValue());
			queryFormatter.addQueryPhrase("'");
		}
		else {
			//simple substitution
			//WHEN field=X THEN Y
			queryFormatter.addQueryPhrase("=");
			queryFormatter.addQueryPhrase("'");
			queryFormatter.addQueryPhrase(cleaningRule.getSearchValue());
			queryFormatter.addQueryPhrase("'");
		}
		queryFormatter.addQueryPhrase(" THEN ");
		queryFormatter.addQueryPhrase("'");
		queryFormatter.addQueryPhrase(cleaningRule.getReplaceValue());
		queryFormatter.addQueryPhrase("'");
		
		String applyingCleaningRuleMessage
			= RIFDataLoaderToolMessages.getMessage("sqlQuery.comment.applyCleaningRule");
		queryFormatter.addComment(applyingCleaningRuleMessage);
		
		queryFormatter.padAndFinishLine();
	}
	
	public String generateDropSearchReplaceTableQuery(
		final CleanWorkflowConfiguration tableCleaningConfiguration) {

		SQLDeleteTableQueryFormatter queryFormatter = new SQLDeleteTableQueryFormatter();
		String queryCommentLine
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.dropSearchReplaceQuery.comments1");
		queryFormatter.addCommentLine(queryCommentLine);
		queryFormatter.addUnderline();
		
		String coreTableName = tableCleaningConfiguration.getCoreTableName();
		String searchReplaceTableName
			= RIFTemporaryTablePrefixes.CLEAN_SEARCH_REPLACE.getTableName(coreTableName);
		queryFormatter.setTableToDelete(searchReplaceTableName);

		return queryFormatter.generateQuery();		
	}
		
	/**
	 * We use this method in Part II of the cleaning activity.  By step II, we have already
	 * finished doing all the search and replace substitutions we want to do.  Here, we
	 * are trying to convert the modified text-based columns to their desired data type,
	 * such as INT, DOUBLE PRECISION etc.
	 * 
	 * <p>
	 * We are trying to generate a statement like:
	 * 
	 * <pre>
	 * CREATE TABLE cln_cast_my_table_2001 AS 
	 * SELECT
	 *    data_source_id,
	 *    row_number,
	 *    CASE
	 *       WHEN age IS NULL THEN NULL
	 *       WHEN age = 'rif_error' THEN NULL
	 *       ELSE cast(age AS INTEGER)
	 *    END AS age,
	 *    CASE
	 *       WHEN postal_code IS NULL THEN NULL
	 *       WHEN age = 'rif_error' THEN NULL
	 *       ELSE postal_code
	 *    END AS postal_code,
	 *    ...
	 * FROM
	 *    cln_val_my_table_2001;
	 * ALTER TABLE cln_cast_my_table_2001 ADD PRIMARY KEY(data_source_id, row_number);
	 * </pre>
	 * 
	 * @return
	 */
	
	public String generateCastingTableQuery(
		final CleanWorkflowConfiguration tableCleaningConfiguration) {
		
		SQLGeneralQueryFormatter queryFormatter = new SQLGeneralQueryFormatter();

		String queryCommentLine1
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.castQuery.comment1");
		queryFormatter.addCommentLine(queryCommentLine1);
		queryFormatter.addUnderline();
		String queryCommentLine2
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.castQuery.comment2");
		queryFormatter.addCommentLine(queryCommentLine2);
		String queryCommentLine3
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.castQuery.comment3");
		queryFormatter.addCommentLine(queryCommentLine3);
		String queryCommentLine4
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.castQuery.comment4");
		queryFormatter.addCommentLine(queryCommentLine4);
		String queryCommentLine5
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.castQuery.comment5");
		queryFormatter.addCommentLine(queryCommentLine5);

		queryFormatter.addQueryPhrase(0, "CREATE TABLE ");
		
		String coreTableName
			= tableCleaningConfiguration.getCoreTableName();
		String castingTableName
			= RIFTemporaryTablePrefixes.CLEAN_CASTING.getTableName(coreTableName);
		queryFormatter.addQueryPhrase(castingTableName);
		queryFormatter.addQueryPhrase(" AS ");
		queryFormatter.finishLine();
		
		queryFormatter.addQueryLine(1, "SELECT ");
		queryFormatter.addQueryLine(2, "data_source_id,");
		queryFormatter.addQueryLine(2, "row_number,");
		
		ArrayList<CleanWorkflowFieldConfiguration> fieldCleaningConfigurations
			= tableCleaningConfiguration.getIncludedFieldCleaningConfigurations();
		int numberTableFieldConfigurations = fieldCleaningConfigurations.size();
		for (int i = 0; i < numberTableFieldConfigurations; i++) {
			CleanWorkflowFieldConfiguration currentTableFieldConfiguration
				= fieldCleaningConfigurations.get(i);
			
			if (i != 0) {
				queryFormatter.addQueryPhrase(",");
				queryFormatter.finishLine();
			}
			addCastingQueryFragment(
				queryFormatter,
				2,
				currentTableFieldConfiguration);
		}		
		queryFormatter.finishLine();
		queryFormatter.addQueryLine(1, "FROM ");

		String searchReplaceTableName
			= RIFTemporaryTablePrefixes.CLEAN_VALIDATION.getTableName(coreTableName);
		queryFormatter.addQueryPhrase(2, searchReplaceTableName);
		queryFormatter.addQueryPhrase(";");
		queryFormatter.finishLine();

		//add a primary key to the new temporary table
		queryFormatter.addQueryPhrase(0, "ALTER TABLE ");
		queryFormatter.addQueryPhrase(castingTableName);
		queryFormatter.addQueryPhrase(" ADD PRIMARY KEY (data_source_id, row_number);");

		
		return queryFormatter.generateQuery();
	}

	private void addCastingQueryFragment(
		final SQLGeneralQueryFormatter queryFormatter,
		int baseIndentationLevel,
		final CleanWorkflowFieldConfiguration tableFieldCleaningConfiguration) {
		
		String cleanedTableFieldName
			= tableFieldCleaningConfiguration.getCleanedTableFieldName();
		RIFDataTypeInterface rifDataType
			= tableFieldCleaningConfiguration.getRifDataType();
		
		/*
		 * makes this kind of fragment:
		 * 
		 * CASE
		 *    WHEN age IS NULL THEN NULL
		 *    WHEN age = 'rif_error' THEN NULL
		 * 
		 */	
		queryFormatter.addQueryLine(baseIndentationLevel, "CASE ");		
		queryFormatter.addQueryPhrase(baseIndentationLevel + 1, "WHEN ");
		queryFormatter.addQueryPhrase(cleanedTableFieldName);
		queryFormatter.addQueryPhrase(" IS NULL THEN NULL ");
		queryFormatter.padAndFinishLine();
		queryFormatter.addQueryPhrase(baseIndentationLevel + 1, "WHEN ");
		queryFormatter.addQueryPhrase(cleanedTableFieldName);
		queryFormatter.addQueryPhrase(" ='' THEN NULL ");		
		queryFormatter.padAndFinishLine();
		
		queryFormatter.addQueryPhrase(baseIndentationLevel + 1, "WHEN ");
		queryFormatter.addQueryPhrase(cleanedTableFieldName);
		queryFormatter.addQueryPhrase(" = 'rif_error' THEN NULL");
		queryFormatter.padAndFinishLine();
		if ((rifDataType instanceof IntegerRIFDataType) ||
			(rifDataType instanceof AgeRIFDataType) ||
			(rifDataType instanceof SexRIFDataType) ||
			(rifDataType instanceof YearRIFDataType)) {
		
			/*
			 * Generates a query fragment like:
			 * 
			 *    ELSE cast(age AS INTEGER)
			 * END
			 */
			
			queryFormatter.addQueryPhrase(baseIndentationLevel + 1, "ELSE ");
			queryFormatter.addQueryPhrase("cast(");
			queryFormatter.addQueryPhrase(cleanedTableFieldName);
			queryFormatter.addQueryPhrase(" AS INTEGER)");
		}
		else if (rifDataType instanceof DateRIFDataType) {
			
			/*
			 * @TODO KLG - may have to create a function that
			 * produces a TIMESTAMP object
			 * 
			 * Generates a query fragment like:
			 * 
			 * ELSE to_timestamp(birth_date, 'DD Mon YYYY');
			 */
			queryFormatter.addQueryPhrase(
				baseIndentationLevel + 1, 
				"ELSE ");
			queryFormatter.addQueryPhrase("to_timestamp(");
			queryFormatter.addQueryPhrase(cleanedTableFieldName);
			queryFormatter.addQueryPhrase(",");
			queryFormatter.addQueryPhrase("'");
			queryFormatter.addQueryPhrase(rifDataType.getMainValidationExpression());
			queryFormatter.addQueryPhrase("')");
		}
		else if (rifDataType instanceof DoubleRIFDataType) {
			
			/*
			 * Generates a query fragment like:
			 * 
			 * ELSE cast(score AS DOUBLE PRECISION)
			 * 
			 */
			queryFormatter.addQueryPhrase(
				baseIndentationLevel + 1,
				"ELSE ");
			queryFormatter.addQueryPhrase("cast(");
			queryFormatter.addQueryPhrase(cleanedTableFieldName);
			queryFormatter.addQueryPhrase(" AS DOUBLE PRECISION)");			
		}
		else {
			//assume it is some kind of formatted text value
			//therefore it does not need to cast from text to text
			queryFormatter.addQueryPhrase(
				baseIndentationLevel + 1, 
				"ELSE ");
			queryFormatter.addQueryPhrase(cleanedTableFieldName);			
		}
		queryFormatter.padAndFinishLine();
		queryFormatter.addQueryPhrase(baseIndentationLevel, " END ");		
		queryFormatter.addQueryPhrase(cleanedTableFieldName);

	}
		
	public String generateDropCastingTableQuery(
		final CleanWorkflowConfiguration tableCleaningConfiguration) {

		SQLDeleteTableQueryFormatter queryFormatter
			= new SQLDeleteTableQueryFormatter();
		String queryCommentLine
			= RIFDataLoaderToolMessages.getMessage("queryComments.clean.dropCastQuery.comment1");
		queryFormatter.addCommentLine(queryCommentLine);
		queryFormatter.addUnderline();
		String cleanedTableName
			= RIFTemporaryTablePrefixes.CLEAN_CASTING.getTableName(
				tableCleaningConfiguration.getCoreTableName());
		queryFormatter.setTableToDelete(cleanedTableName);
		
		return queryFormatter.generateQuery();
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


