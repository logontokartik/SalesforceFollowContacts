/***************************************************************************
 Name 		: AuthorizeTwitter 
 Created By : Kartik Viswanadha (kartik.viswanadha@gmail.com)
 Created Date : 12/24/2012
 VisualForce Page :AuthorizeTwitter
 Description  : Controller class for AuthorizeTwitter VF Page that is the initial config page that performs twitter Authorization.
 
******************************************************************************/

public with sharing class AuthorizeTwitter {

	// Declarations

    private final String TWITTER_URL 	 = 'https://api.twitter.com';
    private final String OAUTH_REQ_URL 	 = '/oauth/request_token';
    private final String OAUTH_AUTH_URL  = '/oauth/authorize';
    private final String OAUTH_ACC_URL 	 = '/oauth/access_token';
    
    private String CALLBACK_URL 			= '/apex/AuthorizeTwitter';    
    private Map<String,String> headerParameters;
    
    public ForceTwitter__c setting {get;set;}
    public boolean settingsPresent {get;set;}
    
    
    
    // Constructor
    public AuthorizeTwitter(){
        
        headerParameters = new Map<String,String>();
        settingsPresent	 = false;
        
        List<ForceTwitter__c> settings 		 = ForceTwitter__c.getAll().values(); // check if Config Settings are present
        
        if(settings.size() > 0){
        	settingsPresent = true;
        	setting = settings[0];
        }else {
        	setting = new ForceTwitter__c();
        }
        
    }
    
    
    /*
    	Save the configs, Name is the only required field, the other fields are pre-filled from my Twitter APP, if not provided
    */
    
    public void saveConfigs(){
    	
    	setting.TwitterURL__c = TWITTER_URL; 
    	
    	if(setting.ConsumerKey__c == null || setting.ConsumerKey__c == '')
    		setting.ConsumerKey__c = TwitterConfig.CONSUMER_KEY;
    	
    	if(setting.ConsumerSecret__c == null || setting.ConsumerSecret__c == '')
    		setting.ConsumerSecret__c = TwitterConfig.CONSUMER_SECRET;
    	
    	upsert setting;
    	
    	settingsPresent = true;
    	
    }
    
    /*
    	Method called on the Redirect from the Twitter Authentication Page
    */
    
    public void saveTokens(){
        
        
        // Check to see if the page has oauth_token and oauth_verifier on the page parameters.
        
        if(Apexpages.currentPage().getParameters().get('oauth_token') != null && Apexpages.currentPage().getParameters().get('oauth_verifier') != null){
        
            String oauthToken    = Apexpages.currentPage().getParameters().get('oauth_token');
            String oauthVerifier = Apexpages.currentPage().getParameters().get('oauth_verifier');
        
            headerParameters = new Map<String,String>();
      		headerParameters = TwitterConfig.getDefaultHeaders();
       
			headerParameters.put('oauth_token', oauthToken);            
      		headerParameters.put('oauth_verifier',oauthVerifier);
		
        	String oAuthHeader 	 = TwitterConfig.getOAuthHeader(headerParameters, new Set<String>{'oauth_verifier'}, new Set<String>());
      	
      		String signature 	 = TwitterConfig.getOAuthSignature(headerParameters, TWITTER_URL + OAUTH_ACC_URL, 'POST', new Set<String>{'oauth_verifier'},false);
      	
        	oAuthHeader += 'oauth_signature=' + '"' + signature + '"';
		
			// Perform a HttpCall to get the OAuth Token and Token Secret from Twitter.
		
            String response = HttpUtil.performHttpRequest('oauth_verifier=' + oauthVerifier, TWITTER_URL + OAUTH_ACC_URL, 'POST', 'application/x-www-form-urlencoded', oAuthHeader);
                  
            List<String> responses = response.split('&',4);
            
            for(String s : responses){
            	if(s.subStringBefore('=') == 'oauth_token')
            		setting.OAuthToken__c = s.subStringAfter('=');
            		
            	if(s.subStringBefore('=') == 'oauth_token_secret')
            		setting.OauthTokenSecret__c = s.subStringAfter('=');
            	
            	if(s.subStringBefore('=') == 'user_id')
            		setting.UserId__c = s.subStringAfter('=');
            	
            		
            	if(s.subStringBefore('=') == 'screen_name')
            		setting.ScreenName__c = s.subStringAfter('=');
            		
            }
            
            update setting; // Update the Settings.
            
        }
    
    }
    
    /*
    	Method called when user clicks on Authorize button on the page. Performs the first Authorize call to Twitter and builds the redirect URI
    */
    
    public Pagereference authorize(){
        
        Pagereference redirectURI; 
        
        String callback = 'https://'+ ApexPages.currentPage().getHeaders().get('Host') + CALLBACK_URL; // Build the callback
        
        headerParameters = new Map<String,String>();
        
        headerParameters = TwitterConfig.getDefaultHeaders();
       
		headerParameters.put('oauth_callback', callback);            
      
      	String oAuthHeader 	 = TwitterConfig.getOAuthHeader(headerParameters, new Set<String>(), new Set<String>{'oauth_callback'});
      	
      	String signature 	 = TwitterConfig.getOAuthSignature(headerParameters, TWITTER_URL + OAUTH_REQ_URL, 'POST', new Set<String>{'oauth_callback'},false);
      	
        oAuthHeader += 'oauth_signature=' + '"' + signature + '"';
		  
        system.debug('sf '+signature);
        
        // Do a HTTP post to the Twitter OAuth Req URI and get the Redirect URI.
        
        String response = HttpUtil.performHttpRequest(null, TWITTER_URL + OAUTH_REQ_URL, 'POST', null, oAuthHeader);
        
        String oauthToken = response.subStringBefore('&');
        
        system.debug(oauthToken);
        
        redirectURI = new Pagereference(TWITTER_URL + OAUTH_AUTH_URL + '?' + oauthToken);
        
        return redirectURI;
        
    }
    
}