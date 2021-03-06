package rifServices.test.services.ms;

import rifGenericLibrary.businessConceptLayer.User;
import rifGenericLibrary.system.RIFServiceException;
import rifGenericLibrary.system.RIFGenericLibraryError;
import rifServices.businessConceptLayer.GeoLevelSelect;
import rifServices.businessConceptLayer.Geography;
import rifServices.system.RIFServiceError;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

import org.junit.Test;


/**
 *
 * <hr>
 * The Rapid Inquiry Facility (RIF) is an automated tool devised by SAHSU 
 * that rapidly addresses epidemiological and public health questions using 
 * routinely collected health and population data and generates standardised 
 * rates and relative risks for any given health outcome, for specified age 
 * and year ranges, for any given geographical area.
 *
 * Copyright 2017 Imperial College London, developed by the Small Area
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

public final class GetDefaultGeoLevelSelectValue 
	extends AbstractRIFServiceTestCase {

	// ==========================================
	// Section Constants
	// ==========================================

	// ==========================================
	// Section Properties
	// ==========================================

	// ==========================================
	// Section Construction
	// ==========================================

	public GetDefaultGeoLevelSelectValue() {

	}

	// ==========================================
	// Section Accessors and Mutators
	// ==========================================
	
	// ==========================================
	// Section Errors and Validation
	// ==========================================

	
	@Test
	public void getDefaultGeoLevelSelectValue_COMMON1() {
		try {
			User validUser = cloneValidUser();
			Geography validGeography = cloneValidGeography();
			
			GeoLevelSelect defaultSelectValue
				= rifStudySubmissionService.getDefaultGeoLevelSelectValue(
					validUser, 
					validGeography);
			assertEquals("LEVEL2", defaultSelectValue.getName());
		}
		catch(RIFServiceException rifServiceException) {
			fail();
		}		
	}
	
	@Test
	public void getDefaultGeoLevelSelectValue_NULL1() {

		//empty user
		try {
			Geography validGeography = cloneValidGeography();
			rifStudySubmissionService.getDefaultGeoLevelSelectValue(
				null, 
				validGeography);
			fail();
		}
		catch(RIFServiceException rifServiceException) {
			checkErrorType(
				rifServiceException,
				RIFServiceError.EMPTY_API_METHOD_PARAMETER,
				1);
		}
	}

	@Test
	public void getDefaultGeoLevelSelectValue_EMPTY1() {
		try {
			User emptyUser = cloneEmptyUser();
			Geography validGeography = cloneValidGeography();
			rifStudySubmissionService.getDefaultGeoLevelSelectValue(
				emptyUser, 
				validGeography);
			fail();
		}
		catch(RIFServiceException rifServiceException) {
			checkErrorType(
				rifServiceException,
				RIFGenericLibraryError.INVALID_USER,
				1);
		}
	}
	
	@Test
	public void getDefaultGeoLevelSelectValue_NULL2() {

		//empty geography
		try {			
			User validUser = cloneValidUser();
			rifStudySubmissionService.getDefaultGeoLevelSelectValue(
				validUser, 
				null);
			fail();
		}
		catch(RIFServiceException rifServiceException) {
			checkErrorType(
				rifServiceException,
				RIFServiceError.EMPTY_API_METHOD_PARAMETER,
				1);
		}
	}
	
	@Test
	public void getDefaultGeoLevelSelectValue_EMPTY2() {
		try {			
			User validUser = cloneValidUser();
			Geography emptyGeography = cloneEmptyGeography();
			rifStudySubmissionService.getDefaultGeoLevelSelectValue(
				validUser, 
				emptyGeography);
			fail();
		}
		catch(RIFServiceException rifServiceException) {
			checkErrorType(
				rifServiceException,
				RIFServiceError.INVALID_GEOGRAPHY,
				1);
		}		
	}

	@Test
	public void getDefaultGeoLevelSelectValue_NONEXISTENT1() {

		//user
		try {
			User nonExistentUser = cloneNonExistentUser();
			Geography validGeography = cloneValidGeography();
			
			rifStudySubmissionService.getDefaultGeoLevelSelectValue(
				nonExistentUser, 
				validGeography);
			fail();
		}
		catch(RIFServiceException rifServiceException) {
			checkErrorType(
				rifServiceException,
				RIFGenericLibraryError.SECURITY_VIOLATION,
				1);
		}

	}

	@Test
	public void getDefaultGeoLevelSelectValue_NONEXISTENT2() {	

		try {
			User validUser = cloneValidUser();
			Geography nonExistentGeography = cloneNonExistentGeography();
			
			rifStudySubmissionService.getDefaultGeoLevelSelectValue(
				validUser, 
				nonExistentGeography);
			fail();
		}
		catch(RIFServiceException rifServiceException) {
			checkErrorType(
				rifServiceException,
				RIFServiceError.NON_EXISTENT_GEOGRAPHY,
				1);
		}				
	}

	@Test
	public void getDefaultGeoLevelSelectValue_MALICIOUS1() {	
		try {
			User maliciousUser = cloneMaliciousUser();
			Geography validGeography = cloneValidGeography();
			
			rifStudySubmissionService.getDefaultGeoLevelSelectValue(
				maliciousUser, 
				validGeography);
			fail();
		}
		catch(RIFServiceException rifServiceException) {
			checkErrorType(
				rifServiceException,
				RIFGenericLibraryError.SECURITY_VIOLATION,
				1);
		}		
	}
	
	@Test
	public void getDefaultGeoLevelSelectValue_MALICIOUS2() {	
		try {
			User validUser = cloneValidUser();
			Geography maliciousGeography = cloneMaliciousGeography();
			
			rifStudySubmissionService.getDefaultGeoLevelSelectValue(
				validUser, 
				maliciousGeography);
			fail();
		}
		catch(RIFServiceException rifServiceException) {
			checkErrorType(
				rifServiceException,
				RIFGenericLibraryError.SECURITY_VIOLATION,
				1);
		}		
	}

	// ==========================================
	// Section Interfaces
	// ==========================================

	// ==========================================
	// Section Override
	// ==========================================
}
