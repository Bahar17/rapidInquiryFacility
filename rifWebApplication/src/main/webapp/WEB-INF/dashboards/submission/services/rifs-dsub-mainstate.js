/* SERVICE to store state of main submission page
 * will be used eventually to load studies
 */
angular.module("RIF")
        .factory('SubmissionStateService', 
                function () {
                    var s = {
                        //these are on the main disease submission page
                        studyTree: false,
                        comparisonTree: false,
                        investigationTree: false,
                        statsTree: false,
                        studyName: "", //1
                        healthTheme: "", //2
                        geography: "SAHSU", //3
                        numerator: "", //4
                        denominator: "", //5
                        //these are in the run-study modal
                        projectName: "",
                        projectDescription: "",
                        studyDescription: ""
                    };
                    var defaults = angular.copy(JSON.parse(JSON.stringify(s)));
                    return {
                        getState: function () {
                            return s;
                        },
                        resetState: function () {
                            s = angular.copy(defaults);
                        }
                    };
                });