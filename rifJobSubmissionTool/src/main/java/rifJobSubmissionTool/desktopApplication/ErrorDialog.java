package rifJobSubmissionTool.desktopApplication;

import rifJobSubmissionTool.system.RIFJobSubmissionToolException;

import rifServices.system.RIFServiceException;

import java.awt.Component;
import java.util.ArrayList;
import javax.swing.JOptionPane;

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

/**
 * The Class ErrorDialog.
 */
public class ErrorDialog {

// ==========================================
// Section Constants
// ==========================================

// ==========================================
// Section Properties
// ==========================================
		
	
// ==========================================
// Section Construction
// ==========================================
    /**
     * Instantiates a new error dialog.
     */
	private ErrorDialog() {

    }

// ==========================================
// Section Accessors and Mutators
// ==========================================
    
    /**
     * Show error.
     *
     * @param parent the parent
     * @param rifServiceException the rif service exception
     */
	static public void showError(
    	Component parent, 
    	RIFServiceException rifServiceException) {
    	
    	ArrayList<String> errorMessages
    		= rifServiceException.getErrorMessages();
    	if (errorMessages.size() == 1) {
    		showError(parent, errorMessages.get(0));
    	}
    	else {
    		showError(parent, errorMessages);    		
    	} 	
    }
    
    /**
     * Show error.
     *
     * @param parent the parent
     * @param rifJobSubmissionToolException the rif job submission tool exception
     */
    static public void showError(
        Component parent, 
        RIFJobSubmissionToolException rifJobSubmissionToolException) {
        	
        ArrayList<String> errorMessages
        	= rifJobSubmissionToolException.getErrorMessages();
        if (errorMessages.size() == 1) {
        	showError(parent, errorMessages.get(0));
        }
        else {
        	showError(parent, errorMessages);    		
        } 	
    }
    
    
	/**
	 * Show error.
	 *
	 * @param parent the parent
	 * @param errorMessage the error message
	 */
	static public void showError(
		Component parent, 
		String errorMessage) {

		JOptionPane.showMessageDialog(parent, 
			errorMessage, 
			null, 
			JOptionPane.ERROR_MESSAGE);
	}	
	
	/**
	 * Show error.
	 *
	 * @param parent the parent
	 * @param errorMessages the error messages
	 */
	static public void showError(
		Component parent, 
		ArrayList<String> errorMessages) {

		if (errorMessages.size() == 0) {
			return;
		}

		StringBuilder buffer = new StringBuilder();
		if (errorMessages.size() == 1) {
			buffer.append(errorMessages.get(0));
		}
		else {
			for (String errorMessage : errorMessages) {
				buffer.append("* ");
				buffer.append(errorMessage);
				buffer.append("\n");
			}
		}
		JOptionPane.showMessageDialog(parent, 
			buffer.toString(), 
			null, 
			JOptionPane.ERROR_MESSAGE);
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
