/**
 * This is a collection of utility functions required to assist with injection of external modules into the original angular application.
 * It MUST be loaded before angular is loaded but after jQuery is loaded!  
 * @returns
 */
function JsUtil(){};

/**
 * Angular helper object
 */
JsUtil.Angular = function(){};

/**
 * To be used for in-the-fly compilation
 */
JsUtil.Angular.Compile = null;

/**
 * This object maps a src to a function. It will be used for executing code when a route or include is loaded
 */
JsUtil.SrcFunctionMapping = {
	'src': '',
	'func': null
}

/**
 * Holds the mappings of functions to execute when an include successfully loads.
 */
JsUtil.FunctionsToExecuteOnIncludeLoadSuccess = new Array();

/**
 * Holds the mappings of functions to execute when a route successfully loads.
 */
JsUtil.FunctionsToExecuteOnRouteLoadSuccess = new Array();

/**
 * This array will be populated with functions that will be executed on document.ready
 */
JsUtil.FunctionsToExecuteOnReady = new Array();

/**
 * This array will be populated with javascript objects of the following structure:
 * 
 * {
 * 	'original-controller': 'name of the original controller',
 * 	'replacement-controller': 'name of the new controller that will replace the original one'
 * }
 * 
 * The idea is that the replacement-controller extends the original one and only overrides some specific functionality.
 * In the modified angular source, a check will be made when a controller is to be linked.
 * If that controller is included in this array, then the replacement controller is  linked instead.
 */
JsUtil.controllersToReplace = new Array();

/**
 * This function will search the JsUtil.controllersToReplace array and return the name of the replacement controller.
 * If no replacement controller is registered, the name of the original controller is returned. 
 */
JsUtil.getReplacementController = function(originalControllerName){
	for(var i=0; i< JsUtil.controllersToReplace.length; i++){
		var controllerData = JsUtil.controllersToReplace[i];
		if(controllerData['original-controller'] === originalControllerName){
			return controllerData['replacement-controller'];
		}
	}	
	return originalControllerName;
};

/**
 * Registers a new controller to replace an existing one when angular links the component.
 * The original controller still exists as an object and the replacement "should" extend it and only override specific functionality
 */
JsUtil.registerReplacementController = function(originalControllerName, replacementControllerName){
	var controllerData = {
			'original-controller': originalControllerName,
			'replacement-controller': replacementControllerName
	};	
	JsUtil.controllersToReplace.push(controllerData);
};

/**
 * This will loop through all functions registered for execution and run them.
 * Then it will clear the array. 
 */
JsUtil.executeFunctionsOnReady = function(){
	for(var i=0;i<JsUtil.FunctionsToExecuteOnReady.length;i++){
		var f = JsUtil.FunctionsToExecuteOnReady[i];
		f();
	}
	JsUtil.FunctionsToExecuteOnReady.length = 0;
};

/**
 * Appends the contents of a specific URL (absolute or relative) into a JQuery element
 */
JsUtil.appendHtmlContentIntoElement = function(jqTargetElement, url){
	var tempDiv = $('<div></div>');
	jQuery.ajaxSetup({async:false});
	tempDiv.load(url, function(){
		tempDiv.children().each(function () {
			//console.log('appending: ' + this.outerHTML);
			jqTargetElement.append($(this).clone());
		});
		tempDiv.remove();
		jQuery.ajaxSetup({async:true});
	});
};
/**
 * Prepends the contents of a specific URL (absolute or relative) into a JQuery element
 */
JsUtil.prependHtmlContentIntoElement = function(jqTargetElement, url){
	var tempDiv = $('<div></div>');
	jQuery.ajaxSetup({async:false});
	var elementsToPrepend = new Array();
	tempDiv.load(url, function(){
		tempDiv.children().each(function () {
			//console.log('appending: ' + this.outerHTML);
			elementsToPrepend.push($(this).clone());
		});
		jqTargetElement.prepend(elementsToPrepend);
		tempDiv.remove();
		jQuery.ajaxSetup({async:true});
	});
};

/**
 * Adds a function to be executed when a specific include loads successfully.
 * The srcSegment will be matched in an "endsWith" manner. This is because the src returned by angular events
 * usually looks like "../../dir1/dir2/dir3/dir4/file.html" and such long src may lead to errors.
 * Using "endsWith" matching allows to only supply the segment of the filepath required to correctly identify the full src.
 */
