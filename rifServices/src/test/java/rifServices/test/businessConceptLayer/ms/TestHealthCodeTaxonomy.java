package rifServices.test.businessConceptLayer.ms;

import rifGenericLibrary.system.RIFServiceException;
import rifGenericLibrary.system.RIFServiceSecurityException;
import rifServices.test.AbstractRIFTestCase;
import rifServices.businessConceptLayer.HealthCodeTaxonomy;
import rifServices.system.RIFServiceError;
import static org.junit.Assert.*;

import org.junit.Test;



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

public final class TestHealthCodeTaxonomy 
	extends AbstractRIFTestCase {

	// ==========================================
	// Section Constants
	// ==========================================

	// ==========================================
	// Section Properties
	// ==========================================
	/** The master health code taxonomy. */
	private HealthCodeTaxonomy masterHealthCodeTaxonomy;
	
	// ==========================================
	// Section Construction
	// ==========================================

	/**
	 * Instantiates a new test health code taxonomy.
	 */
	public TestHealthCodeTaxonomy() {
		masterHealthCodeTaxonomy
			= HealthCodeTaxonomy.newInstance(
				"ICD 9 Codes", 
				"Contains all the health codes from ICD 9", 
				"icd9",
				"1.0");
	}
	
	// ==========================================
	// Section Accessors and Mutators
	// ==========================================

	// ==========================================
	// Section Errors and Validation
	// ==========================================
	
	/**
	 * Accept valid health code taxonomy.
	 */
	@Test
	public void acceptValidInstance_COMMON() {
		HealthCodeTaxonomy healthCodeTaxonomy
			= HealthCodeTaxonomy.createCopy(masterHealthCodeTaxonomy);		
		try {
			healthCodeTaxonomy.checkErrors(getValidationPolicy());
		}
		catch(RIFServiceException rifServiceException) {
			fail();
		}		
	}

	/**
	 * Reject blank field values.
	 */
	@Test
	public void rejectBlankRequiredFields_ERROR() {
		HealthCodeTaxonomy healthCodeTaxonomy
			= HealthCodeTaxonomy.createCopy(masterHealthCodeTaxonomy);		
		healthCodeTaxonomy.setName(null);
		try {
			healthCodeTaxonomy.checkErrors(getValidationPolicy());
		}
		catch(RIFServiceException rifServiceException) {
			checkErrorType(
				rifServiceException, 
				RIFServiceError.INVALID_HEALTH_CODE_TAXONOMY, 
				1);
		}		
		
		healthCodeTaxonomy
			= HealthCodeTaxonomy.createCopy(masterHealthCodeTaxonomy);		
		healthCodeTaxonomy.setName("");
		try {
			healthCodeTaxonomy.checkErrors(getValidationPolicy());
		}
		catch(RIFServiceException rifServiceException) {
			checkErrorType(
				rifServiceException, 
				RIFServiceError.INVALID_HEALTH_CODE_TAXONOMY, 
				1);
		}		
				
		healthCodeTaxonomy
			= HealthCodeTaxonomy.createCopy(masterHealthCodeTaxonomy);		
		healthCodeTaxonomy.setName(null);
		try {
			healthCodeTaxonomy.checkErrors(getValidationPolicy());
		}
		catch(RIFServiceException rifServiceException) {
			checkErrorType(
				rifServiceException, 
				RIFServiceError.INVALID_HEALTH_CODE_TAXONOMY, 
				1);
		}		
		
		healthCodeTaxonomy
			= HealthCodeTaxonomy.createCopy(masterHealthCodeTaxonomy);		
		healthCodeTaxonomy.setDescription("");
		try {
			healthCodeTaxonomy.checkErrors(getValidationPolicy());
		}
		catch(RIFServiceException rifServiceException) {
			checkErrorType(
				rifServiceException, 
				RIFServiceError.INVALID_HEALTH_CODE_TAXONOMY, 
				1);
		}		
		
		healthCodeTaxonomy
			= HealthCodeTaxonomy.createCopy(masterHealthCodeTaxonomy);		
		healthCodeTaxonomy.setDescription(null);
		try {
			healthCodeTaxonomy.checkErrors(getValidationPolicy());
		}
		catch(RIFServiceException rifServiceException) {
			checkErrorType(
				rifServiceException, 
				RIFServiceError.INVALID_HEALTH_CODE_TAXONOMY, 
				1);
		}		
		
		healthCodeTaxonomy
			= HealthCodeTaxonomy.createCopy(masterHealthCodeTaxonomy);		
		healthCodeTaxonomy.setNameSpace("");
		try {
			healthCodeTaxonomy.checkErrors(getValidationPolicy());
		}
		catch(RIFServiceException rifServiceException) {
			checkErrorType(
				rifServiceException, 
				RIFServiceError.INVALID_HEALTH_CODE_TAXONOMY, 
				1);
		}		
			
		healthCodeTaxonomy
			= HealthCodeTaxonomy.createCopy(masterHealthCodeTaxonomy);		
		healthCodeTaxonomy.setNameSpace(null);
		try {
			healthCodeTaxonomy.checkErrors(getValidationPolicy());
		}
		catch(RIFServiceException rifServiceException) {
			checkErrorType(
				rifServiceException, 
				RIFServiceError.INVALID_HEALTH_CODE_TAXONOMY, 
				1);
		}	
	}
	
	/**
	 * Check security violations.
	 */
	@Test
	public void rejectSecurityViolations_MALICIOUS() {
		HealthCodeTaxonomy healthCodeTaxonomy
			= HealthCodeTaxonomy.createCopy(masterHealthCodeTaxonomy);		
		
		try {
			healthCodeTaxonomy.setIdentifier(getTestMaliciousValue());
			healthCodeTaxonomy.checkSecurityViolations();
			fail();
		}
		catch(RIFServiceSecurityException rifServiceSecurityException) {
			//pass
		}
		
		healthCodeTaxonomy
			= HealthCodeTaxonomy.createCopy(masterHealthCodeTaxonomy);		
	
		try {
			healthCodeTaxonomy.setIdentifier(getTestMaliciousValue());
			healthCodeTaxonomy.checkSecurityViolations();
			fail();
		}
		catch(RIFServiceSecurityException rifServiceSecurityException) {
			//pass
		}

		healthCodeTaxonomy
			= HealthCodeTaxonomy.createCopy(masterHealthCodeTaxonomy);		

		try {
			healthCodeTaxonomy.setName(getTestMaliciousValue());
			healthCodeTaxonomy.checkSecurityViolations();
			fail();
		}
		catch(RIFServiceSecurityException rifServiceSecurityException) {
			//pass
		}
	

		healthCodeTaxonomy
			= HealthCodeTaxonomy.createCopy(masterHealthCodeTaxonomy);		
		try {
			healthCodeTaxonomy.setDescription(getTestMaliciousValue());
			healthCodeTaxonomy.checkSecurityViolations();
			fail();
		}
		catch(RIFServiceSecurityException rifServiceSecurityException) {
			//pass
		}

		healthCodeTaxonomy
			= HealthCodeTaxonomy.createCopy(masterHealthCodeTaxonomy);		
		try {
			healthCodeTaxonomy.setNameSpace(getTestMaliciousValue());
			healthCodeTaxonomy.checkSecurityViolations();
			fail();
		}
		catch(RIFServiceSecurityException rifServiceSecurityException) {
			//pass
		}
	}
	

	// ==========================================
	// Section Interfaces
	// ==========================================

	// ==========================================
	// Section Override
	// ==========================================
}
