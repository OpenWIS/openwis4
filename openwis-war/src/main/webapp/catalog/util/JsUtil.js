/**
 * This is a collection of utility functions required to assist with injection of external modules into the original angular application.
 * It MUST be loaded before angular is loaded but after jQuery is loaded!  
 * @returns
 */
function JsUtil(){};

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
JsUtil.executeFunctions = function(){
	for(var i=0;i<JsUtil.FunctionsToExecuteOnReady.length;i++){
		var f = JsUtil.FunctionsToExecuteOnReady[i];
		f();
	}
	JsUtil.FunctionsToExecuteOnReady.length = 0;
};

/**
 * Loads the contents of a specific URL (absolute or relative) into a JQuery object
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
 * Runs on document.ready
 */
$(document).ready(function(){
	JsUtil.executeFunctions();	
});
