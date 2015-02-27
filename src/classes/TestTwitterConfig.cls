/*

	Test Class for the TwitterConfig Class

*/


@isTest
private class TestTwitterConfig {

	static testmethod void testConfigMethod(){
		
		// Insert basic Config record with just the Name
		
		ForceTwitter__c newC = new ForceTwitter__c();
    	newC.Name = 'Test Config';
    	insert newC;
    	
    	// Get the Configs, 
    	
		TwitterConfig.getBaseURL();
		TwitterConfig.getConsumerKey();
		TwitterConfig.getConsumerSecret();
		TwitterConfig.getOAuthToken();
		TwitterConfig.getOAuthSecret();
		
		
		// Update the configs with values
		
		List<ForceTwitter__c> settings 		 = ForceTwitter__c.getAll().values();
        
        settings[0].OAuthToken__c = 'test123';
        settings[0].OauthTokenSecret__c = 'secret';
        settings[0].ConsumerKey__c = '123';
    	settings[0].ConsumerSecret__c = 'abc';
    	settings[0].TwitterURL__c = 'https://api.twitter.com';	
    	
        update settings;
        
        Test.StartTest();
        
        // Get the values and perform the asserts
        system.assertEquals(settings[0].TwitterURL__c,TwitterConfig.getBaseURL());
		system.assertEquals(settings[0].ConsumerKey__c,TwitterConfig.getConsumerKey());
		system.assertEquals(settings[0].ConsumerSecret__c,TwitterConfig.getConsumerSecret());
		system.assertEquals(settings[0].OAuthToken__c,TwitterConfig.getOAuthToken());
		system.assertEquals(settings[0].OauthTokenSecret__c,TwitterConfig.getOAuthSecret());
		
		TwitterConfig.generateGUID(); // generate GUID
		
		Map<String,String> defaultHeaders = TwitterConfig.getDefaultHeaders(); // Get the Default headers.
		
		system.assertEquals(5,defaultHeaders.size());
		
		defaultHeaders.put('oauth_token', 'test123');     
		       
		// Get the OAuth Signature and OAuth Authentication Header       
      	String oAuthHeader 	 = TwitterConfig.getOAuthHeader(defaultHeaders, new Set<String>{'oauth_token'}, new Set<String>());     	
      	String signature 	 = TwitterConfig.getOAuthSignature(defaultHeaders, TwitterConfig.getBaseURL(), 'POST', new Set<String>{'oauth_token'},false);
      	
		Test.StopTest();
		
	}


}