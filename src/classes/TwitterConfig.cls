/***************************************************************************
 Name 		: TwitterConfig 
 Created By : Kartik Viswanadha (kartik.viswanadha@gmail.com)
 Created Date : 12/24/2012
 Description  : Twitter Configuration Class. Does the following
 
 				1. Returns the Custom Settings, Configurations
 				2. Builds the OAuth Signature
 				3. Builds the OAuth Authentication Headers
 				4. Generates the random GUID
 
******************************************************************************/
public with sharing class TwitterConfig {

    public static String TWITTER_URL 	    = 'https://api.twitter.com';
	public static String CONSUMER_KEY 		= 'G3qCXl4OLeje4Fqolr2QA';
	public static String CONSUMER_SECRET    = 'C1AdfOo81ioEu5qGOVE05PYhvT3mq5S98XvwvDp8Io'; 
	public static String SIGNATURE_METHOD   = 'HMAC-SHA1';
	public static String VERSION		    = '1.0';
	public static String VERSION_1		    = '/1.1';
	
	private static String kHexChars = '0123456789abcdefABCDEF';
	
	
	/*
		Methods to Return the Custom Settings	
	*/
	public static String getConsumerKey(){
		
		if(ForceTwitter__c.getAll().values()[0].ConsumerKey__c != null)
			return ForceTwitter__c.getAll().values()[0].ConsumerKey__c.trim();
		else
			return null;	
		
	}
	
	public static String getConsumerSecret(){
		
		if(ForceTwitter__c.getAll().values()[0].ConsumerSecret__c != null)
			return ForceTwitter__c.getAll().values()[0].ConsumerSecret__c.trim();
		else
			return null;
		
	}
	
	public static String getBaseURL(){
	
		if(ForceTwitter__c.getAll().values()[0].TwitterURL__c != null)		
			return ForceTwitter__c.getAll().values()[0].TwitterURL__c.trim();
		else
			return null;	
	
		
	}
	
	public static String getOAuthToken(){
		
		if(ForceTwitter__c.getAll().values()[0].OAuthToken__c != null)				
			return ForceTwitter__c.getAll().values()[0].OAuthToken__c.trim();
		else
			return null;	
	
		
	}
	
	public static String getOAuthSecret(){
	
		if(ForceTwitter__c.getAll().values()[0].OauthTokenSecret__c != null)	
			return ForceTwitter__c.getAll().values()[0].OauthTokenSecret__c.trim();
		else
			return null;	
		
	}
	
	/*
		Build the OAuth Headers as Map for default ones 
	*/
	
	public static Map<String,String> getDefaultHeaders(){
		
			Map<String,String> headerParameters = new Map<String,String>();
			
			headerParameters.put('oauth_consumer_key', TwitterConfig.getConsumerKey());
			headerParameters.put('oauth_nonce', TwitterConfig.generateGUID().Replace('-', ''));	
			headerParameters.put('oauth_signature_method', TwitterConfig.SIGNATURE_METHOD);
			headerParameters.put('oauth_timestamp', String.valueof(DateTime.now().getTime() / 1000));
			headerParameters.put('oauth_version',TwitterConfig.VERSION);
	        
			return headerParameters;
		
	}
	
	/*
		Return the OAuth Signature for the provided arguments inputs
	*/
	
	public static String getOAuthSignature(Map<String,String> headerParameters, String endPoint, String method, Set<String> bodyParms, boolean useSecret){
		
		Map<String,String> sortedheaderPs = new Map<String,String>();
        List<String> sortedKeys = new List<String>();
        sortedKeys.addAll(headerParameters.keySet());
        sortedKeys.sort();
        
        String tokenSecret;
        
        if(useSecret)
        	tokenSecret = TwitterConfig.getOAuthSecret();
        
		String concat 	   = '';
	        
	    for(String s : sortedKeys){
		    if (bodyParms.contains(s))			    
		        concat += s + '=' + EncodingUtil.urlEncode(headerParameters.get(s),'UTF-8') + '&';		// Encode all URLs and Body Parameters	    
		    else			    
		        concat += s + '=' + headerParameters.get(s) + '&';
			    	
	    }
	    
	    concat = concat.removeEnd('&');
        concat = EncodingUtil.urlEncode(concat,'UTF-8');
        concat =  method + '&' + EncodingUtil.urlEncode(endPoint,'UTF-8') + '&' + concat;
        Blob sig = Crypto.generateMac('HmacSHA1', Blob.valueOf(concat), Blob.valueOf(TwitterConfig.getConsumerSecret() + '&' + (tokenSecret!=null ? tokenSecret : '')));
        String signature = EncodingUtil.urlEncode(EncodingUtil.base64encode(sig), 'UTF-8');
        
        return signature;
            
	}
	
	/*
		Return the OAuth Header for the provided arguments input
	*/
	
	public static String getOAuthHeader(Map<String,String> headerParameters, Set<String> bodyParms, Set<String> urlParms){
		
		Map<String,String> sortedheaderPs = new Map<String,String>();
        List<String> sortedKeys = new List<String>();
        sortedKeys.addAll(headerParameters.keySet());
        sortedKeys.sort();
        
		String OAuthHeader = 'OAuth ';
           
	    for(String s : sortedKeys){
		  	if (urlParms.contains(s))
		        OAuthHeader += s + '=' + '"' + EncodingUtil.urlEncode(headerParameters.get(s),'UTF-8') + '", '; // Encode URL Params and bypass Body Params
		    else if(!bodyParms.contains(s))
		        OAuthHeader += s + '=' + '"' + headerParameters.get(s) + '", ';
	    }
	    
        return OAuthHeader;
            
	}
	
	/*
		Random GUID Generator. To generate the noonce parm in the Twitter Header. Algorithm uses RFC standard for the random GUID
	*/
	
	public static String generateGUID(){
		
		String returnValue = '';
        Integer nextByte = 0;
        for(Integer i = 0; i < 16; i++){
            if(i==4 || i==6 || i==8 || i==10){
                returnValue += '-';
            }
            //generate a "byte"; i.e., number in range [-2^7,2^7-1]
            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if(i==6){
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }
            if(i==8){
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }
            
            returnValue += charAt(kHexChars,nextByte >> 4);
            returnValue += charAt(kHexChars,nextByte & 15);
        }
        return returnValue;
    }

	private static String charAt(String str, Integer index){
		if(str == null){
            return null;
        }
        if(str.length() <= 0){
            return str;    
        }
        if(index < 0 || index >= str.length()){
            return null;    
        }
        return str.substring(index, index+1);
	}
	


}