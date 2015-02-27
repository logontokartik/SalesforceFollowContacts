/***************************************************************************
 Name 		: TwitterFollowsExt 
 Created By : Kartik Viswanadha (kartik.viswanadha@gmail.com)
 Created Date : 12/24/2012
 VisualForce Page :TwitterFollows
 Description  : Extension Class for the TwitterFollows Page called when Follow on Twitter is clicked on Contacts List View.
******************************************************************************/
public with sharing class TwitterFollowsExt {
	
	private Apexpages.StandardSetController setCon;
	
	private List<Contact> selectedContacts;
	
	public List<Contact> eFollowers {get;set;}
	public List<Contact> nFollowers {get;set;}
	public List<Contact> nContacts  {get;set;}
	
	// Constructor
		
	public TwitterFollowsExt(Apexpages.StandardSetController con){
		
		this.setCon = con;
		
		selectedContacts = new List<Contact>();
		eFollowers = new List<Contact>();
		nFollowers = new List<Contact>();
		nContacts  = new List<Contact>();
		
		selectedContacts = [Select Id, Name, Persona__c, Following__c from Contact Where ID in :setCon.getSelected()];
		
		// Return if no contacts selected.
		
		if(selectedContacts.size() == 0){
			Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Select at least one contact to follow'));	
			return;	
		}
		
		// Split the contacts into different buckets, Already Following, New Following & Contacts with No Persona.
		
		for(Contact c : selectedContacts){
			if(c.Following__c)
				eFollowers.add(c);
			if(c.Persona__c != null && !c.Following__c)
				nFollowers.add(c);
			if(c.Persona__c == null || c.Persona__c == '')
				nContacts.add(c);		
		}
		
	}
	
	/* 
		Action method called when User clicks Follow on Twitter on Contacts List View
	*/
	public void follow(){
		
		// Allow only 10 users to follow at once.
		if(nFollowers.size() > 10){
			Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Select Less than 10 Contacts'));	
			return;
		}
		
		// Call the TwitterManager.followUser method one at a time by passing the Contact Record.
		for(Contact c : nFollowers){
			TwitterManager.followUser(c);
			c.Following__c = true;
		}
		
		update nFollowers; // Update the contact records.
		
	}
	

}