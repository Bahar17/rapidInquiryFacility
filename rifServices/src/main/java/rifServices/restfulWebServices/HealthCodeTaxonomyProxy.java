package rifServices.restfulWebServices;


import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;

/**
 * Describes a source of terms that describe health concepts.  The most
 * commonly used sources will be ICD 9 and ICD 10, but in future the 
 * RIF will likely be adapted to accommodate more sources of terms.
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

@XmlRootElement(name="healthCode")
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(propOrder= {
	"code",
	"description",
	"nameSpace",
	"version"
	})
final public class HealthCodeTaxonomyProxy {

	// ==========================================
	// Section Constants
	// ==========================================

	// ==========================================
	// Section Properties
	// ==========================================
 	@XmlElement(required = true)	
	private String name;
	
 	@XmlElement(required = true)	
	private String description;
	
 	@XmlElement(required = true)	
	private String nameSpace;
	
 	@XmlElement(required = true)	
	private String version;
	
	// ==========================================
	// Section Construction
	// ==========================================

	/**
	 * Instantiates a new health code taxonomy.
	 *
	 * @param code the name
	 * @param description the description
	 * @param nameSpace the name space
	 * @param version the version
	 */
	public HealthCodeTaxonomyProxy() {
		
		this.name = "";
		this.description = "";
		this.nameSpace = "";	
		this.version = "";
	}
	
	// ==========================================
	// Section Accessors and Mutators
	// ==========================================	
	/**
	 * Gets the name.
	 *
	 * @return the name
	 */
	public String getName() {
		return name;
	}

	/**
	 * Sets the name.
	 *
	 * @param name the new name
	 */
	public void setName(
		final String name) {

		this.name = name;
	}

	/**
	 * Gets the description.
	 *
	 * @return the description
	 */
	public String getDescription() {
		
		return description;
	}

	/**
	 * Sets the description.
	 *
	 * @param description the new description
	 */
	public void setDescription(
		final String description) {

		this.description = description;
	}

	/**
	 * Gets the name space.
	 *
	 * @return the name space
	 */
	public String getNameSpace() {
		
		return nameSpace;
	}

	/**
	 * Sets the name space.
	 *
	 * @param nameSpace the new name space
	 */
	public void setNameSpace(
		final String nameSpace) {
		
		this.nameSpace = nameSpace;
	}

	/**
	 * Sets the version.
	 *
	 * @param version the new version
	 */
	public void setVersion(
		final String version) {

		this.version = version;
	}
	
	/**
	 * Gets the version.
	 *
	 * @return the version
	 */
	public String getVersion() {
		
		return version;
	}
		
	// ==========================================
	// Section Errors and Validation
	// ==========================================
		
	// ==========================================
	// Section Interfaces
	// ==========================================

	//Interface: DisplayableItem

	public String getDisplayName() {

		return name;
	}
		
	// ==========================================
	// Section Override
	// ==========================================

}
