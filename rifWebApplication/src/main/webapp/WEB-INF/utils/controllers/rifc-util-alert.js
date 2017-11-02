/**
 * The Rapid Inquiry Facility (RIF) is an automated tool devised by SAHSU 
 * that rapidly addresses epidemiological and public health questions using 
 * routinely collected health and population data and generates standardised 
 * rates and relative risks for any given health outcome, for specified age 
 * and year ranges, for any given geographical area.
 *
 * Copyright 2016 Imperial College London, developed by the Small Area
 * Health Statistics Unit. The work of the Small Area Health Statistics Unit 
 * is funded by the Public Health England as part of the MRC-PHE Centre for 
 * Environment and Health. Funding for this project has also been received 
 * from the United States Centers for Disease Control and Prevention.  
 *
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

 * David Morley
 * @author dmorley
 */

/* 
 * CONTROLLER to handle alert bars and notifications over whole application
 */
angular.module("RIF")
        .controller('AlertCtrl', function ($scope, notifications) {
            $scope.delay = 0; // mS
			$scope.lastMessage = undefined;
			$scope.messageList = [];
			$scope.messageCount = undefined;
			$scope.messageStart = new Date().getTime();
			
			/*
			 * Function:	rifMessage()
			 * Parameters:	Level [ERROR/WARNING/SUCCESS], message, auto hide (after about 5s): true/false, rif Error object [optional] 
			 * Desription:	Call notifications.show* to display message to user
			 *				Log message to console with relative timestamp; save message in array
             *				Uses ngNotificationsBar.min and ngNotificationsBar.css
			 */
			function rifMessage(messageLevel, msg, rifHide, rifError) {
				var err; // Get stack
				if (rifError) {
					err=rifError;
				}
				else {
					err=new Error("Dummy");
				}
				
				if (angular.isUndefined($scope.lastMessage)) {
                    $scope.messageCount = 0;
				}
				if (angular.isUndefined($scope.lastMessageTime)) {
                    $scope.lastMessageTime = new Date().getTime();
				}				
				angular.copy(($scope.messageCount++));
				var end=new Date().getTime();
				var elapsed=(Math.round((end - $scope.messageStart)/100))/10; 
						// time since application init in S
				var msgInterval=(Math.round((end - $scope.lastMessageTime)/100))/10; 
						// time since last message in S	
				if (angular.isUndefined($scope.lastMessage) || $scope.lastMessage != msg || msgInterval > 5 /* Secs */) {
					console.log("+" + elapsed + ": [" + $scope.messageCount + "] " + messageLevel + ": " + msg);
					
					if (messageLevel.toUpperCase() == "ERROR") {	
						notifications.showError({message: 'Error: ' + msg, hideDelay: $scope.delay, hide: rifHide});	
						console.log("Stack: " + err.stack);
					}
					else if (messageLevel.toUpperCase() == "WARNING") {
						notifications.showWarning({message: 'Warning: ' + msg, hideDelay: $scope.delay, hide: rifHide});
					}
					else if (messageLevel.toUpperCase() == "SUCCESS") {
						notifications.showSuccess({message: 'Success: ' + msg, hideDelay: $scope.delay, hide: rifHide});
					}	
				}
                $scope.lastMessage = angular.copy(msg);
				var msgList = $scope.messageList;
				var msgItem = {
					sequence:	$scope.messageCount,
					message: 	msg,
					time:		end,
					stack:		err.stack,
					relative:	elapsed,
					level:		messageLevel
				}
				msgList.push(msg); 
				$scope.messageList = angular.copy(msgList);			
			}
			
            $scope.showError = function (msg) {
				rifMessage("ERROR", msg, true);
            };
            $scope.showWarning = function (msg) {
				rifMessage("WARNING", msg, true);
            };
            $scope.showSuccess = function (msg) {
				rifMessage("SUCCESS", msg, true);
            };
            $scope.showErrorNoHide = function (msg) {
				rifMessage("ERROR", msg, false);
            };						
            $scope.showWarningNoHide = function (msg) {
				rifMessage("WARNING", msg, false);
            };
            $scope.showSuccessNoHide = function (msg) {
				rifMessage("SUCCESS", msg, false);
            };
        });