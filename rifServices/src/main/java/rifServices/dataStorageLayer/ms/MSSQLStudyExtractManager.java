package rifServices.dataStorageLayer.ms;


import rifServices.system.RIFServiceStartupOptions;
import rifServices.businessConceptLayer.AbstractStudy;
import rifServices.businessConceptLayer.RIFStudySubmission;
import rifServices.fileFormats.RIFStudySubmissionContentHandler;
import rifGenericLibrary.businessConceptLayer.User;
import rifGenericLibrary.dataStorageLayer.SQLGeneralQueryFormatter;
import rifGenericLibrary.dataStorageLayer.pg.PGSQLFunctionCallerQueryFormatter;
import rifGenericLibrary.dataStorageLayer.pg.PGSQLQueryUtility;
import rifGenericLibrary.fileFormats.XMLCommentInjector;
import rifGenericLibrary.system.RIFServiceException;
import rifGenericLibrary.system.RIFServiceExceptionFactory;
import rifServices.system.RIFServiceError;
import rifServices.system.RIFServiceMessages;
import rifGenericLibrary.util.RIFDateFormat;

import java.io.*;
import java.sql.*;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import java.util.Date;

import org.json.JSONObject;
import org.json.JSONArray;

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

public class MSSQLStudyExtractManager extends MSSQLAbstractSQLManager {

	// ==========================================
	// Section Constants
	// ==========================================
	private static String EXTRACT_DIRECTORY;
	private static final String STUDY_QUERY_SUBDIRECTORY = "study_query";
	private static final String STUDY_EXTRACT_SUBDIRECTORY = "study_extract";
	private static final String RATES_AND_RISKS_SUBDIRECTORY = "rates_and_risks";
	private static final String GEOGRAPHY_SUBDIRECTORY = "geography";
	//private static final String STATISTICAL_POSTPROCESSING_SUBDIRECTORY = "statistical_post_processing";
	
	//private static final String TERMS_CONDITIONS_SUBDIRECTORY = "terms_and_conditions";

	private static final int BASE_FILE_STUDY_NAME_LENGTH = 100;
	private static String lineSeparator = System.getProperty("line.separator");
	
	// ==========================================
	// Section Properties
	// ==========================================
	
	//private File termsAndConditionsDirectory;
	
	// ==========================================
	// Section Construction
	// ==========================================

	public MSSQLStudyExtractManager(
		final RIFServiceStartupOptions rifServiceStartupOptions) {

		
		super(rifServiceStartupOptions.getRIFDatabaseProperties());
		
		EXTRACT_DIRECTORY = rifServiceStartupOptions.getExtractDirectory();
		
	}

	// ==========================================
	// Section Accessors and Mutators
	// ==========================================
	public String getStudyExtractFIleName(
			final User user,
			final String studyID)
					throws RIFServiceException {
						
		StringBuilder fileName = new StringBuilder();
		fileName.append(user.getUserID());		
		fileName.append("_");
		fileName.append("s" + studyID);
		fileName.append(".zip");
		
		return fileName.toString();	
		}
		
	public FileInputStream getStudyExtract(
			final Connection connection,
			final User user,
			final RIFStudySubmission rifStudySubmission,
			final String zoomLevel,
			final String studyID)
					throws RIFServiceException {
		//Validate parameters
		String temporaryDirectoryPath = null;
		File temporaryDirectory = null;
		File submissionZipFile = null;
		FileInputStream fileInputStream = null;
		
		try {
			//Establish the phrase that will be used to help name the main zip
			//file and data files within its directories
			String baseStudyName 
			= createBaseStudyFileName(rifStudySubmission, studyID);

			temporaryDirectoryPath = 
					createTemporaryDirectoryPath(
							user, 
							studyID);
			temporaryDirectory = new File(temporaryDirectoryPath);
			if (temporaryDirectory.exists()) {
				rifLogger.info(this.getClass(), "Found R temporary directory: "  + 
					temporaryDirectory.getAbsolutePath());
			}
			else {
				throw new Exception("R temporary directory: "  + 
					temporaryDirectory.getAbsolutePath() + " was not created by Adj_Cov_Smooth_JRI.R");
			}
			
			submissionZipFile 
			= createSubmissionZipFile(
					user,
					baseStudyName);
					
			if (submissionZipFile.isFile()) { // No file (i.e. NULL) handled in MSSQLAbstractRIFWebServiceResource.java
				fileInputStream = new FileInputStream(submissionZipFile);	
				rifLogger.info(this.getClass(), "Fetched ZIP file: " + 
					submissionZipFile.getAbsolutePath());
			}
			else {
				rifLogger.info(this.getClass(), "Unable to fetch ZIP file: " + 
					submissionZipFile.getAbsolutePath() + "; file does not exist");
			}
		}
		catch(Exception exception) {
			rifLogger.error(this.getClass(), "MSSQLStudyExtractManager ERROR", exception);
				
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlStudyStateManager.error.unableToGetStudyExtract",
					user.getUserID(),
					submissionZipFile.getAbsolutePath());
			RIFServiceException rifServiceExeption
				= new RIFServiceException(
				RIFServiceError.ZIPFILE_CREATE_FAILED, 
					errorMessage);
			throw rifServiceExeption;
		}	

