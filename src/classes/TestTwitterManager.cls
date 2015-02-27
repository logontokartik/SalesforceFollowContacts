/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestTwitterManager {

	
	// Test Methods to test the Twitter Managers 2 Static methods.

    static testMethod void testTwitter() {
        
        // Load Data
        
        ForceTwitter__c newC = new ForceTwitter__c();
    	newC.Name = 'Test Config';
    	newC.OAuthToken__c = 'test123';
        newC.OauthTokenSecret__c = 'secret';
        newC.ConsumerKey__c = '123';
    	newC.ConsumerSecret__c = 'abc';
    	newC.TwitterURL__c = 'https://api.twitter.com';	
    	newC.ScreenName__c = 'testScreen';
    	newC.UserId__c = '111';
    	
    	insert newC;
    	
    	
    	Contact c = new Contact(LastName='Test',FirstName='First',Persona__c='testScreen');
    	
    	insert c;
    	
    	HttpResponse res = new HttpResponse();
    	res.setStatusCode(200);
    	
    	HttpUtil.testResponse = res;
    	
    	// Start Tests
    	
    	Test.StartTest();
    	
	    	TwitterManager.followUser(c.Id);
	    	
	    	c = [Select Id, Name, Persona__c, Following__c from Contact where Id = :c.Id];
	    	
	    	system.assertEquals(true,c.Following__c); // assert that the following is set to true
	    	
    	Test.StopTest();
        
        
    }
    
    static testMethod void testTwitter2(){
    	
    	// Load Data
    		
    	ForceTwitter__c newC = new ForceTwitter__c();
    	newC.Name = 'Test Config';
    	newC.OAuthToken__c = 'test123';
        newC.OauthTokenSecret__c = 'secret';
        newC.ConsumerKey__c = '123';
    	newC.ConsumerSecret__c = 'abc';
    	newC.TwitterURL__c = 'https://api.twitter.com';	
    	newC.ScreenName__c = 'testScreen';
    	newC.UserId__c = '111';
    	
    	insert newC;
    	
    	Contact c = new Contact(LastName='Test',FirstName='First',Persona__c='testScreen');
    	
    	insert c;
    	
    	HttpResponse res = new HttpResponse();
    	res.setStatusCode(200);
    	
    	HttpUtil.testResponse = res;
    	
    	Test.StartTest();
    	
	    	TwitterManager.followUser(c);
	    	
	    	c = [Select Id, Name, Persona__c, Following__c from Contact where Id = :c.Id];
	    	
	    	system.assertEquals(false,c.Following__c);
	    	
    	Test.StopTest();
     
    }
    
    
}