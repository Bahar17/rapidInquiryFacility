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
 * CONTROLLER for disease submission reset model
 */
angular.module("RIF")
        .controller('ModalResetCtrl', ['$scope', '$uibModal', '$state', 'SubmissionStateService', 'StudyAreaStateService', 'CompAreaStateService', 'ParameterStateService', 'StatsStateService',
            function ($scope, $uibModal, $state, SubmissionStateService, StudyAreaStateService, CompAreaStateService, ParameterStateService, StatsStateService) {
                
                $scope.resetToDefaults = function () {
                    //reset all submission states to default
                    SubmissionStateService.resetState();
                    StudyAreaStateService.resetState();
                    CompAreaStateService.resetState();
                    ParameterStateService.resetState();
                    StatsStateService.resetState();
                    $scope.resetState();
                };

                $scope.resetState = function () {
                    //Reload submission (state1)
                    //i.e. gray the trees
                    $state.go('state1').then(function () {
                        $state.reload();
                    });
                };
                        
                $scope.modalHeader = "Reset Study";
                $scope.modalBody = "Are you sure?";   
                
                $scope.open = function () {
                    var modalInstance = $uibModal.open({
                        animation: true,
                        templateUrl: 'utils/partials/rifp-util-yesno.html',
                        controller: 'ModalResetYesNoInstanceCtrl',
                        windowClass: 'stats-Modal',
                        backdrop: 'static',
                        scope: $scope,
                        keyboard: false
                    });
                };
            }])
        .controller('ModalResetYesNoInstanceCtrl', function ($scope, $uibModalInstance) {
            $scope.close = function () {
                $uibModalInstance.dismiss();
            };
            $scope.submit = function () {
                $scope.showSuccess("RIF study reset");
                $scope.resetToDefaults();
                $uibModalInstance.close();
            };
        });