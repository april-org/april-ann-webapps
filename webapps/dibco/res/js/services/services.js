'use strict';

/* Services */

// Demonstrate how to register services
// In this case it is a simple value service.
angular.module('myApp.services', []).
    value('version', '0.1').
    service('fileUploadService', function ($http) {
	this.uploadFileToUrl = function(file, uploadUrl){
            var fd = new FormData();
            fd.append('image', file);
            $http.post(uploadUrl, fd, {
		transformRequest: angular.identity,
		headers: {'Content-Type': undefined}
            }).
		success(function(){
		}).
		error(function(){
		});
	}
    });
