// ************************************************************************
//
// GIT Header
//
// $Format:Git ID: (%h) %ci$
// $Id: 7ccec3471201c4da4d181af6faef06a362b29526 $
// Version hash: $Format:%H$
//
// Description:
//
// Rapid Enquiry Facility (RIF) - HTTP error reponse
//
// Copyright:
//
// The Rapid Inquiry Facility (RIF) is an automated tool devised by SAHSU 
// that rapidly addresses epidemiological and public health questions using 
// routinely collected health and population data and generates standardised 
// rates and relative risks for any given health outcome, for specified age 
// and year ranges, for any given geographical area.
//
// Copyright 2014 Imperial College London, developed by the Small Area
// Health Statistics Unit. The work of the Small Area Health Statistics Unit 
// is funded by the Public Health England as part of the MRC-PHE Centre for 
// Environment and Health. Funding for this project has also been received 
// from the Centers for Disease Control and Prevention.  
//
// This file is part of the Rapid Inquiry Facility (RIF) project.
// RIF is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// RIF is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with RIF. If not, see <http://www.gnu.org/licenses/>; or write 
// to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, 
// Boston, MA 02110-1301 USA
//
// Author:
//
// Peter Hambly, SAHSU

const os = require('os'),
	  fs = require('fs'),
	  nodeGeoSpatialServicesCommon = require('../lib/nodeGeoSpatialServicesCommon');
	  
/*
 * Function: 	httpErrorResponse() 
 * Parameters:  File called from, line number called from, procedure called from, 
 *				serverLog object,
 *				HTTP status,
 *				HTTP request object,
 *				HTTP response object,
 * 				Message text,
 *				Error object [may be null],
 *				Internal response object [may be null]
 * Description: HTTP error reponse
 *
 * Response object - errors:
 *  
 * error: 			Error message (if present) 
 * no_files: 		Numeric, number of files    
 * field_errors: 	Number of errors in processing fields
 * file_list: 		Array file objects:
 *						file_name: File name
 * message: 		Error message
 * diagnostic:		Diagnotic message 
 * fields: 			Array of fields; includes all from request plus any additional fields set as a result of processing 
 */		
