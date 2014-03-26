package rifServices.dataStorageLayer;

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
 * Copyright 2014 Imperial College London, developed by the Small Area
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

public class SQLMinMaxQueryFormatter 
	extends SQLQueryFormatter {

	// ==========================================
	// Section Constants
	// ==========================================
	/**
	 * The Enum OperationType.
	 */
	public enum OperationType {
		/** The min. */
		MIN, 
		/** The max. */
		MAX, 
		/** The avg. */
		AVG};
	
	// ==========================================
	// Section Properties
	// ==========================================
	/** The from table name. */
	private String fromTableName;
	
	/** The countable field name. */
	private String countableFieldName;
	
	/** The where conditions. */
	private ArrayList<String> whereConditions;
	
	/** The operation type. */
	private OperationType operationType;

	
	// ==========================================
	// Section Construction
	// ==========================================

	/**
	 * Instantiates a new SQL min max query formatter.
	 *
	 * @param operationType the operation type
	 */
	public SQLMinMaxQueryFormatter(
		final OperationType operationType) {
		
		this.operationType = operationType;
		whereConditions = new ArrayList<String>();
	}

	// ==========================================
	// Section Accessors and Mutators
	// ==========================================
	/**
	 * Sets the from table.
	 *
	 * @param fromTableName the new from table
	 */
	public void setFromTable(
		final String fromTableName) {

		this.fromTableName = fromTableName;
	}
	
	/**
	 * Sets the countable field name.
	 *
	 * @param countableFieldName the new countable field name
	 */
	public void setCountableFieldName(
		final String countableFieldName) {
		
		this.countableFieldName = countableFieldName;		
	}
		
	/**
	 * Adds the where parameter.
	 *
	 * @param fieldName the field name
	 */
	public void addWhereParameter(
		final String fieldName) {

		StringBuilder whereCondition = new StringBuilder();
		whereCondition.append(fieldName);
		whereCondition.append("=?");

		whereConditions.add(whereCondition.toString());
	}
	
	/**
	 * Adds the where parameter with operator.
	 *
	 * @param fieldName the field name
	 * @param operator the operator
	 */
	public void addWhereParameterWithOperator(
		final String fieldName,
		final String operator) {

		StringBuilder whereCondition = new StringBuilder();
		whereCondition.append(fieldName);
		whereCondition.append(operator);
		whereCondition.append("?");
			
		whereConditions.add(whereCondition.toString());
	}

	/* (non-Javadoc)
	 * @see rifServices.dataStorageLayer.SQLQueryFormatter#generateQuery()
	 */
	public String generateQuery() {
		
		query = new StringBuilder();
		query.append("SELECT ");
		if (operationType == OperationType.MAX) {
			query.append("MAX(");
		}
		else if (operationType == OperationType.MIN) {
			query.append("MIN(");			
		}
		else {
			query.append("AVG(");			
		}
		query.append(countableFieldName);
		query.append(") ");
		query.append("FROM ");
		query.append(convertCase(fromTableName));
		
		int numberOfWhereConditions = whereConditions.size();
		if (numberOfWhereConditions > 0) {			
			query.append(" WHERE ");
			for (int i = 0; i < numberOfWhereConditions; i++) {
				if (i != 0) {
					query.append(" AND ");
				}
				query.append(convertCase(whereConditions.get(i)));
			}
		}
		query.append(";");
				
		return query.toString();
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
