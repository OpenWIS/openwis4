/**
 * In this file we add to the original dependencies of the "module".
 * The custom Wro4j will search for files providing the required modules and package them into its resources 
 */

(function() {
	
	goog.provide('gn_usergroup_controller');
	  
	goog.require('injector.gn_usergroup_controller');
	goog.require('gn_openwis_blacklist_controller');
	goog.require('gn_openwis_admin_subscription_controller');
	goog.require('gn_openwis_admin_request_controller');

})();
