/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class LookupRequestResultController {
    global String eventDrivenMode {
        get;
    }
    global Boolean isLanguageRTL {
        get;
        set;
    }
    global String nameSpacePrefix {
        get;
    }
    global Boolean showScratchPad {
        get;
    }
    global LookupRequestResultController() {

    }
    @RemoteAction
    global static List<vlocity_cmt.LookupRequest> getLookupRequests(Map<String,Object> additionalData) {
        return null;
    }
    @RemoteAction
    global static List<vlocity_cmt.Action> getLookupVerificationAction(String objectName, String recordId) {
        return null;
    }
    @RemoteAction
    global static List<vlocity_cmt.LookupResult> getNextLookupRequestsWithoutSearch(String strResult, String searchUniqueName) {
        return null;
    }
    @RemoteAction
    global static List<vlocity_cmt.LookupResult> getNextLookupRequests(List<String> contextIds, String searchUniqueName, Map<String,Object> additionalData) {
        return null;
    }
    @RemoteAction
    global static List<vlocity_cmt.Action> getRoleBasedActions(String objectName, String recordId) {
        return null;
    }
    @RemoteAction
    global static List<vlocity_cmt.LookupResult> getSearchResultById(String contextId, String searchUniqueName, Map<String,Object> additionalData) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> getSearchResultByIds(List<String> contextIds, String searchUniqueName, Map<String,Object> additionalData) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> getSearchResult(String strRequest, List<String> contextIds, String parentId) {
        return null;
    }
    @RemoteAction
    global static List<vlocity_cmt.Action> getStepActions(String unqiueRequestName, String stepName, Map<String,Object> searchValueMap, Map<String,Object> resultValueMap, Map<String,Object> additionalData, Map<String,Object> verificationResult, Boolean hasResult) {
        return null;
    }
    @RemoteAction
    global static Map<String,List<vlocity_cmt.Action>> getVerificationPaneActions(String unqiueRequestName, Map<String,Object> searchValueMap, Map<String,Object> resultValueMap, Map<String,Object> additionalData, Map<String,Object> verificationResult) {
        return null;
    }
    @RemoteAction
    global static Object invokeVOIMethod(String className, String methodName, String inputJson, String optionJson) {
        return null;
    }
}
