'use strict';

/* Directives */

angular.module('myApp.directives', []).
    directive('appVersion', function (version) {
	return function(scope, elm, attrs) {
	    elm.text(version);
	};
    }).
    directive('fileModel', function ($parse) {
	return {
            restrict: 'A',
            link: function(scope, element, attrs) {
		var model = $parse(attrs.fileModel);
		var modelSetter = model.assign;
		
		element.bind('change', function(){
                    scope.$apply(function(){
			modelSetter(scope, element[0].files[0]);
                    });
		});
            }
	};
    }).
    directive('capitalize', function () {
        return {
            require: 'ngModel',
            link: function (scope, element, attrs, modelCtrl) {
                var capitalize = function (inputValue) {
                    if (angular.isUndefined(inputValue))
                        return;
		    
                    var capitalized = inputValue.toUpperCase();
                    if (capitalized !== inputValue) {
                        modelCtrl.$setViewValue(capitalized);
                        modelCtrl.$render();
                    }
                    return capitalized;
                }
                modelCtrl.$parsers.push(capitalize);
                capitalize(scope[attrs.ngModel]);  // capitalize initial value
            }
        };
    }).
    directive('titlecase', function() {
	return {
	    require: 'ngModel',
	    link: function(scope, element, attrs, modelCtrl) {
		var capitalize = function(inputValue) {
		    if (angular.isUndefined(inputValue)) return;
		    var capitalized =
			inputValue.replace(/\w\S*/g,
					   function(txt){
					       return txt.charAt(0).toUpperCase() +
						   txt.substr(1).toLowerCase();
					   });
		    if(capitalized !== inputValue) {
			modelCtrl.$setViewValue(capitalized);
			modelCtrl.$render();
		    }
		    return capitalized;
		}
		modelCtrl.$parsers.push(capitalize);
		capitalize(scope[attrs.ngModel]);  // capitalize initial value
	    }
	};
    });
