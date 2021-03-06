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
 * CONTROLLER for the main 'tree' page
 */
angular.module("RIF")
        .controller('SumbmissionCtrl', ['$scope', 'user', '$state', 'SubmissionStateService', 'StudyAreaStateService', 'CompAreaStateService', 'ParameterStateService',
            function ($scope, user, $state, SubmissionStateService, StudyAreaStateService, CompAreaStateService, ParameterStateService) {
                /*
                 * STUDY, GEOGRAPHY AND FRACTION DROP-DOWNS
                 * Calls to API returns a chain of promises
                 */

                $scope.geographies = [];

                //Get geographies
                user.getGeographies(user.currentUser).then(handleGeographies, handleError); //1ST PROMISE
                function handleGeographies(res) {
                    $scope.geographies.length = 0;
                    for (var i = 0; i < res.data[0].names.length; i++) {
                        $scope.geographies.push(res.data[0].names[i]);
                    }
                    var thisGeography = SubmissionStateService.getState().geography;
                    if ($scope.geographies.indexOf(thisGeography) !== -1) {
                        $scope.geography = thisGeography;
                    } else {
                        $scope.geography = $scope.geographies[0];
                    }
                    SubmissionStateService.getState().geography = $scope.geography;
                    //Fill health themes drop-down
                    $scope.healthThemes = [];
                    user.getHealthThemes(user.currentUser, $scope.geography).then(handleHealthThemes, handleError); //2ND PROMISE
                }
                $scope.geographyChange = function () {
                    SubmissionStateService.getState().geography = $scope.geography;
                    //reset states using geography
                    StudyAreaStateService.resetState();
                    CompAreaStateService.resetState();
                    ParameterStateService.resetState();
                    SubmissionStateService.getState().comparisonTree = false;
                    SubmissionStateService.getState().studyTree = false;
                    SubmissionStateService.getState().investigationTree = false;
                    SubmissionStateService.getState().numerator = "";
                    SubmissionStateService.getState().denominator = "";
                    $scope.resetState();
                };

                //Get health themes
                function handleHealthThemes(res) {
                    $scope.healthThemes.length = 0;
                    for (var i = 0; i < res.data.length; i++) {
                        $scope.healthThemes.push({name: res.data[i].name, description: res.data[i].description});
                    }
                    $scope.healthTheme = $scope.healthThemes[0];
                    SubmissionStateService.getState().healthTheme = $scope.healthTheme;
                    $scope.healthThemeChange();
                }

                //Get relevant numerators and associated denominators
                $scope.fractions = [];
                $scope.healthThemeChange = function () {
                    if ($scope.healthTheme) {
                        SubmissionStateService.getState().healthTheme = $scope.healthTheme;
                        user.getNumerator(user.currentUser, $scope.geography, $scope.healthTheme.description).then(handleFractions, handleError); //3RD PROMISE
                    } else {
                        $scope.fractions.length = 0;
                    }
                };
                function handleFractions(res) {
                    $scope.fractions.length = 0;
                    for (var i = 0; i < res.data.length; i++) {
                        $scope.fractions.push(res.data[i]);
                    }
					$scope.consoleDebug("[rifc-dsub-main.js] handleFractions(): " + JSON.stringify($scope.fractions, null, 2));
                    if (angular.isDefined(SubmissionStateService.getState().numerator.length) && SubmissionStateService.getState().numerator.length !== 0) {
                        for (var i = 0; i < $scope.fractions.length; i++) {
                            var thisNum = SubmissionStateService.getState().numerator;
                            if ($scope.fractions[i].numeratorTableName === thisNum) {
                                $scope.numerator = $scope.fractions[i];
                                $scope.denominator = $scope.fractions[i].denominatorTableName;
                            }
                        }
                    } else {
                        $scope.numerator = $scope.fractions[0];
                        $scope.denominator = $scope.fractions[0].denominatorTableName;
                    }
                    SubmissionStateService.getState().numerator = $scope.numerator;
                    SubmissionStateService.getState().denominator = $scope.numerator;
                }

                //sync the denominator
                $scope.numeratorChange = function () {
                    if ($scope.numerator) {
                        $scope.denominator = $scope.numerator.denominatorTableName;
                    } else {
                        $scope.denominator = "";
                    }
					
					if (SubmissionStateService.getState().numerator != $scope.numerator &&
					    SubmissionStateService.getState().denominator != $scope.numerator) {
					
						$scope.consoleDebug("[rifc-dsub-main.js] numeratorChange(), reset investigation parameters: " + JSON.stringify($scope.numerator, null, 2));
						SubmissionStateService.getState().numerator = $scope.numerator;
						SubmissionStateService.getState().denominator = $scope.numerator;
						//This will have an impact on investigations year range, so reset investigation parameters
						ParameterStateService.resetState();
					}
					else {		
						$scope.consoleDebug("[rifc-dsub-main.js] numeratorChange(), no change: " + JSON.stringify($scope.numerator, null, 2));
					}	
                };

                function handleError(e) {
                    $scope.showError("Could not retrieve your project information from the database");
                }

                /*
                 * STUDY NAME
                 */
                $scope.studyName = SubmissionStateService.getState().studyName;
                $scope.studyNameChanged = function () {
                    SubmissionStateService.getState().studyName = $scope.studyName;
                };

                /*
                 * RESET
                 */
                $scope.resetState = function () {
                    $state.go('state1').then(function () {
                        $state.reload();
                    });
                };
            }]);