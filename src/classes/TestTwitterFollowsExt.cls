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
private class TestTwitterFollowsExt {

	// Test method to test the TwitterFollowsExt Class. 

    static testMethod void testTwitterFollows() {
       
        // Load the data
       
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
    	
    	List<Contact> contacts = new List<Contact>();
    	
    	contacts.add(new Contact(LastName='Test',FirstName='First',Persona__c='testScreen'));
    	contacts.add(new Contact(LastName='Test2',FirstName='First2',Persona__c='testScreen2'));
    	contacts.add(new Contact(LastName='Test3',FirstName='First3'));
    	
    	insert contacts;
    	
    	// Build the Response
    	
    	HttpResponse res = new HttpResponse();
    	res.setStatusCode(200);
    	
    	HttpUtil.testResponse = res;
    	
    	TwitterManager.followUser(contacts[0].Id); // Set this so that the contact user is already followed
    	
    	contacts = [Select Id, Name, Persona__c, Following__c from contact where Id in :contacts order by Following__c desc];
    	
    	system.assertEquals(true, contacts[0].Following__c);
    	
    	// Tests start here
    	
    	Test.startTest();
    	
	    	Apexpages.Standardsetcontroller setCon = new Apexpages.Standardsetcontroller(contacts);	    	
	    	TwitterFollowsExt testConfail = new TwitterFollowsExt(setCon);
	    		    	
	    	setCon.setSelected(contacts);	    	
	    	TwitterFollowsExt testCon = new TwitterFollowsExt(setCon);
	    	
	    	testCon.follow();
	    	
	    	contacts = [Select Id, Name, Persona__c, Following__c from contact where Id in :contacts order by Following__c];
    			
	    	system.assertEquals(false, contacts[0].Following__c);
    		system.assertEquals(true, contacts[1].Following__c);
    		system.assertEquals(true, contacts[2].Following__c);
    	
	    	
    	Test.stopTest();
    	
    	
    }
}