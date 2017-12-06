@isTest
public class TestFactory {
    // define default constants that can be accessible to assert against.

    public static final String DEFAULT_ACCOUNT_NAME = 'ACME Inc.';


    /* The “create” methods are used to instantiate the sobjects without inserting them. 
       This is tremendously helpful when you need to create a particular record and then tweak it before 
       it’s inserted from the calling code. */  

    
    public static Account createAccount(){

          return createAccount(DEFAULT_ACCOUNT_NAME);

    }

 

    /* The create methods are commonly overloaded to allow different properties to be set. */

    public static Account createAccount(String name){

           return new Account(

               Name = name

           );

    }
    
    public static EntitySubscription createEntitySubs(id prentID, id subscrID){

           return new EntitySubscription(

               ParentId = prentID,
               SubscriberId = subscrID

           );

    }

 

    /* The “Insert” methods are used to create the sobjects and then insert them. They delegate 
       the creation to the create methods and then insert the records. Like the create methods,
       the insert methods are overloaded to allow different properties to be set as necessary.
       Another best practice is to bulk insert or bulk create data, but to keep the sample short, that’s omitted. */

    public static Account insertAccount(){

          Account accountToInsert = createAccount();
          insert accountToInsert;
          return accountToInsert;

    }
    
    public static EntitySubscription insertEntitySubscription(id parentID, id subscriberID){

          EntitySubscription entToInsert = createEntitySubs(parentID, subscriberID);
          insert entToInsert;
          return entToInsert;

    }

}