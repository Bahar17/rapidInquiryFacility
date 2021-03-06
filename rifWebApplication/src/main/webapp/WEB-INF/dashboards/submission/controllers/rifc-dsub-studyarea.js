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
 * CONTROLLER for disease submission study area modal
 */
/* global L */

angular.module("RIF")
        .controller('ModalStudyAreaCtrl', ['$state', '$scope', '$uibModal', 'StudyAreaStateService', 'SubmissionStateService', 'CompAreaStateService',
            function ($state, $scope, $uibModal, StudyAreaStateService, SubmissionStateService, CompAreaStateService) {
                $scope.tree = SubmissionStateService.getState().studyTree;
                $scope.animationsEnabled = false;
                $scope.open = function () {
                    var modalInstance = $uibModal.open({
                        animation: $scope.animationsEnabled,
                        templateUrl: 'dashboards/submission/partials/rifp-dsub-studyarea.html',
                        controller: 'ModalStudyAreaInstanceCtrl',
                        windowClass: 'modal-fit',
                        backdrop: 'static',
                        keyboard: false
                    });
                    modalInstance.result.then(function (input) {
                        //Change tree icon colour
                        if (input.selectedPolygon.length === 0) {
                            SubmissionStateService.getState().studyTree = false;
                            $scope.tree = false;
                        } else {
                            //if CompAreaStateService studyResolution is now greater than the new Study studyResolution
                            //then clear the comparison area tree and show a warning
                            //Study tree will not change
                            if (CompAreaStateService.getState().studyResolution !== "") {
                                if (input.geoLevels.indexOf(CompAreaStateService.getState().studyResolution) >
                                        input.geoLevels.indexOf(input.studyResolution)) {
                                    $scope.showError("Comparision area study resolution cannot be higher than for the study area");
                                    //clear the comparison tree
                                    SubmissionStateService.getState().comparisonTree = false;
                                    CompAreaStateService.getState().studyResolution = "";
                                    //reset tree
                                    $state.go('state1').then(function () {
                                        $state.reload();
                                    });
                                }
                            }
                            SubmissionStateService.getState().studyTree = true;
                            $scope.tree = true;
                        }

						$scope.areamap=SubmissionStateService.getAreaMap();
						SubmissionStateService.setRemoveMap(function() { // Setup map remove function
                            $scope.consoleDebug("[rifc-dsub-studyarea.js] remove shared areamap");
							$scope.areamap.remove(); 
						});
						
                        //Store what has been selected
                        StudyAreaStateService.getState().geoLevels = input.geoLevels;
                        StudyAreaStateService.getState().polygonIDs = input.selectedPolygon;
                        StudyAreaStateService.getState().selectAt = input.selectAt;
                        StudyAreaStateService.getState().studyResolution = input.studyResolution;
                        StudyAreaStateService.getState().center = input.center;
                        StudyAreaStateService.getState().geography = input.geography;
                        StudyAreaStateService.getState().transparency = input.transparency;
                        StudyAreaStateService.getState().type = input.type;
                    });
                };
            }])
        .controller('ModalStudyAreaInstanceCtrl', function ($scope, $uibModalInstance, StudyAreaStateService) {
            $scope.input = {};
            $scope.input.name = "StudyAreaMap";
            $scope.input.selectedPolygon = StudyAreaStateService.getState().polygonIDs;
            $scope.input.selectAt = StudyAreaStateService.getState().selectAt;
            $scope.input.studyResolution = StudyAreaStateService.getState().studyResolution;
            $scope.input.center = StudyAreaStateService.getState().center;
            $scope.input.geography = StudyAreaStateService.getState().geography;
            $scope.input.transparency = StudyAreaStateService.getState().transparency;  
            $scope.input.showSwitch = true;
            $scope.input.type = StudyAreaStateService.getState().type; 
            if ($scope.input.type === "Risk Analysis") {
                $scope.input.bands = [1, 2, 3, 4, 5, 6];
            } else {
                $scope.input.bands = [1];
            }

            $scope.close = function () {
                $uibModalInstance.dismiss();
            };
            $scope.submit = function () {
                $uibModalInstance.close($scope.input);
            };
        });