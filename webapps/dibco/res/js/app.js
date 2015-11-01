'use strict';

// Declare app level module which depends on filters, and services

angular.module('myApp', [
    'ngRoute',
    'myApp.controllers',
    'myApp.filters',
    'myApp.services',
    'myApp.directives'
]).
    config(function ($routeProvider, $locationProvider) {
	$routeProvider.
	    when('/dibco/demo', {
		templateUrl: '/dibco/views/partials/demo.html',
		controller: 'baseController'
	    }).
            when('/dibco/result', {
		templateUrl: '/dibco/views/partials/result.html',
		controller: 'baseController'
	    }).
            // etc. etc. etc.
	    otherwise({
		redirectTo: '/dibco/demo'
	    });

	$locationProvider.html5Mode(true);
    });
