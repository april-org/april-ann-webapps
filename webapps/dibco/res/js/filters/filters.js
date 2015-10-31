'use strict';

/* Filters */

angular.module('myApp.filters', []).
    filter('interpolate', function (version) {
	return function (text) {
	    return String(text).replace(/\%VERSION\%/mg, version);
	}
    }).
    filter('textSearch', function() {
	return function(items, texto) {
            var filtrado = []; 
	    texto = texto.toLowerCase();
	    angular.forEach(items, function(item) {
		if( item.label.toLowerCase().indexOf(texto) >= 0 )
		    filtered.push(item);
	    });
            return filtered;
	}
    }).
    filter('imageBase64', function() {
	return function(input) {
	    if (!angular.isUndefined(input)) {
		return 'loading.gif';
	    }
	    else
		return 'loading.gif';
	}
    });
