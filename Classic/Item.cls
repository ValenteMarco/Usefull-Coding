global class Item
{ 
	global OrderItem__c orderItem {get;set;}
	global Catalog_Item__c catalogItem {get;set;}
	global Product__c product {get;set;}
	global Catalog_Item_Discount__c catItemDiscount {get;set;}
	global String urlImage {get;set;}
	global boolean eligible {get;set;}
	global boolean isSelected {get;set;} //GC: complex product configuration
	global String eligibilityComments {get;set;}
	global String toDelete {get;set;}
	global String id{get;set;}
	global String parentId{get;set;}
	global String rootId{get;set;}
	global String itemHeaderId{get;set;} //GC 3.2
	global list<Family__c> families{get;set;}
	global list<Order_Item_Attribute__c> orderItemAttributes{get;set;}
	global List<Product_Wave__c> productWaves {get;set;} // 23-08 (GP): all Product Wave 
	global Product_Wave__c productWave {get; set;} // 23-08 (GP): active Product Wave 
	global String visible{get;set;} // GC 3.0
	global String urlWave {get;set;}
	global String promotionId{get;set;}//GC 3.2.4 trace the promo id of a promo item
	global Map < String , String> mapOfOiRtypesId;        //GC 3.5 map for resolve the recortypes of an order item
	global boolean configurationFrozen {get;set;} //GC 3.5 read only if the configuration is frozen
	global String freezeComment{get;set;}
	global Map < String , String> mapOfItemExternalAttributes{get;set;} //GC 3.6 map for store all the external attributes not related with the sObject
	global map<String,list<Attribute>> attributesMap{get;set;} //GC 3.9.5
	global decimal oldQty{get;set;} //GC 3.10 used to intercept a quantity change in the item
	global String htmlOneTimeTax {get;set;}		//LV 3.11: html string with the list of one time tax models applied to a catalog item
	global String htmlRecurringTax {get;set;}	//LV 3.11: html string with the list of recurring tax models applied to a catalog item
	//JS 4.0 list of Unit of Measure
	global List<SelectOption> admittedUnitOfMeasure;
	global map<String,String> admittedUnitOfMeasureMap{get;set;}//GC 4.1
	
	global String orderItemMagnitude {get;set;}
	global String htmlOneTimeThresholds {get;set;}		//LV 4.0.1: html string with the list of one time thresholds applied
	global String htmlRecurringThresholds {get;set;}	//LV 4.0.1: html string with the list of recurring thresholds applied

	global Item(){
		//GC
		id					=	RandomNumberGenerator.generateRandomNumber();
		isSelected			=	false;
		families			=	new list<Family__c>();
		orderItemAttributes	=	new list<Order_Item_Attribute__c>();
		
		catalogItem			=	new Catalog_Item__c();
		urlImage			=	'';
		product				=	new Product__c();
		orderItem			=	new OrderItem__c();
		catItemDiscount 	= 	new Catalog_Item_Discount__c();
		eligible			=	false;
		eligibilityComments = 	'';
		productWaves 		= 	new List<Product_Wave__c>(); //23-08 (GP)
  		productWave 		= 	new Product_Wave__c(); // 23-08 (GP)
  		visible				=	'true';
  		mapOfOiRtypesId		=	new Map < String , String>();
  		configurationFrozen	=	false;
  		freezeComment		=	'';
  		product				=	new Product__c();
  		
  		attributesMap		=	new map<String,list<Attribute>>();
  		
  		mapOfItemExternalAttributes =	new Map < String , String>();
  		mapOfItemExternalAttributes.put('EligibleForItemMaxQty','false');
  		admittedUnitOfMeasure = new List<SelectOption>();
  		orderItemMagnitude	= 	'';
  		//orderItem.Magnitude__c 	= orderItemMagnitude;

	}
	
	global Item(Catalog_Item__c catItem, Product__c prod,Catalog_Item_Discount__c catItemDisc, OrderItem__c ordItem, String url){
		//GC
		id			=	RandomNumberGenerator.generateRandomNumber();
		isSelected	=	false;
		families	=	new list<Family__c>();
		orderItemAttributes	=	new list<Order_Item_Attribute__c>();
		
		this.catalogItem=catItem.clone( true );
		this.urlImage=url;
		if ( catItemDisc != null ){
			if ( catItemDisc.Id != null )
				this.catItemDiscount=catItemDisc.clone( true );
			else
				this.catItemDiscount=catItemDisc.clone( false );
		}else{
			catItemDiscount = null;
		}
		if ( prod != null ){
			if ( prod.Id != null )
				this.product=prod.clone( true );
			else
				this.product=prod.clone( false );
		}else{
			product	=	new Product__c();
		}
		if( ordItem != null ){
			if ( ordItem.Id != null )
				this.orderItem=ordItem.clone( true );
			else
				this.orderItem=ordItem.clone( false );
		}else{
			this.orderItem = null;
		}
		eligible=false;
		eligibilityComments = '';
		   //23-08 (GP)
	      productWaves = new List<Product_Wave__c>(); 
	      productWave = new Product_Wave__c (); 
	    
	    visible				=	'true';
	    mapOfOiRtypesId		=	new Map < String , String>();
	    configurationFrozen	=	false;
	    freezeComment		=	'';
	    mapOfItemExternalAttributes =	new Map < String , String>();
	    mapOfItemExternalAttributes.put('EligibleForItemMaxQty','false');  
	    
	    attributesMap		=	new map<String,list<Attribute>>(); 
	    orderItemMagnitude	=	''; 
	}
	
	//GC 3.0 updated the method definition
	global Item cloneItem()
	{			
		Item it 				= 	new Item();			
		it.catalogItem 			=	this.catalogItem;
		it.product 				=	this.product;
		it.catItemDiscount 		=	this.catItemDiscount;
		it.urlImage 			=	this.urlImage;
		it.eligible 			=	this.eligible;	
		it.isSelected 			=	this.isSelected;
		it.eligibilityComments 	=	this.eligibilityComments;
		it.toDelete 			=	this.toDelete;
		it.rootId				=	this.rootId;
		it.families				=	this.families;
		it.productWaves 		= 	this.productWaves;
    	it.productWave			=	this.productWave;
    	it.visible				=	this.visible;
    	it.itemHeaderId			=	this.itemHeaderId; //GC 3.2
    	it.promotionId			=	this.promotionId; //GC 3.2.4
		it.configurationFrozen	=	this.configurationFrozen; //GC 3.5
		it.freezeComment		=	this.freezeComment;
		it.orderItem			=	this.orderItem.clone(false); 
		it.mapOfItemExternalAttributes= this.mapOfItemExternalAttributes;
		it.parentId 			=	this.parentId;
		for(Order_Item_Attribute__c oia:this.orderItemAttributes)
			it.orderItemAttributes.add(oia.clone(false));
		
		it.mapOfOiRtypesId		=	this.mapOfOiRtypesId;
		it.mapOfItemExternalAttributes = this.mapOfItemExternalAttributes;
		
		//GC 3.9.5
		it.attributesMap		=	new map<String,list<Attribute>>();
		for(String familyId:this.attributesMap.keySet())
		{
			list<Attribute> attributeToAdd	=	new list<Attribute>();
			for(Attribute attrToClone:this.attributesMap.get(familyId))
				attributeToAdd.add(attrToClone.cloneAttribute());
				
			it.attributesMap.put(familyId,attributeToAdd);
		}
		//JS 4.0 
		it.orderItemMagnitude	= 	this.orderItemMagnitude;
		if(this.orderItem.Magnitude__c != '' )
			it.orderItem.Magnitude__c = this.orderItem.Magnitude__c;
		it.admittedUnitOfMeasure = this.admittedUnitOfMeasure;
		return it;			
	}
	
	//IA 22-01-2014
	global void catalogItemToOrderItem() {
		
		orderItem.BaseOneTimeFee__c 	= 	catalogItem.Base_OneTime_Fee__c; 
		orderItem.BaseRecurringCharge__c= 	catalogItem.BaseRecurringCharge__c;
		orderItem.OneTimeFeeOv__c		=	catalogItem.Base_OneTime_Fee__c; 
		orderItem.RecurringChargeOv__c 	=	catalogItem.BaseRecurringCharge__c;
		orderItem.CatalogItem__c	 	=	this.catalogItem.id;
		
		orderItem.Commitment__c 		= 	catalogItem.Commitment__c;
		orderItem.Commitment_Period__c 	= 	catalogItem.Commitment_Period__c;
		orderItem.Commitment_UOM__c 	= 	catalogItem.Commitment_UOM__c;
		orderItem.EndDate__c 			= 	catalogItem.End_Date__c;
		orderItem.Generate_Asset_Item__c= 	catalogItem.Generate_Asset_Item__c;
		orderItem.Qty__c 				=	1;
		orderItem.Penalty__c 			= 	catalogItem.Penalty__c;
		orderItem.Penalty_Fee__c 		= 	catalogItem.Penalty_Fee__c;
		orderItem.Penalty_Type__c 		= 	catalogItem.Penalty_Type__c;	//MP3.11 20160325
		orderItem.OneTimeFeeCode__c 	= 	catalogItem.OneTime_Fee_Code__c;
		orderItem.ProdId__c 			= 	catalogItem.ProductId__c;
		orderItem.Status__c 			=	'Pending';
		orderItem.PromotionId__c 		=	this.promotionId;
		
		orderItem.RecurringChargeFrequency__c 	=	catalogItem.Recurring_Charge_Frequency__c;
		orderItem.RecurringChargeCode__c 		=	catalogItem.RecurringChargeCode__c;
		
        //GC 3.5 set cost attributes
        orderItem.Recurring_Cost__c			=	catalogItem.Recurring_Cost__c;
        orderItem.One_Time_Cost__c			=	catalogItem.One_Time_Cost__c;
        orderItem.Recurring_Cost_Frequency__c=	catalogItem.Recurring_Cost_Frequency__c;
        
        //GC 3.5 set the recordtype                      
        String rTypeId	=	mapOfOiRtypesId.get(catalogItem.RecordType.name);
        if(rTypeId != null)
        	orderItem.RecordTypeId	=	rTypeId;
        //JS 4.0 
        /*if(orderItemMagnitude != null)
        	orderItem.Magnitude__c 			=	orderItemMagnitude;*/
	}
	
	// MR methods for translations
	
	// return the item name. If exist a translation, returns it
	// otherwise return the standard name
	global String getProductName()
	{
    	if(product!=null && product.Translations__r!=null && product.Translations__r.size()>0 && product.Translations__r[0].Text__c!=null)
    		return product.Translations__r[0].Text__c;
    	else
    		return catalogItem.ProductId__r.Name;
	}
	
	// return the item description. If exist a translation, returns it
	// otherwise return the standard description
	global String getProductDesc()
	{
    	if(product!=null && product.Translations__r!=null && product.Translations__r.size()>0 && product.Translations__r[0].Description__c!=null)
    		return product.Translations__r[0].Description__c;
    	else
    		return catalogItem.ProductId__r.Description__c;
	}
	
	
	// GC Used to translate a complex category name, a catalog item with type = 'Category'
	global String getCategoryName()
	{
    	if(catalogItem!=null && catalogItem.Translations__r!=null && catalogItem.Translations__r.size()>0 && catalogItem.Translations__r[0].Text__c!=null)
    		return catalogItem.Translations__r[0].Text__c;
    	else
    		return catalogItem.Product_Category_Name__c;
	}

	//JS 4.0 List of SelectOption for Unit of Measure Picklist
	global void initAdmittedUnitOfMeasure(Map<String,Unit_Of_Measure__c> mapOfUnit)
	{
		if(catalogItem != null && catalogItem.Admitted_Magnitude__c != null && catalogItem.Admitted_Magnitude__c != '')
		{
			List<String> units = catalogItem.Admitted_Magnitude__c.split(';');
			for(String s : units)
			{
				admittedUnitOfMeasure.add(new SelectOption(s, mapOfUnit.get(s).Name));
			}
		}
	}
	//JS 4.0 
	global List<SelectOption> getAdmittedUnitOfMeasure()
	{
		return admittedUnitOfMeasure;
	}
}