httpErrorResponse=function(file, line, calling_function, serverLog, status, req, res, msg, err, g_response) {
	
	var l_response = {                 // Set output response    
		error: '',
		no_files: 0,    
		field_errors: 0,
		file_errors: 0,
		file_list: [],
		message: '',  
		diagnostic: '',
		fields: [] 
	};
	
	/*
	 * Function:	httpErrorResponseAddStatusCallback()
	 * Parameters:	Error object
	 * Returns:		Nothing
	 * Description: addStatus callback
	 */				
	function httpErrorResponseAddStatusCallback(err) { // Add error status
		if (err) {
			serverLog.serverLog2(__file, __line, "httpErrorResponseAddStatusCallback", 
				"WARNING: Error in addStatus()", req, err);
		}
		
		var statii="";
		for (var i=0; i<g_response.status.length; i++) { // Print statii
			if (g_response.status[i]) {
				statii+="[" + i + "]: +" + g_response.status[i].etime + " S (" + 
					g_response.status[i].httpStatus + "); " +
					g_response.status[i].statusText;
				if (g_response.status[i].errorName) {
					statii+="\n\terrorName: " + g_response.status[i].errorName+ "; "
				}
				if (g_response.status[i].additionalInfo) {
					statii+="\n\tadditionalInfo: >>>\n" + g_response.status[i].additionalInfo+ "<<< End of additionalInfo; "
				}
				statii+="\n";
			}
		}
		
		serverLog.serverLog2(__file, __line, "httpErrorResponseAddStatusCallback", 
			"Status list; size: " + g_response.status.length + "\n" + statii);
		
		if (!res.finished) { // Error if httpErrorResponse.httpErrorResponse() NOT already processed
			res.status(status);		
			var output;
			try {
				output = JSON.stringify(l_response); // Convert output response to JSON 
			}
			catch (e) {
				const util = require('util');

				var trace=(util.inspect(l_response, { showHidden: true, depth: 3 }));
				serverLog.serverLog2(__file, __line, "httpErrorResponseAddStatusCallback", 
					"ERROR! in JSON.stringify(g_response); trace >>>\n" + trace + "\n<<< End of trace", req, e);
			}

			if (g_response && g_response.fields["diagnosticFileDir"] && g_response.fields["responseFileName"]) { // Save to response file
				var fs = require('fs');
				fs.writeFileSync(g_response.fields["diagnosticFileDir"] + "/" + g_response.fields["responseFileName"], 
					output);	
			}
			else if (g_response && !g_response.fields["responseFileName"]) { // Do not raise errors - you will recurse and it will not be devine
				serverLog.serverLog2(__file, __line, "httpErrorResponseAddStatusCallback", "FATAL ERROR! Unable to save response file; no responseFileName", req);
			}
				
			res.write(output);
			res.end();	
			serverLog.serverLog2(__file, __line, "httpErrorResponseAddStatusCallback", "httpErrorResponse sent; size: " + output.length + " bytes: \nOutput: " + output, req);	
		}
		else { // Do not raise errors - likewise
			serverLog.serverLog2(__file, __line, "httpErrorResponseAddStatusCallback", 
				"FATAL ERROR! Unable to return error to user - httpErrorResponse() already processed", req, err);
		}						
	} // End of httpErrorResponseAddStatusCallback()	
					
	try {		
		if (g_response) {
			if (g_response.sqlError) {
				l_response.sqlError=g_response.sqlError;
			}
			l_response.no_files = g_response.no_files;
			l_response.field_errors = g_response.field_errors;
			l_response.file_errors = g_response.file_errors;
			for (var i = 0; i < l_response.no_files; i++) {	
				if (g_response.file_list[i]) { // Handle incomplete file list
					if (g_response.file_list[i].file_name) {
						l_response.file_list[i] = {
							file_name: g_response.file_list[i].file_name
						};
					}
					else {
						l_response.file_list[i] = {
							file_name: ''
						};
					}							
				}
				else {
					l_response.file_list[i] = {
						file_name: ''
					};
				}
			}
			g_response.fields["diagnosticFileDir"]=undefined;	// Remove diagnosticFileDir as it reveals OS type
			if (!g_response.fields["my_reference"]) { 
				g_response.fields["my_reference"]=undefined;
			}
			l_response.fields = g_response.fields;
		}
		if (msg) {
			l_response.message = msg;
		}
		else {
			l_response.message = "(No error message)";
		}
		if (err) { // Add error to message
			l_response.error = err.message;
		}
		if (g_response && g_response.message) { // Add diagnostic
			serverLog.serverLog2(file, line, calling_function, g_response.message, req, err);
			l_response.diagnostic += "\n\n" + g_response.message;
			
			if (g_response.fields && g_response.fields["diagnosticFileDir"] && g_response.fields["diagnosticFileName"]) {
				var fs = require('fs');
				
				fs.writeFileSync(g_response.fields["diagnosticFileDir"] + "/" + g_response.fields["diagnosticFileName"], 
					g_response.message);
			}
		}
		else { 
			serverLog.serverLog2(file, line, calling_function, "(No diagnostic)", req, err);
		}
		
		if (g_response && g_response.diagnosticsTimer) { // Disable the diagnostic file write timer
			clearInterval(g_response.diagnosticsTimer);
			g_response.diagnosticsTimer=undefined;
		}
	
		if (g_response && g_response.status && nodeGeoSpatialServicesCommon && 
		    nodeGeoSpatialServicesCommon.addStatus && typeof nodeGeoSpatialServicesCommon.addStatus == "function") { // Add error status
			try {	
				console.error("httpErrorResponse(): Call addStatus(): " + status);
				nodeGeoSpatialServicesCommon.addStatus(file, line, g_response, "FATAL", 
					status /* HTTP status */, serverLog, req, httpErrorResponseAddStatusCallback);
					
				l_response.status = g_response.status;
			}
			catch (e) {		
				serverLog.serverLog2(file, line, calling_function, "WARNING: httpErrorResponse(): caught exception in addStatus()", req, e);
			}
		}
		else {
			if (!g_response) {	
				serverLog.serverLog2(file, line, calling_function, "WARNING: httpErrorResponse(): no g_response; unable to addStatus()", req, undefined /* No exception */);	
			}
			else if (!g_response.status) {	
				serverLog.serverLog2(file, line, calling_function, "WARNING: httpErrorResponse(): no g_response.status; unable to addStatus()", req, undefined /* No exception */);	
			}
			else if (!nodeGeoSpatialServicesCommon) {	
				serverLog.serverLog2(file, line, calling_function, 
					"WARNING: httpErrorResponse(): no nodeGeoSpatialServicesCommon module for addStatus() function; unable to addStatus()", req, undefined /* No exception */);
			}
			else if (!nodeGeoSpatialServicesCommon.addStatus) {	
				serverLog.serverLog2(file, line, calling_function, "WARNING: httpErrorResponse(): no addStatus() function; unable to addStatus()", req, undefined /* No exception */);
			}
			else if (typeof nodeGeoSpatialServicesCommon.addStatus != "function") {	
				serverLog.serverLog2(file, line, calling_function, "WARNING: httpErrorResponse(): addStatus() is not a function; unable to addStatus()", req, undefined /* No exception */);
			}
			httpErrorResponseAddStatusCallback(); // Cannot add status, run callback anyway (or you won't get a result)...
		}

	} catch (e) {                            // Catch conversion errors
		try {
			var n_msg="Error response processing ERROR!\n\n" + (msg || "no msg");				  
			serverLog.serverLog(n_msg, req, e);
			if (!res.finished) { // Error if httpErrorResponse.httpErrorResponse() NOT already processed
				res.status(501);			
				res.write(n_msg);
				res.end();	
			}
			else {
				serverLog.serverLog2(__file, __line, "httpErrorResponse", "FATAL! Unable to return error to user - httpErrorResponse() already processed", req, e);
			}
		}
		catch (e2) {
			console.error("\n* LOG START *********************************************************************\n" +
				+ "\nhttpErrorResponse() FATAL Error in exception handler; message >>>\n" + (n_msg || "No n_msg") + "\n<<< End of message." +
				"\nhttpErrorResponse() error: " + e2.message +
				"\n\n* LOG END ***********************************************************************\n");
			throw new Error("httpErrorResponse() FATAL Error in exception handler");
		}	
		return;
	}
} // End of httpErrorResponse() 

module.exports.httpErrorResponse = httpErrorResponse;	