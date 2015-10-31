'use strict';

function modal_error(message, log) {
    return function(data,status,headers,config){
        log.log("Error: " + message);
    }
}

/* Controllers */

angular.module('myApp.controllers', []).
    // global variables of the App
    controller('AppCtrl', function($scope, $http, $location, $log) {
	$scope.refs = {
	    item: { }
	};
	// useful to change location
	$scope.go = function ( path ) { $location.path( path ); };
	// get the appname
	$http.get('/dibco/api/appname').
	    success(function(data,status,headers,config){
		$scope.appname = data.appname;
	    }).
	    error(modal_error('Unable to get appname', $log));
    }).
    // base controller for all the app pages
    controller('baseCtrl', function($scope, $http) {
    }).
    // controller for demo image submission
    controller('demoCtrl', function($scope, $http, $location, $log) {
        $scope.reset = function() {
            $scope.refs.item = {
                "image" : null,
                "example" : null,
                "model" : null
            };
        };
        $scope.reset();
        $http.get('/dibco/api/nets').
            success(function(data,status,headers,config){
                $scope.nets_list = data;
            }).
            error(modal_error('Unable to get nets list', $log));
        $http.get('/dibco/api/examples').
            success(function(data,status,headers,config){
                $scope.examples_list = data;
            }).
            error(modal_error('Unable to get examples list', $log));
        $scope.submitForm = function() {
            var fd = new FormData();
            if ($scope.refs.item.image != '') fd.append('image', $scope.refs.item.image);
            if ($scope.refs.item.example) fd.append('example', $scope.refs.item.example);
            fd.append('model', $scope.refs.item.model);
            $http.post("/dibco/api/clean", fd, {
                headers: {'Content-Type': undefined},
                transformRequest: angular.identity
            }).
                success(function(data, status, headers, config) {
                    $scope.dirty_image = "/dibco/images/dirty/"+data;
                    $scope.cleaned_image = "/dibco/images/clean/"+data;
                }).
                error(modal_error("Unable to process POST request", $log));
        };
    });
