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
private class TestAuthorizeTwitter {

    static testMethod void testAuthorize() {
    	
    	Test.StartTest();
    	
    	AuthorizeTwitter testCon = new AuthorizeTwitter(); // Build the AuthorizeTwitter Instance.
    	
    	system.assertEquals(false,testCon.settingsPresent); // No Configs present.
    	
    	testCon.setting.Name = 'Test Config';
    	testCon.saveConfigs(); // Save Configs
    	
    	system.assertEquals(true,testCon.settingsPresent);
    	
    	List<ForceTwitter__c> settings = ForceTwitter__c.getAll().values();
    	system.assertEquals(1,settings.size());
    	
    	AuthorizeTwitter testCon2 = new AuthorizeTwitter(); // Build another instance
    	
    	system.assertEquals(true,testCon.settingsPresent);
    	
    	Pagereference testPage = Page.AuthorizeTwitter;
        Test.setCurrentPageReference(testPage);
        
        HttpResponse res = new HttpResponse();
        
        res.setStatusCode(200);
        res.setBody('oauth_token=1234541&access=true'); // Test HttpResponse
        
        HttpUtil.testResponse = res;
        
        testCon2.authorize();
        
        // Load the Page Parameters
        
        Apexpages.currentPage().getParameters().put('oauth_token','123test');
        Apexpages.currentPage().getParameters().put('oauth_verifier','123verify');
       
        res = new Httpresponse();
        res.setStatusCode(200);
        res.setBody('oauth_token=123testtoken&oauth_token_secret=123secret&user_id=111&screen_name=testscreen');
        
        HttpUtil.testResponse = res;
        
        testCon.saveTokens();
        
        settings = ForceTwitter__c.getAll().values();
        
        system.assertEquals('123testtoken',settings[0].OAuthToken__c);
        system.assertEquals('123secret',settings[0].OAuthTokenSecret__c);
        system.assertEquals('testscreen',settings[0].ScreenName__c);
        system.assertEquals('111',settings[0].UserID__c);
       
        Test.StopTest();
       
       
    }
}