package rifDataLoaderTool.targetDBScriptGenerator.pg;

import rifDataLoaderTool.businessConceptLayer.*;
import rifDataLoaderTool.fileFormats.DataLoaderToolConfigurationReader;
import rifGenericLibrary.system.RIFGenericLibraryMessages;

import java.util.ArrayList;
import java.util.Date;
import java.io.*;

/**
 * This class generates a single PostgreSQL script that will load all of the 
 * data sets that have been processed by the data loader tool
 *
 * <hr>
 * Copyright 2017 Imperial College London, developed by the Small Area
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

public class PGDataLoadingScriptGenerator {

	public static void main(String[] args) {
		try {
			File sampleConfigFile
				= new File("C:\\rifDataLoaderTool\\SAHSULAND_ConfigurationFile.xml");
			DataLoaderToolConfigurationReader reader	
				 = new DataLoaderToolConfigurationReader();
			reader.readFile(sampleConfigFile);
			DataLoaderToolConfiguration dataLoaderToolConfiguration
				= reader.getDataLoaderToolConfiguration();
			PGDataLoadingScriptGenerator scriptGenerator
				= new PGDataLoadingScriptGenerator();
			File scriptFile
				= new File("C:\\rifDataLoaderTool\\LoadItScript.sql");
			scriptGenerator.writeScript(scriptFile, dataLoaderToolConfiguration);
		}
		catch(Exception exception) {
			exception.printStackTrace(System.out);
		}
	}
	
	// ==========================================
	// Section Constants
	// ==========================================

	// ==========================================
	// Section Properties
	// ==========================================
	private PGHealthThemeScriptGenerator healthThemeScriptGenerator;
	private PGDenominatorScriptGenerator denominatorScriptGenerator;
	private PGNumeratorScriptGenerator numeratorScriptGenerator;
	private PGCovariateScriptGenerator covariateScriptGenerator;
	
	// ==========================================
	// Section Construction
	// ==========================================

	public PGDataLoadingScriptGenerator() {
		healthThemeScriptGenerator = new PGHealthThemeScriptGenerator();
		denominatorScriptGenerator = new PGDenominatorScriptGenerator();
		numeratorScriptGenerator = new PGNumeratorScriptGenerator();
		covariateScriptGenerator = new PGCovariateScriptGenerator();

	}

	// ==========================================
	// Section Accessors and Mutators
	// ==========================================
	public void writeScript(
		final File outputDirectory,
		final DataLoaderToolConfiguration dataLoaderToolConfiguration) {

		
		setOutputDirectory(outputDirectory);
		
		BufferedWriter bufferedWriter = null;
		try {
			File scriptfile = createDataLoadingScriptFile(outputDirectory);						
			FileWriter fileWriter = new FileWriter(scriptfile);
			bufferedWriter = new BufferedWriter(fileWriter);
		
			addBeginTransactionSection(bufferedWriter);

			
			//Part I: Pre-pend script for loading geospatial data
		


			//Part II: Load health themes
			addSectionHeading(bufferedWriter, "Health Themes");
			ArrayList<DLHealthTheme> healthThemes
				= dataLoaderToolConfiguration.getHealthThemes();
			for (DLHealthTheme healthTheme : healthThemes) {
				String healthThemeEntry
					= healthThemeScriptGenerator.generateScript(healthTheme);
				bufferedWriter.write(healthThemeEntry);
				bufferedWriter.newLine();
				bufferedWriter.flush();
			}

			addSectionHeading(bufferedWriter, "Denominators");
			
			//Processing Denominators
			DLGeographyMetaData geographyMetaData
				= dataLoaderToolConfiguration.getGeographyMetaData();
			ArrayList<DataSetConfiguration> denominators
				= dataLoaderToolConfiguration.getDenominatorDataSetConfigurations();
			for (DataSetConfiguration denominator : denominators) {
				DLHealthTheme healthTheme
					= denominator.getHealthTheme();
				addDataSetHeading(bufferedWriter, denominator.getDisplayName());
				
				String denominatorEntry
					= denominatorScriptGenerator.generateScript(
						denominator);
				bufferedWriter.write(denominatorEntry);
				bufferedWriter.newLine();
				bufferedWriter.flush();
			}

			//Processing Numerators
			addSectionHeading(bufferedWriter, "Numerators");
			ArrayList<DataSetConfiguration> numerators
				= dataLoaderToolConfiguration.getNumeratorDataSetConfigurations();
			for (DataSetConfiguration numerator : numerators) {
				addDataSetHeading(bufferedWriter, numerator.getDisplayName());
				bufferedWriter.newLine();
				bufferedWriter.newLine();
				
				String numeratorEntry
					= numeratorScriptGenerator.generateScript(
							geographyMetaData,
							numerator);
				bufferedWriter.write(numeratorEntry);
				bufferedWriter.newLine();
				bufferedWriter.flush();
			}
		
			//Processing Covariates
			addSectionHeading(bufferedWriter, "Covariates");
			ArrayList<DataSetConfiguration> covariateConfigurations
				= dataLoaderToolConfiguration.getCovariateDataSetConfigurations();
			for (DataSetConfiguration covariateConfiguration : covariateConfigurations) {
				addDataSetHeading(bufferedWriter, covariateConfiguration.getDisplayName());
				bufferedWriter.newLine();
				bufferedWriter.newLine();
				
				String covariaterEntry
					= covariateScriptGenerator.generateScript(
						covariateConfiguration);
				bufferedWriter.write(covariaterEntry);
				bufferedWriter.newLine();
				bufferedWriter.flush();
			}
			
			addEndTransactionSection(bufferedWriter);
	
			bufferedWriter.flush();
			bufferedWriter.close();
			
		}
		catch(IOException ioException) {
			ioException.printStackTrace(System.out);
		}	
	}

	
	private void addBeginTransactionSection(
		final BufferedWriter bufferedWriter)
		throws IOException {
		
		bufferedWriter.write("\\set ECHO all");
		bufferedWriter.newLine();
		bufferedWriter.write("\\set ON_ERROR_STOP ON");
		bufferedWriter.newLine();
		bufferedWriter.write("\\timing");
		bufferedWriter.newLine();
		bufferedWriter.write("BEGIN TRANSACTION;");
		bufferedWriter.newLine();
	}
	
	private void addEndTransactionSection(
		final BufferedWriter bufferedWriter)
		throws IOException {
		
		bufferedWriter.newLine();
		bufferedWriter.write("COMMIT TRANSACTION;");
	}
	
	private void addSectionHeading(
		final BufferedWriter bufferedWriter,
		final String headingName) 
		throws IOException {
	
		bufferedWriter.write("-- ===============================================");
		bufferedWriter.newLine();
		bufferedWriter.write("-- Adding ");
		bufferedWriter.write(headingName);
		bufferedWriter.newLine();
		bufferedWriter.write("-- ===============================================");
		bufferedWriter.newLine();
		bufferedWriter.newLine();
	}

	private void addDataSetHeading(
		final BufferedWriter bufferedWriter,
		final String dataSetName)
		throws IOException {
		
		bufferedWriter.write("-- Adding ");
		bufferedWriter.write(dataSetName);
		bufferedWriter.newLine();
	}
	
	private void setOutputDirectory(final File outputDirectory) {
		denominatorScriptGenerator.setScriptDirectory(outputDirectory);
		numeratorScriptGenerator.setScriptDirectory(outputDirectory);
		covariateScriptGenerator.setScriptDirectory(outputDirectory);
	}
	
	private File createDataLoadingScriptFile(final File outputDirectory) {
		StringBuilder filePath = new StringBuilder();
		filePath.append(outputDirectory.getAbsolutePath());
		filePath.append(File.separator);
		filePath.append("pg_run_data_loader_");
		String timeStamp
			= RIFGenericLibraryMessages.getTimeStampForFileName(new Date());
		filePath.append(timeStamp);
		filePath.append(".sql");
		
		File file = new File(filePath.toString());
		return file;
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

