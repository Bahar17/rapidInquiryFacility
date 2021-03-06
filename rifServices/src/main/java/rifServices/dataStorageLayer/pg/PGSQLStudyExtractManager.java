package rifServices.dataStorageLayer.pg;


import rifServices.system.RIFServiceStartupOptions;
import rifServices.businessConceptLayer.AbstractStudy;
import rifServices.businessConceptLayer.RIFStudySubmission;
import rifServices.fileFormats.RIFStudySubmissionContentHandler;
import rifGenericLibrary.businessConceptLayer.User;
import rifGenericLibrary.dataStorageLayer.SQLGeneralQueryFormatter;
//import rifGenericLibrary.dataStorageLayer.common.SQLFunctionCallerQueryFormatter;
import rifGenericLibrary.dataStorageLayer.common.SQLQueryUtility;
import rifGenericLibrary.dataStorageLayer.DatabaseType;
import rifServices.dataStorageLayer.common.GetStudyJSON;
import rifServices.dataStorageLayer.common.RifZipFile;
import rifGenericLibrary.fileFormats.XMLCommentInjector;
import rifGenericLibrary.system.RIFServiceException;
import rifGenericLibrary.system.RIFServiceExceptionFactory;
import rifServices.system.RIFServiceError;
import rifServices.system.RIFServiceMessages;
import rifGenericLibrary.util.RIFDateFormat;

import java.io.*;
import java.sql.*;
import org.json.JSONObject;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import java.util.Locale;


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

public class PGSQLStudyExtractManager extends PGSQLAbstractSQLManager {

	// ==========================================
	// Section Constants
	// ==========================================
	private static String EXTRACT_DIRECTORY;
	private static String TAXONOMY_SERVICES_SERVER;
	private static final String STUDY_QUERY_SUBDIRECTORY = "study_query";
	private static final String STUDY_EXTRACT_SUBDIRECTORY = "study_extract";
	private static final String RATES_AND_RISKS_SUBDIRECTORY = "rates_and_risks";
	private static final String GEOGRAPHY_SUBDIRECTORY = "geography";
	//private static final String STATISTICAL_POSTPROCESSING_SUBDIRECTORY = "statistical_post_processing";

	//private static final String TERMS_CONDITIONS_SUBDIRECTORY = "terms_and_conditions";

	private static final int BASE_FILE_STUDY_NAME_LENGTH = 100;
	private static String lineSeparator = System.getProperty("line.separator");
	private RIFServiceStartupOptions rifServiceStartupOptions;
	private static DatabaseType databaseType;
	
	// ==========================================
	// Section Properties
	// ==========================================

	//private File termsAndConditionsDirectory;

	// ==========================================
	// Section Construction
	// ==========================================

	public PGSQLStudyExtractManager(
			final RIFServiceStartupOptions rifServiceStartupOptions) {


		super(rifServiceStartupOptions.getRIFDatabaseProperties());
		this.rifServiceStartupOptions = rifServiceStartupOptions;
		EXTRACT_DIRECTORY = this.rifServiceStartupOptions.getExtractDirectory();
		TAXONOMY_SERVICES_SERVER = this.rifServiceStartupOptions.getTaxonomyServicesServer();
		databaseType=this.rifServiceStartupOptions.getRifDatabaseType();
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
		
	/**
	 * Get study extract
	 *
	 * @param  connection	Database specfic Connection object assigned from pool
	 * @param  user 		Database username of logged on user.
	 * @param  rifStudySubmission 		RIFStudySubmission object.
	 * @param  String 		zoomLevel (as text!).
	 * @param  studyID 		Study_id (as text!).
	 *
	 * @return 				FileInputStream 
	 * 
	 * @exception  			RIFServiceException		Catches all exceptions, logs, and re-throws as RIFServiceException
	 */	
	public FileInputStream getStudyExtract(
			final Connection connection,
			final User user,
			final RIFStudySubmission rifStudySubmission,
			final String zoomLevel,
			final String studyID)
					throws RIFServiceException {
						
		RifZipFile rifZipFile = new RifZipFile(rifServiceStartupOptions);
		FileInputStream zipStream=rifZipFile.getStudyExtract(
			connection,
			user,
			rifStudySubmission,
			zoomLevel,
			studyID);
		return zipStream;
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
	 * </il>
	 * </p>
	 *
	 * @param  connection	Database specfic Connection object assigned from pool
	 * @param  user 		Database username of logged on user.
	 * @param  rifStudySubmission 		RIFStudySubmission object.
	 * @param  studyID 		Study_id (as text!).
	 *
	 * @return 				Textual extract status as exscaped JSON, e.g. {status: STUDY_NOT_FOUND}
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
		RifZipFile rifZipFile = new RifZipFile(rifServiceStartupOptions);
		String extractStatus=rifZipFile.getExtractStatus(
			connection,
			user,
			rifStudySubmission,
			studyID);
		return extractStatus;
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
	 * @param  locale 		locale
	 * @param  tomcatServer e.g. http://localhost:8080.
	 * 
	 * @exception  			RIFServiceException		Catches all exceptions, logs, and re-throws as RIFServiceException
	 */
	 public String getJsonFile(
			final Connection connection,
			final User user,
			final RIFStudySubmission rifStudySubmission,
			final String studyID,
			final Locale locale,
			final String tomcatServer)
					throws RIFServiceException {
		String result="{}";

		try {
			JSONObject json = new JSONObject();
			GetStudyJSON getStudyJSON = new GetStudyJSON(rifServiceStartupOptions);
			JSONObject rif_job_submission=getStudyJSON.addRifStudiesJson(connection, 
				studyID, locale, tomcatServer, TAXONOMY_SERVICES_SERVER);
			rif_job_submission.put("created_by", user.getUserID());
			json.put("rif_job_submission", rif_job_submission);
			result=json.toString();
		}
		catch(Exception exception) {
			rifLogger.error(this.getClass(), "PGSQLStudyExtractManager ERROR", exception);
				
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
	
	/** 
     * Create study extract. 
	 *
     * @param Connection connection (required)
     * @param User user (required)
     * @param RIFStudySubmission rifStudySubmission (required)
     * @param String zoomLevel (required)
     * @param String studyID (required)
     * @param Locale locale (required)
     * @param String tomcatServer [deduced from calling URL] (required)
     * @return JSONObject [front end saves as JSON5 file]
     */	
	public void createStudyExtract(
			final Connection connection,
			final User user,
			final RIFStudySubmission rifStudySubmission,
			final String zoomLevel,
			final String studyID,
			final Locale locale,
			final String tomcatServer)
					throws RIFServiceException {
						
		RifZipFile rifZipFile = new RifZipFile(rifServiceStartupOptions);
		rifZipFile.createStudyExtract(connection,
			user,
			rifStudySubmission,
			zoomLevel,
			studyID,
			locale,
			tomcatServer,
			TAXONOMY_SERVICES_SERVER);

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
	} */
		
	public String getRif40StudyState(
			final Connection connection,
			final String studyID)
					throws Exception {
		String studyState;
		RifZipFile rifZipFile = new RifZipFile(rifServiceStartupOptions);
		studyState=rifZipFile.getRif40StudyState(connection,
			studyID);
		
		return studyState;
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