		return fileInputStream;
	}
	
	/**
	 * Get textual extract status of a study.                          
	 * <p>   
	 * This fucntion determines whether a study can be extracted from the database and the results returned to the user in a ZIP file 
	 * </p>
	 * <p>
	 * Returns the following textual strings:
	 * <il>
	 *   <li>STUDY_INCOMPLETE_NOT_ZIPPABLE: returned for the following rif40_studies.study_state codes/meanings:
	 *     <ul>
	 *	     <li>C: created, not verified;</li>
	 *	     <li>V: verified, but no other work done; [NOT USED BY MIDDLEWARE]</li>
	 *	     <li>E: extracted imported or created, but no results or maps created;</li> 
	 *	     <li>R: initial results population, create map table; [NOT USED BY MIDDLEWARE] design]</li>
	 *	     <li>W: R warning. [NOT USED BY MIDDLEWARE]</li>
	 *     <ul>
	 *   </li>
	 *   <li>STUDY_FAILED_NOT_ZIPPABLE: returned for the following rif40_studies.study_state codes/meanings:
	 *	     <li>G: Extract failure, extract, results or maps not created;</li> 
	 *	     <li>F: R failure, R has caught one or more exceptions [depends on the exception handler]</li> 
	 *   </li>
	 *   <li>STUDY_EXTRACTABLE_NEEDS_ZIPPING: returned for the following rif40_studies.study_state code/meaning of: S: R success; 
	 *       when the ZIP extrsct file has not yet been created
	 *   </il>
	 *   <li>STUDY_EXTRABLE_ZIPPID: returned for the following rif40_studies.study_statu  code/meaning of: S: R success; 
	 *       when the ZIP extrsct file has been created
	 *   </il>
	 *   <il>STUDY_NOT_FOUND: returned where the studyID was not found in rif40_studies
	 *   </il>
	 * </il>
	 * </p>
	 *
	 * @param  connection	Database specfic Connection object assigned from pool
	 * @param  user 		Database username of logged on user.
	 * @param  rifStudySubmission 		RIFStudySubmission object.
	 * @param  studyID 		Study_id (as text!).
	 *
	 * @return 				Textual extract status, e.g. {status: STUDY_NOT_FOUND} 
	 * 
	 * @exception  			RIFServiceException		Catches all exceptions, logs, and re-throws as RIFServiceException
	 */
	 public String getExtractStatus(
			final Connection connection,
			final User user,
			final RIFStudySubmission rifStudySubmission,
			final String studyID
			)
					throws RIFServiceException {
		String result=null;
		File submissionZipFile = null;
		String zipFileName="UNKNOWN";
		
		try {
			//Establish the phrase that will be used to help name the main zip
			//file and data files within its directories
			
			String studyStatus=getRif40StudyState(connection, studyID);
			if (studyStatus == null) { 	// Study ID does not exist. You will not get this
										// [this is raised as an exception in the calling function: RIFStudySubmission.getRIFStudySubmission()]
				throw new Exception("STUDY_NOT_FOUND: " + studyID);
			}
			if (result != null && studyStatus != null) { 
				switch (studyStatus.charAt(0)) {
					case 'C':
					case 'V':
					case 'E':
					case 'R':
					case 'W':
						result="STUDY_INCOMPLETE_NOT_ZIPPABLE";
						break;
					case 'G':
					case 'F':
						result="STUDY_FAILED_NOT_ZIPPABLE";
						break;
					case 'S':	/* R success */
						break;
					default:
						throw new Exception("Invalid rif40_studies.study_state: " + studyStatus);
				}
			}
			
			if (result == null) {
				String baseStudyName 
				= createBaseStudyFileName(rifStudySubmission, studyID);
				
				submissionZipFile = createSubmissionZipFile(
						user,
						baseStudyName);
				zipFileName=submissionZipFile.getAbsolutePath();
				if (submissionZipFile.isFile()) { // ZIP file exists - no need to recreate
					result="STUDY_EXTRACTBLE_ZIPPID";
				}
				else { // No zip file 
					result="STUDY_EXTRACTABLE_NEEDS_ZIPPING";
				}
			}
		}
		catch(Exception exception) {
			rifLogger.error(this.getClass(), "MSSQLStudyExtractManager ERROR", exception);
				
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlStudyStateManager.error.unableToGetExtractStatus",
					user.getUserID(),
					studyID,
					zipFileName);
			RIFServiceException rifServiceExeption
				= new RIFServiceException(
					RIFServiceError.ZIPFILE_GET_STATUS_FAILED, 
					errorMessage);
			throw rifServiceExeption;
		}

		return "{\"status\":\"" + result + "\"}";
	}
	
	/**
	 * Get the JSON setup file for a run study.                          
	 * <p>   
	 * This function returns the JSON setup file for a run study, including the print setup 
	 * </p>
	 * 
	 * @param  connection	Database specfic Connection object assigned from pool
	 * @param  user 		Database username of logged on user.
	 * @param  rifStudySubmission 		RIFStudySubmission object.
	 * @param  studyID 		Study_id (as text!).
	 *
	 * @return 				Textual extract status as exscaped JSON, e.g. {status: STUDY_NOT_FOUND}
	 *
	 * e.g.
{
	"rif_job_submission": {
		"submitted_by": "peter",
		"job_submission_date": "24/08/2017 16:18:38",
		"project": {
			"name": "TEST",
			"description": "Test project"
		},
		"disease_mapping_study": {
			"name": "1002 LUNG CANCER",
			"description": "",
			"geography": {
				"name": "SAHSULAND",
				"description": "SAHSULAND"
			},
			"disease_mapping_study_area": {
				"geo_levels": {
					"geolevel_select": {
						"name": "SAHSU_GRD_LEVEL1"
					},
					"geolevel_area": {
						"name": ""
					},
					"geolevel_view": {
						"name": "SAHSU_GRD_LEVEL4"
					},
					"geolevel_to_map": {
						"name": "SAHSU_GRD_LEVEL4"
					}
				},
				"map_areas": {
					"map_area": [{
							"id": "01",
							"gid": "01",
							"label": "01",
							"band": 1
						}
					]
				}
			},
			"comparison_area": {
				"geo_levels": {
					"geolevel_select": {
						"name": "SAHSU_GRD_LEVEL1"
					},
					"geolevel_area": {
						"name": ""
					},
					"geolevel_view": {
						"name": "SAHSU_GRD_LEVEL1"
					},
					"geolevel_to_map": {
						"name": "SAHSU_GRD_LEVEL1"
					}
				},
				"map_areas": {
					"map_area": [{
							"id": "01",
							"gid": "01",
							"label": "01",
							"band": 1
						}
					]
				}
			},
			"investigations": {
				"investigation": [{
						"title": "TEST 1002",
						"health_theme": {
							"name": "cancers",
							"description": "covering various types of cancers"
						},
						"numerator_denominator_pair": {
							"numerator_table_name": "NUM_SAHSULAND_CANCER",
							"numerator_table_description": "cancer numerator",
							"denominator_table_name": "POP_SAHSULAND_POP",
							"denominator_table_description": "population health file"
						},
						"age_band": {
							"lower_age_group": {
								"id": 0,
								"name": "0",
								"lower_limit": "0",
								"upper_limit": "0"
							},
							"upper_age_group": {
								"id": 0,
								"name": "85PLUS",
								"lower_limit": "85",
								"upper_limit": "255"
							}
						},
						"health_codes": {
							"health_code": [{
									"code": "C33",
									"name_space": "icd10",
									"description": "Malignant neoplasm of trachea",
									"is_top_level_term": "no"
								}, {
									"code": "C340",
									"name_space": "icd10",
									"description": "Main bronchus",
									"is_top_level_term": "no"
								}, {
									"code": "C341",
									"name_space": "icd10",
									"description": "Upper lobe, bronchus or lung",
									"is_top_level_term": "no"
								}, {
									"code": "C342",
									"name_space": "icd10",
									"description": "Middle lobe, bronchus or lung",
									"is_top_level_term": "no"
								}, {
									"code": "C343",
									"name_space": "icd10",
									"description": "Lower lobe, bronchus or lung",
									"is_top_level_term": "no"
								}, {
									"code": "C348",
									"name_space": "icd10",
									"description": "Overlapping lesion of bronchus and lung",
									"is_top_level_term": "no"
								}, {
									"code": "C349",
									"name_space": "icd10",
									"description": "Bronchus or lung, unspecified",
									"is_top_level_term": "no"
								}
							]
						},
						"year_range": {
							"lower_bound": 1995,
							"upper_bound": 1996
						},
						"year_intervals": {
							"year_interval": [{
									"start_year": "1995",
									"end_year": "1995"
								}, {
									"start_year": "1996",
									"end_year": "1996"
								}
							]
						},
						"years_per_interval": 1,
						"sex": "Both",
						"covariates": []
					}
				]
			}
		},
		"calculation_methods": {
			"calculation_method": {
				"name": "het_r_procedure",
				"code_routine_name": "het_r_procedure",
				"description": "Heterogenous (HET) model type",
				"parameters": {
					"parameter": []
				}
			}
		},
		"rif_output_options": {
			"rif_output_option": ["Data", "Maps", "Ratios and Rates"]
		}
	}
}
	 * 
	 * @exception  			RIFServiceException		Catches all exceptions, logs, and re-throws as RIFServiceException
	 */
	 public String getJsonFile(
			final Connection connection,
			final User user,
			final RIFStudySubmission rifStudySubmission,
			final String studyID)
					throws RIFServiceException {
		String result="{}";

		try {
			JSONObject json = new JSONObject();
			JSONObject rif_job_submission=addRifStudiesJson(connection, studyID);
			rif_job_submission.put("created_by", user.getUserID());
			json.put("rif_job_submission", rif_job_submission);
			result=json.toString();
		}
		catch(Exception exception) {
			rifLogger.error(this.getClass(), "MSSQLStudyExtractManager ERROR", exception);
				
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlStudyStateManager.error.getJsonFile",
					user.getUserID(),
					studyID);
			RIFServiceException rifServiceExeption
				= new RIFServiceException(
					RIFServiceError.JSONFILE_CREATE_FAILED, 
					errorMessage);
			throw rifServiceExeption;
		}
		return result;
	}
		
	public void createStudyExtract(
			final Connection connection,
			final User user,
			final RIFStudySubmission rifStudySubmission,
			final String zoomLevel,
			final String studyID)
					throws RIFServiceException {

		//Validate parameters
		String temporaryDirectoryPath = null;
		File temporaryDirectory = null;
		File submissionZipFile = null;
		
		try {
			//Establish the phrase that will be used to help name the main zip
			//file and data files within its directories
			String baseStudyName 
			= createBaseStudyFileName(rifStudySubmission, studyID);

			temporaryDirectoryPath = 
					createTemporaryDirectoryPath(
							user, 
							studyID);
			temporaryDirectory = new File(temporaryDirectoryPath);
			if (temporaryDirectory.exists()) {
				rifLogger.info(this.getClass(), "Found R temporary directory: "  + 
					temporaryDirectory.getAbsolutePath());
			}
			else {
				throw new Exception("R temporary directory: "  + 
					temporaryDirectory.getAbsolutePath() + " was not created by Adj_Cov_Smooth_JRI.R");
			}
			
			File submissionZipSavFile = createSubmissionZipFile(
					user,
					baseStudyName + ".sav");
			submissionZipFile = createSubmissionZipFile(
					user,
					baseStudyName);
			if (submissionZipFile.isFile()) { // ZIP file exists - no need to recreate
				Thread.sleep(500); // Sleep to allow JS promises time to work
				rifLogger.info(this.getClass(), "No need to create ZIP file: " + 
					submissionZipFile.getAbsolutePath() + "; already exists");
			}
			else if (submissionZipSavFile.isFile()) { // Sav file exists - being created
				Thread.sleep(500); // Sleep to allow JS promises time to work
				rifLogger.info(this.getClass(), "No need to create ZIP file: " + 
					submissionZipSavFile.getAbsolutePath() + "; being created");
			}
			else { // No zip file - can be created
				ZipOutputStream submissionZipOutputStream 
				= new ZipOutputStream(new FileOutputStream(submissionZipFile));


				//write the study the user made when they first submitted their query
				writeQueryFile(
						submissionZipOutputStream,
						user,
						baseStudyName,
						rifStudySubmission);

				addRFiles(
					temporaryDirectory,
					submissionZipOutputStream,
					null);

				writeGeographyFiles(
						connection,
						temporaryDirectoryPath,
						submissionZipOutputStream,
						baseStudyName,
						zoomLevel,
						rifStudySubmission);

				/*
				writeStatisticalPostProcessingFiles(
					connection,
					temporaryDirectoryPath,
					submissionZipOutputStream,				
					baseStudyName,
					rifStudySubmission);

				writeTermsAndConditionsFiles(
					submissionZipOutputStream);	
				 */	
				submissionZipOutputStream.flush();
				submissionZipOutputStream.close();
				submissionZipSavFile.renameTo(submissionZipFile);
				rifLogger.info(this.getClass(), "Created ZIP file: " + 
					submissionZipFile.getAbsolutePath());
			}
		}
		catch(Exception exception) {
			rifLogger.error(this.getClass(), "MSSQLStudyExtractManager ERROR", exception);
//			temporaryDirectory.delete();
				
			String errorMessage
				= RIFServiceMessages.getMessage(
					"sqlStudyStateManager.error.unableToCreateStudyExtract",
					user.getUserID(),
					submissionZipFile.getAbsolutePath());
			RIFServiceException rifServiceExeption
				= new RIFServiceException(
					RIFServiceError.ZIPFILE_CREATE_FAILED, 
					errorMessage);
			throw rifServiceExeption;
		}
		finally {
//			throw new  RIFServiceException(RIFServiceError.ZIPFILE_CREATE_FAILED, "TEST ZIP ERROR");
//			temporaryDirectory.delete();
		}
	}

	private File createSubmissionZipFile(
		final User user,
		final String baseStudyName) {

		StringBuilder fileName = new StringBuilder();
		fileName.append(EXTRACT_DIRECTORY);
		fileName.append(File.separator);
		fileName.append(user.getUserID());		
		fileName.append("_");
		fileName.append(baseStudyName);
		fileName.append(".zip");
		
		return new File(fileName.toString());		
	}

	
	/*
	 * Produces the base name for result files.
	 */
	private String createBaseStudyFileName(
		final RIFStudySubmission rifStudySubmission,
		final String studyID) {
		
		AbstractStudy study = rifStudySubmission.getStudy();
//		String name = study.getName().toLowerCase();
		String name = "s" + studyID + "_" + study.getName().toLowerCase();
		//concatenate study name length.  We need to be mindful about
		//the length of file names we produce so that they are not too
		//long for some operating systems to handle.
		
		if (name.length() > BASE_FILE_STUDY_NAME_LENGTH) {
			name = name.substring(0, BASE_FILE_STUDY_NAME_LENGTH);
		}
		
		
		//replace any spaces with underscores
		name = name.replaceAll(" ", "_");
		
		return name;
	}
	
	private String createTemporaryDirectoryPath(
		final User user,
		final String studyID) {
		
		StringBuilder fileName = new StringBuilder();
		fileName.append(EXTRACT_DIRECTORY);
		
		// Numbered directory support (1-100 etc) to reduce the number of files/directories per directory to 100. This is to improve filesystem 
		// performance on Windows Tomcat servers 	
		Integer centile=Integer.parseInt(studyID) / 100; // 1273 = 12
		// Number directory: d1201-1300
		String numberDir = "d" + ((centile*100)+1) + "-" + (centile+1)*100;
		fileName.append(File.separator);
		fileName.append(numberDir);
		
		fileName.append(File.separator);
		fileName.append("s" + studyID);
	
		return fileName.toString();
	}
	
	
	
	
	private void writeQueryFile(
		final ZipOutputStream submissionZipOutputStream,
		final User user,
		final String baseStudyName,
		final RIFStudySubmission rifStudySubmission)
		throws Exception {
		
		XMLCommentInjector commentInjector = new XMLCommentInjector();
		RIFStudySubmissionContentHandler rifStudySubmissionContentHandler
			= new RIFStudySubmissionContentHandler();
		rifStudySubmissionContentHandler.initialise(
			submissionZipOutputStream, 
			commentInjector);
	
		//KLG @TODO.  Right now we have only 
		
		//write the query file to a special directory.
		//this folder should only contain one file
		StringBuilder queryFileName = new StringBuilder();
		queryFileName.append(STUDY_QUERY_SUBDIRECTORY);
		queryFileName.append(File.separator);
		queryFileName.append(baseStudyName);
		queryFileName.append("_query.xml");
		
		ZipEntry rifQueryFileNameZipEntry = new ZipEntry(queryFileName.toString());
		submissionZipOutputStream.putNextEntry(rifQueryFileNameZipEntry);
		rifStudySubmissionContentHandler.writeXML(
			user, 
			rifStudySubmission);
		submissionZipOutputStream.closeEntry();

		rifLogger.info(this.getClass(), "Add to ZIP file: " + queryFileName);		
	}
	
	
	private void addRFiles(
			final File temporaryDirectory,
			final ZipOutputStream submissionZipOutputStream,
			final String relativePath)
					throws Exception {
						
		File[] listOfFiles = temporaryDirectory.listFiles();

		for (int i = 0; i < listOfFiles.length; i++) {	
		
			if (listOfFiles[i].isFile()) {
				rifLogger.info(this.getClass(), "Adding R file: " + temporaryDirectory.getAbsolutePath() + File.separator + 
					listOfFiles[i].getName() + " to ZIP file");
				
				File file=new File(temporaryDirectory.getAbsolutePath() + File.separator + listOfFiles[i].getName());
				ZipEntry zipEntry = null;
				if (relativePath != null) {
					zipEntry = new ZipEntry(relativePath + File.separator + listOfFiles[i].getName());
				}
				else {
					zipEntry = new ZipEntry(listOfFiles[i].getName());
				}
				submissionZipOutputStream.putNextEntry(zipEntry);

				FileInputStream fileInputStream  = new FileInputStream(file);
				byte[] buffer = new byte[4092];
				int byteCount = 0;
				while ((byteCount = fileInputStream.read(buffer)) != -1) {
					submissionZipOutputStream.write(buffer, 0, byteCount);
				}

				fileInputStream.close();
				submissionZipOutputStream.closeEntry();
			}
			else if (listOfFiles[i].isDirectory()) {
				rifLogger.info(this.getClass(), "Adding R directory: " + temporaryDirectory.getAbsolutePath() + File.separator + 
					listOfFiles[i].getName() + File.separator + " to ZIP file");
				if (relativePath != null) {
					submissionZipOutputStream.putNextEntry(
						new ZipEntry(listOfFiles[i].getName() + File.separator));
				}
				else {
					submissionZipOutputStream.putNextEntry(
						new ZipEntry(listOfFiles[i].getName() + File.separator));
				}					
				addRFiles(listOfFiles[i], submissionZipOutputStream, listOfFiles[i].getName()); // Recurse!!!
			}
			else {
				rifLogger.info(this.getClass(), "Ignoring R file: " + temporaryDirectory.getAbsolutePath() + File.separator + 
					listOfFiles[i].getName());
			}
    	}
	}
	
	private void writeGeographyFiles(
			final Connection connection,
			final String temporaryDirectoryPath,
			final ZipOutputStream submissionZipOutputStream,
			final String baseStudyName,
			final String zoomLevel,
			final RIFStudySubmission rifStudySubmission)
					throws Exception {
		
		String studyID = rifStudySubmission.getStudyID();
	
		//Add geographies to zip file
		StringBuilder tileTableName = new StringBuilder();	
		tileTableName.append("rif_data.geometry_");
		String geog = rifStudySubmission.getStudy().getGeography().getName();			
		tileTableName.append(geog);
						
		StringBuilder tileFilePath = new StringBuilder();
		tileFilePath.append(GEOGRAPHY_SUBDIRECTORY);
		tileFilePath.append(File.separator);
		tileFilePath.append(baseStudyName);
		
		//Write study area
		StringBuilder tileFileName = null;
		tileFileName = new StringBuilder();
		tileFileName.append(tileFilePath.toString());
		tileFileName.append("_studyArea");
		tileFileName.append(".txt");
		
		writeMapQueryTogeoJSONFile(
				connection,
				submissionZipOutputStream,
				"rif40_study_areas",
				tileTableName.toString(),
				tileFileName.toString(),
				zoomLevel,
				studyID);
		
		//Write comparison area
		tileFileName = new StringBuilder();
		tileFileName.append(tileFilePath.toString());
		tileFileName.append("_comparisonArea");
		tileFileName.append(".txt");
		
		writeMapQueryTogeoJSONFile(
				connection,
				submissionZipOutputStream,
				"rif40_comparison_areas",
				tileTableName.toString(),
				tileFileName.toString(),
				zoomLevel,
				studyID);
		rifLogger.info(this.getClass(), "Add to ZIP file: " + tileFileName);
	}	

	
	/*
	private void writeStatisticalPostProcessingFiles(
		final Connection connection,
		final String temporaryDirectoryPath,		
		final ZipOutputStream submissionZipOutputStream,
		final String baseStudyName,
		final RIFStudySubmission rifStudySubmission)
		throws Exception {
				
		
		ArrayList<CalculationMethod> calculationMethods
			= rifStudySubmission.getCalculationMethods();
		for (CalculationMethod calculationMethod : calculationMethods) {
			
			StringBuilder postProcessedTableName = new StringBuilder();			
			postProcessedTableName.append("s");
			postProcessedTableName.append(rifStudySubmission.getStudyID());
			postProcessedTableName.append("_");
			postProcessedTableName.append(calculationMethod.getName());
			
			StringBuilder postProcessedFileName = new StringBuilder();
			postProcessedFileName.append(temporaryDirectoryPath);
			postProcessedFileName.append(File.separator);
			postProcessedFileName.append(baseStudyName);
			postProcessedFileName.append("_");
			postProcessedFileName.append(calculationMethod.getName());
			postProcessedFileName.append(".csv");
			
			File postProcessedFile = new File(postProcessedFileName.toString());
			addFileToZipFile(
				submissionZipOutputStream, 
				STATISTICAL_POSTPROCESSING_SUBDIRECTORY, 
				postProcessedFile);
		}
	}	
	*/
	
	/*
	private void writeTermsAndConditionsFiles(
		final ZipOutputStream submissionZipOutputStream) 
		throws Exception {
		
		File[] files = termsAndConditionsDirectory.listFiles();
		for (File file : files) {
			addFileToZipFile(
				submissionZipOutputStream, 
				TERMS_CONDITIONS_SUBDIRECTORY,
				file);			
		}		
	}
	*/

	
	/*
	 * General methods for writing to zip files
	 */
		
	
	/*
	public void addFileToZipFile(
		final ZipOutputStream submissionZipOutputStream,
		final String zipEntryName,
		final File inputFile)
		throws Exception {
		
		ZipEntry rifQueryFileNameZipEntry = new ZipEntry(zipEntryName);
		submissionZipOutputStream.putNextEntry(rifQueryFileNameZipEntry);
				
		byte[] BUFFER = new byte[4096 * 1024];
		FileInputStream fileInputStream = new FileInputStream(inputFile);		
		int bytesRead = fileInputStream.read(BUFFER);		
		while (bytesRead != -1) {
			submissionZipOutputStream.write(BUFFER, 0, bytesRead);			
			bytesRead = fileInputStream.read(BUFFER);
		}
		submissionZipOutputStream.flush();
		fileInputStream.close();
		submissionZipOutputStream.closeEntry();
		
		rifLogger.info(this.getClass(), "Add to ZIP file: " + inputFile);
	}

    private void addFileToZipFile(
    	final ZipOutputStream submissionZipOutputStream, 
    	final String zipFilePath, 
    	final File file) throws Exception {
    	
    	
    	if (file.isDirectory()) {
    		addDirectoryToZipFile(
    		submissionZipOutputStream,
    		zipFilePath,
    		file); 
    		return;
    	}
    	
    	//assume file is not a directory
    	ZipEntry zipEntry
    		= createZipEntry(
    			zipFilePath,
    			file);
    	submissionZipOutputStream.putNextEntry(zipEntry);

        FileInputStream fileInputStream 
        	= new FileInputStream(file);
        byte[] buffer = new byte[4092];
        int byteCount = 0;
        while ((byteCount = fileInputStream.read(buffer)) != -1)
        {
        	submissionZipOutputStream.write(buffer, 0, byteCount);
            rifLogger.info(this.getClass(), '.');
        }

        fileInputStream.close();
        submissionZipOutputStream.closeEntry();
    }
    
    	*/
	
	public String getRif40StudyState(
			final Connection connection,
			final String studyID)
					throws Exception {
						
		//get study_state
		SQLGeneralQueryFormatter studyStatusQueryFormatter = new SQLGeneralQueryFormatter();	
		studyStatusQueryFormatter.addQueryLine(0, "SELECT a.study_state");
		studyStatusQueryFormatter.addQueryLine(0, "FROM rif40.rif40_studies a");
		studyStatusQueryFormatter.addQueryLine(0, "WHERE a.study_id = ?");
					
		ResultSet studyStatusResultSet = null;
		String studyStatus = null;
		
		try {
			logSQLQuery("getRif40StudyState", studyStatusQueryFormatter, studyID);
			PreparedStatement studyStatusStatement = createPreparedStatement(connection, studyStatusQueryFormatter);
			studyStatusStatement.setInt(1, Integer.parseInt(studyID));	
			studyStatusResultSet = studyStatusStatement.executeQuery();
			studyStatusResultSet.next();
			studyStatus = studyStatusResultSet.getString(1);
		}
		catch (Exception exception) {
			rifLogger.error(this.getClass(), "Error in SQL Statement: >>> " + lineSeparator + studyStatusQueryFormatter.generateQuery(),
				exception);
			throw exception;
		}
		return studyStatus;

	}
					
	public void writeMapQueryTogeoJSONFile(
			final Connection connection,
			final ZipOutputStream submissionZipOutputStream,	
			final String areaTableName,
			final String tableName,
			final String outputFilePath,
			final String zoomLevel,
			final String studyID)
					throws Exception {
		
		//Type of area
		String type = "S";
		
		//get geolevel
		SQLGeneralQueryFormatter geolevelQueryFormatter = new SQLGeneralQueryFormatter();	
		geolevelQueryFormatter.addQueryLine(0, "SELECT b.geolevel_id");
		geolevelQueryFormatter.addQueryLine(0, "FROM rif40.rif40_studies a, rif40.rif40_geolevels b");
		geolevelQueryFormatter.addQueryLine(0, "WHERE study_id = ?");
		if (areaTableName.equals("rif40_comparison_areas")) {
			geolevelQueryFormatter.addQueryLine(0, "AND a.comparison_geolevel_name = b.geolevel_name");
			type = "C";
		} else {
			geolevelQueryFormatter.addQueryLine(0, "AND a.study_geolevel_name = b.geolevel_name");
		}
	
		//count areas
		SQLGeneralQueryFormatter countQueryFormatter = new SQLGeneralQueryFormatter();
		countQueryFormatter.addQueryLine(0, "SELECT count(area_id) from rif40." + areaTableName + " where study_id = ?");
		
		//TODO: possible issues with Multi-polygon and point arrays
		SQLGeneralQueryFormatter queryFormatter = new SQLGeneralQueryFormatter();
		queryFormatter.addQueryLine(0, "SELECT b.areaid, b.zoomlevel, b.wkt from (select area_id from rif40." + areaTableName + " where study_id = ?) a");
		queryFormatter.addQueryLine(0, "left join " + tableName + " b ");
		queryFormatter.addQueryLine(0, "on a.area_id = b.areaid");
		queryFormatter.addQueryLine(0, "WHERE geolevel_id = ? AND zoomlevel = ?");
		
		OutputStreamWriter outputStreamWriter = new OutputStreamWriter(submissionZipOutputStream);
		BufferedWriter bufferedWriter = new BufferedWriter(outputStreamWriter);
		
		PreparedStatement geolevelStatement = createPreparedStatement(connection, geolevelQueryFormatter);		
		ResultSet geolevelResultSet = null;
		PreparedStatement countStatement = createPreparedStatement(connection, countQueryFormatter);		
		ResultSet countResultSet = null;
		PreparedStatement statement = createPreparedStatement(connection, queryFormatter);		
		ResultSet resultSet = null;
		
		try {
			geolevelStatement = createPreparedStatement(connection, geolevelQueryFormatter);
			geolevelStatement.setInt(1, Integer.parseInt(studyID));	
			geolevelResultSet = geolevelStatement.executeQuery();
			geolevelResultSet.next();
			Integer geolevel = geolevelResultSet.getInt(1);
			
			
			countStatement = createPreparedStatement(connection, countQueryFormatter);
			countStatement.setInt(1, Integer.parseInt(studyID));	
			countResultSet = countStatement.executeQuery();
			countResultSet.next();
			int rows = countResultSet.getInt(1);

			statement = createPreparedStatement(connection, queryFormatter);
			statement.setInt(1, Integer.parseInt(studyID));	
			statement.setInt(2, geolevel);
			statement.setInt(3, Integer.parseInt(zoomLevel));
						
			resultSet = statement.executeQuery();

			ZipEntry zipEntry = new ZipEntry(outputFilePath);
			submissionZipOutputStream.putNextEntry(zipEntry);
			
			//Write WKT to geoJSON
			int i = 0;
			bufferedWriter.write("{ \"type\": \"FeatureCollection\", \"features\": [\r\n");	
			while (resultSet.next()) {
				bufferedWriter.write("{ \"type\": \"Feature\",\r\n");
				bufferedWriter.write("\"geometry\": {\r\n\"type\": \"Polygon\",\r\n\"coordinates\": [");
				bufferedWriter.write("[\r\n");
				//Full wkt string
				String polygon = resultSet.getString(3);				
				//trim head and tail
				polygon = polygon.replaceAll("MULTIPOLYGON", "");
				polygon = polygon.replaceAll("[()]", "");				
				//get coordinate pairs
				String[] coords = polygon.split(",");
				for (Integer j = 0; j < coords.length; j++) {
					String node = coords[j].replaceFirst(" ", ",");
					bufferedWriter.write("[" + node + "]");		
					if (j != coords.length - 1) {
						bufferedWriter.write(",");	
					}
				}				
				//get properties
				bufferedWriter.write("]\r\n");					
				bufferedWriter.write("]},\r\n\"properties\": {\r\n");
				bufferedWriter.write("\"area_id\": \"" + resultSet.getString(1) + "\",\r\n");
				bufferedWriter.write("\"zoomLevel\": \"" + resultSet.getString(2) + "\",\r\n");
				bufferedWriter.write("\"areatype\": \"" + type + "\"\r\n");
				bufferedWriter.write("}\r\n");
				bufferedWriter.write("}");
				if (i != rows) {
					bufferedWriter.write(","); 
				}
				bufferedWriter.write("\r\n");
				i++;
			}
			
			bufferedWriter.write("]\r\n");
			bufferedWriter.write("}");

			bufferedWriter.flush();
			submissionZipOutputStream.closeEntry();

			connection.commit();
		}
		finally {
			PGSQLQueryUtility.close(statement);
			PGSQLQueryUtility.close(countStatement);
			PGSQLQueryUtility.close(geolevelStatement);
		}
	}
    	
	private JSONObject addRifStudiesJson(Connection connection, String studyID)
					throws Exception {
		SQLGeneralQueryFormatter rifStudiesQueryFormatter = new SQLGeneralQueryFormatter();		
		ResultSet resultSet = null;
		ResultSetMetaData rsmd = null;
		int columnCount = 0;
		JSONObject rif_job_submission = new JSONObject();
				
		rifStudiesQueryFormatter.addQueryLine(0, "SELECT username AS extracted_by, study_id, extract_table, study_name, summary, description, other_notes,");
        rifStudiesQueryFormatter.addQueryLine(0, "       CONVERT(DATETIME, study_date, 3) + CONVERT(DATETIME, study_date, 8) AS job_submission_date, geography, study_type, study_state, comparison_geolevel_name,");
		rifStudiesQueryFormatter.addQueryLine(0, "       denom_tab, direct_stand_tab, year_start, year_stop, max_age_group, min_age_group,");
		rifStudiesQueryFormatter.addQueryLine(0, "       study_geolevel_name,  map_table, suppression_value, extract_permitted,");
		rifStudiesQueryFormatter.addQueryLine(0, "       transfer_permitted, authorised_by, CONVERT(DATETIME, authorised_on, 3) + CONVERT(DATETIME, authorised_on, 8) AS  AS authorised_on, authorised_notes, audsid,");
		rifStudiesQueryFormatter.addQueryLine(0, "       partition_parallelisation, covariate_table, project, project_description, stats_method");
		rifStudiesQueryFormatter.addQueryLine(0, "  FROM rif40.rif40_studies");	
		rifStudiesQueryFormatter.addQueryLine(0, " WHERE study_id = ?");	
		PreparedStatement statement = createPreparedStatement(connection, rifStudiesQueryFormatter);		
		
		try {
			statement.setInt(1, Integer.parseInt(studyID));	
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				rsmd = resultSet.getMetaData();
				columnCount = rsmd.getColumnCount();
			}
			else {
				throw new Exception("addRifStudiesJson(): expected 1 row, got none");
			}
			JSONObject rif_project = new JSONObject();
			JSONObject study_type = new JSONObject();
			JSONObject rif_output_options = new JSONObject();
			JSONObject investigations = new JSONObject();
			JSONArray investigation = new JSONArray();
			String geographyName=null;
			rif_output_options.put("rif_output_option", new String[] { "Data", "Maps", "Ratios and Rates" });

			// The column count starts from 1
			for (int i = 1; i <= columnCount; i++ ) {
				String name = rsmd.getColumnName(i);
				String value = resultSet.getString(i);
				if (value == null) {
					value="";
				}

				/* 
				"project": {
				  "name": "",
				  "description": ""
				}, */
				
				if (name.equals("project") ) {
					rif_project.put("name", value);	
				}
				else if (name.equals("project_description") ) {
					rif_project.put("description", value);	
				}

				else if (name.equals("study_name") ) {
					study_type.put("name", value);	
				}
				else if (name.equals("description") ) {
					study_type.put(name, value);	
				}
				else if (name.equals("geography") ) {
					JSONObject geography = new JSONObject();
					geographyName = value;
					geography.put("name", geographyName);	
					geography.put("description", getGeographyDescription(connection, geographyName));	// Need to get from rif40_geographies
					study_type.put(name, geography);	
				}
				else if (name.equals("viewer_mapping") || name.equals("diseasemap1_mapping") || name.equals("diseasemap2_mapping") ) {
					rif_output_options.put(name, new JSONObject(value)); // Parse value
				}
				else if (name.equals("study_type") ) {
					switch(Integer.parseInt(value)) {
						case 1: // disease mapping
							study_type.put("study_type", "Disease Mapping");	
							break;
						case 11: 
							study_type.put("study_type", "Risk Analysis (many areas, one band)");
							break;
						case 12: 
							study_type.put("study_type", "Risk Analysis (point sources)");
							break;
						case 13: 
							study_type.put("study_type", "Risk Analysis (exposure covariates)");
							break;
						case 14: 
							study_type.put("study_type", "Risk Analysis (coverage shapefile)");
							break;
						case 15: 
							study_type.put("study_type", "Risk Analysis (exposure shapefile)");
							break;
					}
				}
				/* NONE/HET/BYM/CAR
				"calculation_methods": {
				  "calculation_method": {
					"name": "bym_r_procedure",
					"code_routine_name": "bym_r_procedure",
					"description": "Besag, York and Mollie (BYM) model type",
					"parameters": {
					  "parameter": []
					}
				  }
				}, */
				else if (name.equals("stats_method") ) {
					if (value == null) {
						value="NONE";
					}
					JSONObject calculation_method = new JSONObject();
					JSONObject calculation_methods = new JSONObject();
					JSONObject parameters = new JSONObject();
					JSONArray parameter = new JSONArray();
					if (resultSet.getString(i).equals("NONE")) {
						calculation_method.put("name", value);
						calculation_method.put("code_routine_name", value);
						calculation_method.put("description", value);
					}
					else {
						calculation_method.put("name", value + "_r_procedure");
						calculation_method.put("code_routine_name", value + "_r_procedure");
						if (value.equals("BYM")) {
							calculation_method.put("description", "Besag, York and Mollie (BYM) model type");
						}
						else if (value.equals("HET")) {
							calculation_method.put("description", "Heterogenous (HET) model type");
						}
						else if (value.equals("CAR")) {
							calculation_method.put("description", "Conditional Auto Regression (CAR) model type");
						}
					}
					parameters.put("parameter", parameter);
					calculation_method.put("parameters", parameters);
					calculation_methods.put("calculation_method", calculation_method);	
					rif_job_submission.put("calculation_methods", calculation_methods);
				}
				else { 
					rif_job_submission.put(name, value);	
				}
			}
			rif_job_submission.put("project", rif_project);	
			addInvestigations(connection, investigation, studyID, geographyName);
			investigations.put("investigation", investigation);
			study_type.put("investigations", investigations);
			rif_job_submission.put("disease_mapping_study", study_type);
			rif_job_submission.put("rif_output_options", rif_output_options);

			if (resultSet.next()) {
				throw new Exception("addRifStudiesJson(): expected 1 row, got >1");
			}
		}
		catch (Exception exception) {
			rifLogger.error(this.getClass(), "Error in SQL Statement: >>> " + lineSeparator + rifStudiesQueryFormatter.generateQuery(),
				exception);
			throw exception;
		}
		finally {
			PGSQLQueryUtility.close(statement);
		}

		return rif_job_submission;
	}

	private String getGeographyDescription(Connection connection, String geographyName)
					throws Exception {
		SQLGeneralQueryFormatter rifGeographyQueryFormatter = new SQLGeneralQueryFormatter();		
		ResultSet resultSet = null;
		
		rifGeographyQueryFormatter.addQueryLine(0, "SELECT description FROM rif40.rif40_geographies WHERE geography = ?");
		PreparedStatement statement = createPreparedStatement(connection, rifGeographyQueryFormatter);
		String geographyDescription=null;
		try {		
			statement.setString(1, geographyName);	
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				geographyDescription=resultSet.getString(1);
				if (resultSet.next()) {
					throw new Exception("getGeographyDescription(): expected 1 row, got >1");
				}
			}
			else {
				throw new Exception("getGeographyDescription(): expected 1 row, got none");
			}
		}
		catch (Exception exception) {
			rifLogger.error(this.getClass(), "Error in SQL Statement: >>> " + lineSeparator + rifGeographyQueryFormatter.generateQuery(),
				exception);
			throw exception;
		}
		finally {
			PGSQLQueryUtility.close(statement);
		}

		return geographyDescription;
	}
	
	private void addInvestigations(Connection connection, JSONArray investigation, String studyID, String geographyName)
					throws Exception {
		SQLGeneralQueryFormatter rifInvestigationsQueryFormatter = new SQLGeneralQueryFormatter();		
		ResultSet resultSet = null;
		
		rifInvestigationsQueryFormatter.addQueryLine(0, "SELECT * FROM rif40.rif40_investigations WHERE study_id = ?");
		PreparedStatement statement = createPreparedStatement(connection, rifInvestigationsQueryFormatter);

		try {		
			statement.setInt(1, Integer.parseInt(studyID));	
			resultSet = statement.executeQuery();
			
			if (resultSet.next()) {
				ResultSetMetaData rsmd = resultSet.getMetaData();
				int columnCount = rsmd.getColumnCount();

				do {
					JSONObject investigationObject = new JSONObject();
					// The column count starts from 1
					for (int i = 1; i <= columnCount; i++ ) {
						String name = rsmd.getColumnName(i);
						String value = resultSet.getString(i);
						if (value == null) {
							value="";
						}

						if (name.equals("inv_name") ) {
							investigationObject.put("title", value);
						}
						else if (name.equals("numer_tab") ) {
							String numeratorTable=value;
							JSONObject numerator_denominator_pair = new JSONObject();
							JSONObject health_theme = new JSONObject();
							addNumeratorDenominatorPair(connection, numeratorTable, 
								numerator_denominator_pair, health_theme, geographyName);

							investigationObject.put("health_theme", health_theme);
							investigationObject.put("numerator_denominator_pair", numerator_denominator_pair);
						}
						else {
							investigationObject.put(name, value);
						}
					}
					investigation.put(investigationObject);	
				} while (resultSet.next());
			}
			else {
				throw new Exception("addInvestigations(): expected 1+ rows, got none");
			}			
		}
		catch (Exception exception) {
			rifLogger.error(this.getClass(), "Error in SQL Statement: >>> " + lineSeparator + rifInvestigationsQueryFormatter.generateQuery(),
				exception);
			throw exception;
		}
		finally {
			PGSQLQueryUtility.close(statement);
		}
	}

	public void addNumeratorDenominatorPair(Connection connection, String numeratorTable, 
						JSONObject numerator_denominator_pair, JSONObject health_theme, String geographyName)
					throws Exception {
		SQLGeneralQueryFormatter rifNumDenomQueryFormatter = new SQLGeneralQueryFormatter();		
		ResultSet resultSet = null;
		
		rifNumDenomQueryFormatter.addQueryLine(0, "SELECT a.geography, a.numerator_table, a.numerator_description,");
		rifNumDenomQueryFormatter.addQueryLine(0, "       a.theme_description, a.denominator_table, a.denominator_description, b.theme");
		rifNumDenomQueryFormatter.addQueryLine(0, "  FROM rif40_num_denom a");
		rifNumDenomQueryFormatter.addQueryLine(0, "       LEFT OUTER JOIN rif40.rif40_health_study_themes b ON (a.theme_description = b.description)");
		rifNumDenomQueryFormatter.addQueryLine(0, " WHERE a.geography = ? AND a.numerator_table = ?");
		PreparedStatement statement = createPreparedStatement(connection, rifNumDenomQueryFormatter);

		try {		
			statement.setString(1, geographyName);	
			statement.setString(2, numeratorTable);	
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				ResultSetMetaData rsmd = resultSet.getMetaData();
				int columnCount = rsmd.getColumnCount();
				for (int i = 1; i <= columnCount; i++ ) {
					String name = rsmd.getColumnName(i);
					String value = resultSet.getString(i);
					if (value == null) {
						value="";
					}

					if (name.equals("numerator_table") ) {
						numerator_denominator_pair.put("numerator_table_name", value);
					}
					else if (name.equals("numerator_description") ) {
						numerator_denominator_pair.put("numerator_table_description", value);
					}
					else if (name.equals("denominator_table") ) {
						numerator_denominator_pair.put("denominator_table_name", value);
					}
					else if (name.equals("denominator_description") ) {
						numerator_denominator_pair.put("denominator_description", value);
					}
					else if (name.equals("theme_description") ) {
						health_theme.put("theme_description", value);
					}
					else if (name.equals("theme") ) {
						health_theme.put("name", value);
					}
				}
			}
			else {
				throw new Exception("addNumeratorDenominatorPair(): expected 1 row, got none");
			}	
		}
		catch (Exception exception) {
			rifLogger.error(this.getClass(), "Error in SQL Statement: >>> " + lineSeparator + rifNumDenomQueryFormatter.generateQuery(),
				exception);
			throw exception;
		}
		finally {
			PGSQLQueryUtility.close(statement);
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
