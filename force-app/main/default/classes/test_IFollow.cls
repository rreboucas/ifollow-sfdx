@isTest
private class test_IFollow {
    
    @isTest static void testConstructor() {
 
        Test.startTest();
        Account a = TestFactory.insertAccount();        
        IFollowObject fObj = new IFollowObject(a.id);
        System.assertNotEquals(null, fObj);
        Test.stopTest();
    }
    
        @isTest static void testGetObjects() {

        ID contextUserID = UserInfo.getUserId();
        Test.startTest();
        Account a = TestFactory.insertAccount();        
        EntitySubscription e = TestFactory.insertEntitySubscription(a.id, contextUserID);
        List<String> lstObjectsFollowed = IFollowObject.getObjects();
        System.assertNotEquals(null, lstObjectsFollowed);    
        Test.stopTest();
        
    }
    
    @isTest static void testGetFollowedRecordsByObjLimit() {

        ID contextUserID = UserInfo.getUserId();
        Test.startTest();
        Account a = TestFactory.insertAccount();        
        EntitySubscription e = TestFactory.insertEntitySubscription(a.id, contextUserID);
        List<IFollowObject> lstObjRecsFollowed = IFollowObject.getFollowedRecordsByObjLimit('Most Recent','1');
        System.assertNotEquals(null, lstObjRecsFollowed);
        List<IFollowObject> lstObjRecsFollowedInt = IFollowObject.getFollowedRecordsByObjLimitInt('Most Recent',1);
        System.assertNotEquals(null, lstObjRecsFollowedInt); 
        Test.stopTest();
        
    }

}