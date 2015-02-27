/***************************************************************************
 Name 		: TwitterManager 
 Created By : Kartik Viswanadha (kartik.viswanadha@gmail.com)
 Created Date : 12/24/2012
 VisualForce Page :TwitterManager
 Description  : Manager class that performs the following actions :
 
 				1. Follows the Twitter User (Contact's Persona), when a contact Id is supplied, and updates the Contact Record's Following__c flag.
 				2. Follows the Twitter User (Contact's Persona), when a Contact Record is supplied
 
******************************************************************************/

global with sharing class TwitterManager {

	private static String TWITTER_FOLLOW = '/friendships/create.json';
	
	/*
		The method is written as a webservice method in order for the Contact's StandardButton Javascript Code to call this method using sforce.apex.execute() (AJAX) call.
		Accepts ContactId, this method performs a Http POST call to Twitter using the stored Custom Settings and follows the User on Contact's Persona.
		Also updates the Contact Record (Following__c field)
	*/
	
	webservice static void followUser(String conId){
			
			String endpoint = TwitterConfig.TWITTER_URL + TwitterConfig.VERSION_1 + TWITTER_FOLLOW; // build end point
			
			Contact con = [Select Id, Persona__c, Following__c from Contact where Id =:conId]; // Get the Contact Record
			
			Map<String,String> headerParameters = new Map<String,String>();
			headerParameters = TwitterConfig.getDefaultHeaders();
			
			headerParameters.put('oauth_token', TwitterConfig.getOAuthToken());		
			headerParameters.put('screen_name',con.Persona__c);
	        headerParameters.put('follow','true');
	        
	        // Build the headers, 
	        
	        String oAuthHeader 	 = TwitterConfig.getOAuthHeader(headerParameters, new Set<String>{'screen_name','follow'}, new Set<String>());
      	
      		String signature 	 = TwitterConfig.getOAuthSignature(headerParameters, endpoint, 'POST', new Set<String>{'screen_name','follow'},true);
      	
        	oAuthHeader += 'oauth_signature=' + '"' + signature + '"';
			
			String postBody = 'screen_name='+ con.Persona__c + '&follow=true';
			
			// Perform the HttpCall
			
            String response = HttpUtil.performHttpRequest(postBody, endpoint, 'POST', 'application/x-www-form-urlencoded', oAuthHeader);
        
          	system.debug(response);
	      		
	      	con.Following__c = true; // Set the Following__c to true and update the contact record.
	      		
	      	update con;
	      
	      
	}
	
	/*
		A static method that performs the HttpCall to Twitter to follow a User, similar to the above, but doesnt have an update DML.
	
	*/
	
	public static void followUser(Contact con){
			
			String endpoint = TwitterConfig.TWITTER_URL + TwitterConfig.VERSION_1 + TWITTER_FOLLOW;
		
			Map<String,String> headerParameters = new Map<String,String>();
			headerParameters = TwitterConfig.getDefaultHeaders();
			
			headerParameters.put('oauth_token', TwitterConfig.getOAuthToken());		
			headerParameters.put('screen_name',con.Persona__c);
	        headerParameters.put('follow','true');
	        
	        String oAuthHeader 	 = TwitterConfig.getOAuthHeader(headerParameters, new Set<String>{'screen_name','follow'}, new Set<String>());
      	
      		String signature 	 = TwitterConfig.getOAuthSignature(headerParameters, endpoint, 'POST', new Set<String>{'screen_name','follow'},true);
      	
        	oAuthHeader += 'oauth_signature=' + '"' + signature + '"';
			
			String postBody = 'screen_name='+ con.Persona__c + '&follow=true';
			
            String response = HttpUtil.performHttpRequest(postBody, endpoint, 'POST', 'application/x-www-form-urlencoded', oAuthHeader);
        
          	system.debug(response);
	      
	}



}