/**
 * This module only exists because of the wro4j limitations (no JS loads unless it's in lib.js or unless it's on a dependency tree).
 * The code in here will just inject a <script></script> at the end of the <body>.
 * It is injected at that place because may contain references to other angular modules and this ensures that they are already defined. 
 */

(function() {
	goog.provide('injector.gn_search');

	var module = angular.module('injector.gn_search', []);


})();

/**
 * Push a function to be executed on document.ready. This function will load an
 * html fragment containing a script and append it to the body. That script
 * contains further instructions for angular that could not be loaded because of
 * the wro4j limitations.
 * 
 */
JsUtil.FunctionsToExecuteOnReady
		.push(function() {
			JsUtil
					.appendHtmlContentIntoElement(
							$(document.body),
							'/geonetwork/catalog/components/openwis-extensions/gn_search/script.gn_search.html');
		});