JsUtil.addFunctionToExecuteOnIncludeLoadSuccess = function(srcSegment, func){
	var mapping = Object.create(JsUtil.SrcFunctionMapping);
	mapping.src = srcSegment;
	mapping.func = func;
	JsUtil.FunctionsToExecuteOnIncludeLoadSuccess.push(mapping);
}

/**
 * This is called from an event handler. It will search if there are any registered mappings
 * which match (using endsWith) this src, and if found, will execute the associated functions.
 */
JsUtil.executeOnIncludeLoadSuccess = function(src){
	for(var i=0;i<JsUtil.FunctionsToExecuteOnIncludeLoadSuccess.length;i++){
		var mapping = JsUtil.FunctionsToExecuteOnIncludeLoadSuccess[i];
		if(src.endsWith(mapping.src)){
			var func = mapping.func;
			func();
		}
	}
}

/**
 * Adds a function to be executed when a specific route loads successfully.
 * The srcSegment will be matched in an "endsWith" manner. This is because the src returned by angular events
 * usually looks like "../../dir1/dir2/dir3/dir4/file.html" and such long src may lead to errors.
 * Using "endsWith" matching allows to only supply the segment of the filepath required to correctly identify the full src.
 */
JsUtil.addFunctionToExecuteOnRouteLoadSuccess = function(srcSegment, func){
	var mapping = Object.create(JsUtil.SrcFunctionMapping);
	mapping.src = srcSegment;
	mapping.func = func;
	JsUtil.FunctionsToExecuteOnRouteLoadSuccess.push(mapping);
}

/**
 * This is called from an event handler. It will search if there are any registered mappings
 * which match (using endsWith) this src, and if found, will execute the associated functions.
 */
JsUtil.executeOnRouteLoadSuccess = function(src){
	for(var i=0;i<JsUtil.FunctionsToExecuteOnRouteLoadSuccess.length;i++){
		var mapping = JsUtil.FunctionsToExecuteOnRouteLoadSuccess[i];
		if(src.endsWith(mapping.src)){
			var func = mapping.func;
			func();
		}
	}
}

/**
 * This will load a utility angular module, used to track route and include load events
 */
JsUtil.loadJsUtilAngularModule = function(){
	var jsUtilModule = angular.module('js-util', []);

	jsUtilModule.run(function($rootScope, $timeout, $document, $compile){

		JsUtil.Angular.Compile = $compile;
				
		$rootScope.$on("$routeChangeSuccess", function(event, currentRoute, previousRoute){

			/*console.log('routeChangeSuccess event:');
			console.log(event);
			console.log('currentRoute:');
			console.log(currentRoute);
			console.log('previousRoute:');
			console.log(previousRoute);			*/

			JsUtil.executeOnRouteLoadSuccess(currentRoute.loadedTemplateUrl);
		});

		$rootScope.$on("$includeContentLoaded", function(event, src){

			/*console.log('includeContentLoaded event:');
			console.log(event);
			console.log('src: ' + src);*/

			$timeout(JsUtil.executeOnIncludeLoadSuccess(src));
			
		});
	});
	var mainModule = $('[ng-app]').first();
	var mainModuleName = mainModule.attr('ng-app');
	//console.log(mainModuleName);
	angular.module(mainModuleName).requires.push('js-util');
}

/**
 * 
 */
JsUtil.appendModuleLoader = function(){
	var script = $('<script>');
	script.html('JsUtil.loadJsUtilAngularModule();');
	$(document.body).append(script);
}

/**
 * Runs on document.ready
 */
$(document).ready(function(){
	JsUtil.appendModuleLoader();
	JsUtil.executeFunctionsOnReady();	
});
/**
 * Polyfill for endsWith
 */
if (!String.prototype.endsWith) {
  String.prototype.endsWith = function(searchString, position) {
      var subjectString = this.toString();
      if (typeof position !== 'number' || !isFinite(position) || Math.floor(position) !== position || position > subjectString.length) {
        position = subjectString.length;
      }
      position -= searchString.length;
      var lastIndex = subjectString.lastIndexOf(searchString, position);
      return lastIndex !== -1 && lastIndex === position;
  };
};
