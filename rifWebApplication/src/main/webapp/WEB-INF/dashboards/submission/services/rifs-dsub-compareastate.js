/* SERVICE to store state of comparison area modal
 * will be used eventually to load studies
 */
angular.module("RIF")
        .factory('CompAreaStateService',
                function () {
                    var s = {
                        polygonIDs: [],
                        selectAt: "Select at",
                        studyResolution: "Study resolution",
                        zoomLevel: -1,
                        view: [0,0]
                    };
                    var defaults = JSON.parse(JSON.stringify(s));
                    return {
                        getState: function () {
                            return s;
                        },
                        resetState: function () {
                            s = defaults;
                        }
                    };
                });