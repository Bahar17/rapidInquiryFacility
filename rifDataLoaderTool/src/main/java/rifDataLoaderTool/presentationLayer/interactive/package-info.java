/**
 * This package contains all the classes that support a Swing-based
 * GUI for the Data Loader Tool.  I expect in future, once a web-based
 * front end has been developed, that classes in this package will 
 * become deprecated.
 * 
 * <p>
 * The main electronic form for the Data Loader Tool, 
 * {@link rifDataLoaderTool.presentationLayer.interactive.RIFDataLoaderToolApplication},
 * comprises:
 * <ul>
 * <li>a file menu comprising save configuration, load configuration and exit
 * buttons {@link rifDataLoaderTool.presentationLayer.interactive.RIFDataLoaderToolMenuBar}
 * </li>
 * <li>
 * a button which helps you selects an XML file containing meta data about the geographies
 * that have been processed by the Tile Making service.  
 * {@link rifDataLoaderTool.presentationLayer.interactive.GeographyMetaDataLoadingPanel}
 * </li>
 * <li>
 * a panel for specifying Health Themes.
 * {@link rifDataLoaderTool.presentationLayer.interactive.HealthThemesListPanel}
 * </li>
 * <li>
 * a button that triggers a Data Type Editor dialog to appear
 * {@link rifDataLoaderTool.presentationLayer.interactive.DataTypeEditorDialog}
 * </li>
 * <li>
 * a button that triggers an Configuration Hints Editor dialog to appear
 * {@link rifDataLoaderTool.presentationLayer.interactive.ConfigurationHintsEditorDialog}
 * </li>
 * <li>
 * a panel for editing denominators
 * {@link rifDataLoaderTool.presentationLayer.interactive.DenominatorsListPanel}
 * </li>
 * <li>
 * a panel for editing numerators
 * {@link rifDataLoaderTool.presentationLayer.interactive.NumeratorListPanel}
 * </li>
 * <li>
 * a panel for editing covariates
 * {@link rifDataLoaderTool.presentationLayer.interactive.CovariatesListPanel}
 * </li>
 * </ul>
 * 
 * Note that <code>DenominatorListPanel</code>, <code>NumeratorListPanel</code>
 * and <code>CovariatesListPanel</code> all support editing configuration details
 * through an instance of the Data Set Editor Dialog
 * (@rifDataLoaderTool.presentationLayer.interactive.DataSetConfigurationEditorDialog}.
 * 
 * <p>
 * Users fill in the form in a prescribed order:
 * <ol>
 * <li>
 * specify the meta data file containing definitions of geographies and geographical
 * resolutions.  This file will be generated by the Tile Making Service that simplifies
 * shape files.
 * </li>
 * <li>
 * optionally specify new kinds of data types that may be used in the data cleaning process
 * to change either cleaning or validation behaviour.
 * </li>
 * <li>
 * optionally specify data configuration hints that are used to set configuration options based
 * on on the naming patterns of either imported file names or imported field names
 * </li>
 * <li>
 * <li>
 * define population health denominator data sets
 * </li>
 * <li>
 * define health numerator data sets
 * </li>
 * <li>
 * define covariate data sets
 * </li>
 * </ol>
 * 
 * <p>
 * The ordering of data entry is defined by the class
 * {@link rifDataLoaderTool.presentationLayer.interactive.DataLoadingOrder}.  List
 * items in one area of the Data Loader Tool may depend list items defined in a 
 * previous section.  For example, the definition of a numerator data set must
 * refer to the name of a denominator data set.  Numerator, denominator and covariate
 * data sets must refer to a specific Geography.
 * </p>
 * 
 * <p>
 * Changes made to a given configuration record may therefore influence values in
 * other records that would depend on it.  For example, deleting a denominator may
 * have a knock-on effect in a numerator that references it. Dependencies are 
 * managed by {@link rifDataLoaderTool.presentationLayer.interactive.DLDependencyManager}.
 * </p>
 * 
 * 
 */
/**
 * @author kgarwood
 *
 */
package rifDataLoaderTool.presentationLayer.interactive;