package rifJobSubmissionTool.system;

import rifServices.businessConceptLayer.MapArea;

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

public final class MapAreaSelectionEvent {
	// ==========================================
	// Section Constants
	// ==========================================
	/**
	 * The Enum OperationType.
	 */
	public enum OperationType {
		/** The items added. */
		ITEMS_ADDED, 
		/** The items deleted. */
		ITEMS_DELETED, 
		/** The basket emptied. */
		BASKET_EMPTIED};
	
	// ==========================================
	// Section Properties
	// ==========================================

	/** The map areas. */
	private final ArrayList<MapArea> mapAreas;	
	/** The operation type. */
	private final OperationType operationType;
	
	// ==========================================
	// Section Construction
	// ==========================================

	/**
	 * Instantiates a new map area selection event.
	 *
	 * @param operationType the operation type
	 * @param mapAreas the map areas
	 */
	public MapAreaSelectionEvent(
		final OperationType operationType,
		final ArrayList<MapArea> mapAreas) {
		
		this.operationType = operationType;
		this.mapAreas = mapAreas;
	}
	
	/**
	 * Instantiates a new map area selection event.
	 *
	 * @param operationType the operation type
	 */
	public MapAreaSelectionEvent(
		final OperationType operationType) {
		
		this.operationType = operationType;
		mapAreas = new ArrayList<MapArea>();
		
	}

	// ==========================================
	// Section Accessors and Mutators
	// ==========================================
	/**
	 * Gets the operation type.
	 *
	 * @return the operation type
	 */
	public OperationType getOperationType() {
		
		return operationType;
	}

	/**
	 * Gets the affected areas.
	 *
	 * @return the affected areas
	 */
	public ArrayList<MapArea> getAffectedAreas() {
		
		return mapAreas;
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

