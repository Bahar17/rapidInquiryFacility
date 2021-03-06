package rifGenericLibrary.dataStorageLayer.pg;


import rifGenericLibrary.dataStorageLayer.AbstractSQLQueryFormatter;

import java.util.ArrayList;

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

public final class PGSQLInsertQueryFormatter 
	extends AbstractSQLQueryFormatter {

	// ==========================================
	// Section Constants
	// ==========================================

	// ==========================================
	// Section Properties
	// ==========================================
	/** The into table. */
	private String intoTable;
	
	/** The insert fields. */
	private ArrayList<String> insertFields;
	
	private ArrayList<Boolean> useQuotesForLiteral;

	// ==========================================
	// Section Construction
	// ==========================================

	/**
	 * Instantiates a new SQL insert query formatter.
	 */
	public PGSQLInsertQueryFormatter() {
		insertFields = new ArrayList<String>();
		useQuotesForLiteral = new ArrayList<Boolean>();
	}

	// ==========================================
	// Section Accessors and Mutators
	// ==========================================

	/**
	 * Sets the into table.
	 *
	 * @param intoTable the new into table
	 */
	public void setIntoTable(
		final String intoTable) {
		
		this.intoTable = intoTable;
	}
	
	/**
	 * Adds the insert field.
	 *
	 * @param insertField the insert field
	 */
	public void addInsertField(
		final String insertField) {
		
		insertFields.add(insertField);
	}

	public void addInsertField(
		final String insertField,
		final Boolean useQuotes) {
			
		insertFields.add(insertField);
		useQuotesForLiteral.add(useQuotes);
	}
			
	
	@Override
	
	public String generateQuery() {
		resetAccumulatedQueryExpression();
		addQueryPhrase(0, "INSERT INTO ");
		addQueryPhrase(getSchemaTableName(intoTable));
		addQueryPhrase("(");
		padAndFinishLine();

		int numberOfInsertFields = insertFields.size();
		for (int i = 0; i < numberOfInsertFields; i++) {
			if (i != 0) {
				addQueryPhrase(",");
				finishLine();
			}
			addQueryPhrase(1, insertFields.get(i));			
		}
		addQueryPhrase(")");
		padAndFinishLine();
		addQueryPhrase(0, "VALUES (");
		for (int i = 0; i < numberOfInsertFields; i++) {
			if (i != 0) {
				addQueryPhrase(",");
			}
			addQueryPhrase("?");			
		}

		addQueryPhrase(");");
		finishLine();
		
		return super.generateQuery();		
	}

	
	public String generateQueryWithLiterals(
		final String... literalValues) {
		
		resetAccumulatedQueryExpression();
		addQueryPhrase(0, "INSERT INTO ");
		addQueryPhrase(getSchemaTableName(intoTable));
		addQueryPhrase("(");
		padAndFinishLine();

		int numberOfInsertFields = insertFields.size();
		for (int i = 0; i < numberOfInsertFields; i++) {
			if (i != 0) {
				addQueryPhrase(",");
				finishLine();
			}
			addQueryPhrase(1, insertFields.get(i).trim());			
		}

		addQueryPhrase(")");
		padAndFinishLine();
		
		addQueryPhrase(0, "SELECT ");
		for (int i = 0; i < numberOfInsertFields; i++) {
			if (i != 0) {
				addQueryPhrase(", ");
			}
			
			if (literalValues[i] == null) {
				addQueryPhrase("null");				
			}
			else {
				if (useQuotesForLiteral.get(i) == true) {
					addQueryPhrase("'");
					addQueryPhrase(literalValues[i]);
					addQueryPhrase("'");					
				}
				else {
					addQueryPhrase(literalValues[i]);
				}
			}
			addQueryPhrase(" AS ");
			addQueryPhrase(insertFields.get(i).trim());			
		}
		finishLine();
		addQueryPhrase(0, "FROM ");
		addQueryPhrase(getSchemaTableName(intoTable));
		finishLine();
		addQueryPhrase("WHERE ");
		addQueryPhrase(insertFields.get(0).trim());
		addQueryPhrase(" NOT IN (SELECT ");
		addQueryPhrase(insertFields.get(0).trim());
		addQueryPhrase(" FROM ");
		addQueryPhrase(getSchemaTableName(intoTable));
		addQueryPhrase(")");
	
		return super.generateQuery();		
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
