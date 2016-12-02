/**
 * In this file we add to the original dependencies of the "module".
 * The custom Wro4j will search for files providing the required modules and package them into its resources 
 */

(function() {
	
	goog.provide('gn_adminmetadata_controller');
	  
	goog.require('injector.gn_adminmetadata_controller');
	goog.require('gn_openwis_productmetadata_controller');
	goog.require('gn_openwis_admin_subscription_controller');

})();
