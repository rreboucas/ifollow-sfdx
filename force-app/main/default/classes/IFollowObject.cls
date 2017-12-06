global with sharing class IFollowObject {
  
    @AuraEnabled
    global String recordID { get;set; }
    @AuraEnabled
    global String recordName { get;set; }
    @AuraEnabled
    global String objectType { get;set; }
    @AuraEnabled
    global String iconUrl { get;set; }
    @AuraEnabled
    global String s1Url { get;set; }
    
    //Constructor
    global IFollowObject(String recID) {
        this.recordID = recID;
       
    }
    
    @AuraEnabled
    global static List<String> getObjects()
    {
        List<String> lstObjs = new List<String>();
        ID contextUserID = UserInfo.getUserId();
       
        // SOQL Query to retrieve a List of EntitySubscription for the context user
        
        List<EntitySubscription> lstEntSub = [SELECT ParentId FROM EntitySubscription
                                             where SubscriberId =: contextUserID and isDeleted = false
                                             order by createddate desc limit 800];
        
        Set<String> setObjectTypes = new Set<String>();
       
        System.debug('######## getObjects - lstEntSub: ' + lstEntSub);
        // Create List of IfollowObjects 

        for (EntitySubscription e: lstEntSub)
        {
            // Get object Label based on the id of the EntitySubscription record (followed record) and put on a Set
            String strObjLabel = e.ParentId.getSObjectType().getDescribe().getLabel();
            System.debug('########  getObjects - strObjLabel: ' + strObjLabel);
            if (!strObjLabel.equalsIgnoreCase('Dashboard Component'))
            {
                if (strObjLabel.equalsIgnoreCase('Content Document'))
                    setObjectTypes.add('File');
                else
                    setObjectTypes.add(strObjLabel);  
            }
        }
        lstObjs.addAll(setObjectTypes);
        lstObjs.sort();
        
        return lstObjs;
        
    }
    
    //Invoked from LC on S1 (Client Side) every time the user refreshed the Page in S1

    @AuraEnabled
    global static List<IFollowObject> getFollowedRecordsByObjLimitInt(String reqObjName, Integer rowsLimit)
    {
        System.debug('######## rowsLimit: ' + rowsLimit);
        
        if (reqObjName.equalsIgnoreCase('File'))
            reqObjName = 'Content Document';
            
        List<IFollowObject> lstPosts = new List<IFollowObject>();
        ID contextUserID = UserInfo.getUserId();
        Integer rLimit = integer.valueOf(rowsLimit);
        System.debug('######## rLimit: ' + rLimit);
        
        // SOQL Query to retrieve a List of EntitySubscription for the context user
        
        List<EntitySubscription> lstEntSub = [SELECT CreatedById,CreatedDate,Id,IsDeleted,
                                              ParentId,SubscriberId, parent.name FROM EntitySubscription
                                             where SubscriberId =: contextUserID and isDeleted = false
                                             order by createddate desc limit 600];
        
        Set<String> setObjectTypes = new Set<String>();
        System.debug('######## lstEntSub.size: ' + lstEntSub.size());       
        System.debug('######## lstEntSub: ' + lstEntSub);
        // Create List of IfollowObjects 
        
        Integer counter = 0;
        
        // For Each EntitySubscription record (followed by context user) create a new IFollowObject 
        // and add it to the return list
        
        for (EntitySubscription e: lstEntSub)
        {
            
            IFollowObject i = new IFollowObject(e.ParentId);
            
            
            
            String strObjType = e.ParentId.getSObjectType().getDescribe().getLabel() ;
            integer tpLength = strObjType.length();
            if (strObjType.lastIndexOf('s') == (tpLength - 1))
                {
                    //substring to remove letter s
                    strObjType = strObjType.substring(0, tpLength - 1);
                }
            i.objectType = strObjType;
            String strObjName = e.ParentId.getSObjectType().getDescribe().getLabel();
            System.debug('######## strObjName: ' + strObjName);
            
            integer nmLength = strObjName.length();
            if (strObjName.lastIndexOf('s') == (nmLength - 1))
                {
                    //substring to remove letter s
                    strObjName = strObjName.substring(0, nmLength - 1);
                }
            System.debug('######## strObjName: ' + strObjName);
            System.debug('######## reqObjName: ' + reqObjName);

            // Assign IFollow record name
            i.recordName = e.parent.name;
            
            
            if (!strObjName.equalsIgnoreCase('DashboardComponent'))
            {
                if (strObjName.equalsIgnoreCase(reqObjName) || reqObjName.equalsIgnoreCase('Most Recent'))
                {
                    if (counter < rLimit)
                    {
                        setObjectTypes.add(strObjName);
                        lstPosts.add(i);
                    }
                    else
                        break;
                    counter ++;
                }
            }
        }
        
        Map<String, String> mapIconUrls = new Map<String, String>();
        Map<String, String> mapIconNames = new Map<String, String>();
        // describe tabs to get icons url
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
        
        System.debug('######### setObjectTypes: ' + setObjectTypes);
        for(DescribeTabSetResult tsr : tabSetDesc) 
        {
            List<Schema.DescribeTabResult> tabDesc = tsr.getTabs();
            for(Schema.DescribeTabResult tr : tabDesc) 
            {
                string tabName = tr.getLabel();
                integer tabLength = tabName.length();
                if (tabName.lastIndexOf('s') == (tabLength - 1))
                {
                    //substring to remove letter s
                    tabName = tabName.substring(0, tabLength - 1);
                }
                System.debug('######### tabName: ' + tabName);
                string objName = tr.getSobjectName();
                System.debug('######### objName: ' + objName);
                Boolean tabNameMatches = setObjectTypes.contains(tabName);
                Boolean objNameMatches = setObjectTypes.contains(objName);
                
                if (tabNameMatches)
                {
                    System.debug('### match found: tabName: ' + tabName);
                    List<Schema.DescribeIconResult> lstTabIcons = tr.getIcons();
                    if (lstTabIcons != null)
                    {
                        for (Schema.DescribeIconResult icon: lstTabIcons)
                        {
                            if (icon.getTheme() == 'theme4'&& icon.getContentType() == 'image/svg+xml')
                            {
                                String iconURL = icon.getUrl();
                                System.debug('iconURL: ' + iconURL );
                                mapIconUrls.put(tabName, iconURL);
                                // substring to get the icon name
                                String iconName = iconURL.substringAfterLast('/');
                                String iconNmShort = iconName.replace('.svg', '');
                                System.debug('iconNmShort: ' + iconNmShort );
                                mapIconNames.put(tabName, iconNmShort);
                                break;
                            }
                        }
                    }
                }
                if (objNameMatches)
                {
                    System.debug('### match found: objName: ' + objName);
                    List<Schema.DescribeIconResult> lstObjIcons = tr.getIcons();
                    if (lstObjIcons != null)
                    {
                        for (Schema.DescribeIconResult icon: lstObjIcons)
                        {
                            if (icon.getTheme() == 'theme4'&& icon.getContentType() == 'image/svg+xml')
                            {
                                String iconURL = icon.getUrl();
                                System.debug('iconURL: ' + iconURL );
                                mapIconUrls.put(objName, iconURL);
                                // substring to get the icon name
                                String iconName = iconURL.substringAfterLast('/');
                                String iconNmShort = iconName.replace('.svg', '');
                                System.debug('iconNmShort: ' + iconNmShort );
                                mapIconNames.put(objName, iconNmShort);
                                break;
                            }
                        }
                    }
                }
            }
            System.debug('######## mapIconUrls: ' + mapIconUrls);
            System.debug('######## mapIconNames: ' + mapIconNames);
        }
        
        for (IFollowObject r: lstPosts)
        {
           r.iconUrl = mapIconUrls.get(r.objectType);
           r.s1Url = mapIconNames.get(r.objectType);
           if (r.objectType.equalsIgnoreCase('User'))
           {
               // try to get profile picture
               ConnectApi.Photo userPhoto = ConnectApi.ChatterUsers.getPhoto(null, r.recordID);
               if (userPhoto != null)
                   r.iconUrl = userPhoto.smallPhotoUrl;
           }
           /*if (r.objectType.equalsIgnoreCase('Task') || r.objectType.equalsIgnoreCase('Asset'))
           {
               r.iconUrl = '/img/icon/t4/doctype/unknown_60.png';
           }*/
           if (r.objectType.equalsIgnoreCase('Content Document'))
           {
               r.iconUrl = '/img/icon/t4v32/standard/file.svg';
               r.s1Url = 'file';
           }
            //
           if (r.objectType.equalsIgnoreCase('Topic'))
           {
               r.iconUrl = '/img/icon/t4v32/standard/topic.svg';
               r.s1Url = 'topic';
           }
           if (String.isEmpty(r.iconUrl))
           {
               r.iconUrl = '/img/icon/t4/doctype/unknown_60.png';
           }
           System.debug('######## r.iconUrl: ' + r.iconUrl);
            
            
        }
        
        System.debug('######## lstPosts: ' + lstPosts);
        
        return lstPosts;
    }
    
    //Invoked from LC on S1 (Client Side) every time the user refreshed the Page in S1

    @AuraEnabled
    global static List<IFollowObject> getFollowedRecordsByObjLimit(String reqObjName, string rowsLimit)
    {
        System.debug('######## rowsLimit: ' + rowsLimit);
        
        if (reqObjName.equalsIgnoreCase('File'))
            reqObjName = 'Content Document';
            
        List<IFollowObject> lstPosts = new List<IFollowObject>();
        ID contextUserID = UserInfo.getUserId();
        Integer rLimit = integer.valueOf(rowsLimit);
        System.debug('######## rLimit: ' + rLimit);
        // Get List of EntitySubscription for current user
        
        List<EntitySubscription> lstEntSub = [SELECT CreatedById,CreatedDate,Id,IsDeleted,
                                              ParentId,SubscriberId, parent.name FROM EntitySubscription
                                             where SubscriberId =: contextUserID and isDeleted = false
                                             order by createddate desc limit 600];
        
        Set<String> setObjectTypes = new Set<String>();
        System.debug('######## lstEntSub.size: ' + lstEntSub.size());       
        System.debug('######## lstEntSub: ' + lstEntSub);
        // Create List of IfollowObjects 
        
        Integer counter = 0;
        
        for (EntitySubscription e: lstEntSub)
        {
            
            IFollowObject i = new IFollowObject(e.ParentId);
            String strObjType = e.ParentId.getSObjectType().getDescribe().getLabel() ;
            integer tpLength = strObjType.length();
            if (strObjType.lastIndexOf('s') == (tpLength - 1))
                {
                    //substring to remove letter s
                    strObjType = strObjType.substring(0, tpLength - 1);
                }
            i.objectType = strObjType;
            String strObjName = e.ParentId.getSObjectType().getDescribe().getLabel();
            System.debug('######## strObjName: ' + strObjName);
            
            integer nmLength = strObjName.length();
            if (strObjName.lastIndexOf('s') == (nmLength - 1))
                {
                    //substring to remove letter s
                    strObjName = strObjName.substring(0, nmLength - 1);
                }
            System.debug('######## strObjName: ' + strObjName);
            System.debug('######## reqObjName: ' + reqObjName);
            i.recordName = e.parent.name;
            
            
            if (!strObjName.equalsIgnoreCase('DashboardComponent'))
            {
                if (strObjName.equalsIgnoreCase(reqObjName) || reqObjName.equalsIgnoreCase('Most Recent'))
                {
                    if (counter < rLimit)
                    {
                        setObjectTypes.add(strObjName);
                        lstPosts.add(i);
                    }
                    else
                        break;
                    counter ++;
                }
            }
        }
        
        Map<String, String> mapIconUrls = new Map<String, String>();
        // describe tabs to get icons url
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
        
        System.debug('######### setObjectTypes: ' + setObjectTypes);
        for(DescribeTabSetResult tsr : tabSetDesc) 
        {
            List<Schema.DescribeTabResult> tabDesc = tsr.getTabs();
            for(Schema.DescribeTabResult tr : tabDesc) 
            {
                string tabName = tr.getLabel();
                integer tabLength = tabName.length();
                if (tabName.lastIndexOf('s') == (tabLength - 1))
                {
                    //substring to remove letter s
                    tabName = tabName.substring(0, tabLength - 1);
                }
                System.debug('######### tabName: ' + tabName);
                string objName = tr.getSobjectName();
                System.debug('######### objName: ' + objName);
                Boolean tabNameMatches = setObjectTypes.contains(tabName);
                Boolean objNameMatches = setObjectTypes.contains(objName);
                
                if (tabNameMatches)
                {
                    System.debug('### match found: tabName: ' + tabName);
                    List<Schema.DescribeIconResult> lstTabIcons = tr.getIcons();
                    if (lstTabIcons != null)
                    {
                        for (Schema.DescribeIconResult icon: lstTabIcons)
                        {
                            if (icon.getTheme() == 'theme4'&& icon.getContentType() == 'image/svg+xml')
                            {
                                String iconURL = icon.getUrl();
                                System.debug('iconURL: ' + iconURL );
                                mapIconUrls.put(tabName, iconURL);
                                break;
                            }
                        }
                    }
                }
                if (objNameMatches)
                {
                    System.debug('### match found: objName: ' + objName);
                    List<Schema.DescribeIconResult> lstObjIcons = tr.getIcons();
                    if (lstObjIcons != null)
                    {
                        for (Schema.DescribeIconResult icon: lstObjIcons)
                        {
                            if (icon.getTheme() == 'theme4'&& icon.getContentType() == 'image/svg+xml')
                            {
                                String iconURL = icon.getUrl();
                                System.debug('iconURL: ' + iconURL );
                                mapIconUrls.put(objName, iconURL);
                                break;
                            }
                        }
                    }
                }
            }
            System.debug('######## mapIconUrls: ' + mapIconUrls);
        }
        
        for (IFollowObject r: lstPosts)
        {
           r.iconUrl = mapIconUrls.get(r.objectType);
           if (r.objectType.equalsIgnoreCase('User'))
           {
               // try to get profile picture
               ConnectApi.Photo userPhoto = ConnectApi.ChatterUsers.getPhoto(null, r.recordID);
               if (userPhoto != null)
                   r.iconUrl = userPhoto.smallPhotoUrl;
           }
           if (r.objectType.equalsIgnoreCase('Task') || r.objectType.equalsIgnoreCase('Asset'))
           {
               r.iconUrl = '/img/icon/t4/doctype/unknown_60.png';
           }
           if (r.objectType.equalsIgnoreCase('Content Document'))
           {
               r.iconUrl = '/img/icon/t4v32/standard/file_120.png';
           }
            //
           if (r.objectType.equalsIgnoreCase('Event'))
           {
               r.iconUrl = '/img/icon/t4v32/standard/event_120.png';
           }
           if (String.isEmpty(r.iconUrl))
           {
               r.iconUrl = '/img/icon/t4/doctype/unknown_60.png';
           }
           System.debug('######## r.iconUrl: ' + r.iconUrl);
        }
        
        System.debug('######## lstPosts: ' + lstPosts);
        
        return lstPosts;
    }   
}