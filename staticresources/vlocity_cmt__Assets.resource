(function(){var fileNsPrefix=function(){"use strict";var scripts=document.getElementsByTagName("script");var lastScript=scripts[scripts.length-1];var scriptName=lastScript.src;var parts=scriptName.split("/");var thisScript=parts[parts.length-1];if(thisScript===""){thisScript=parts[parts.length-2]}var lowerCasePrefix=thisScript.indexOf("__")==-1?"":thisScript.substring(0,thisScript.indexOf("__")+2);lowerCasePrefix=lowerCasePrefix===""&&localStorage.getItem("nsPrefix")?localStorage.getItem("nsPrefix"):lowerCasePrefix;if(lowerCasePrefix!==""){lowerCasePrefix=/__$/.test(lowerCasePrefix)?lowerCasePrefix:lowerCasePrefix+"__"}if(lowerCasePrefix.length===0){return function(){lowerCasePrefix=window.nsPrefix?window.nsPrefix:lowerCasePrefix;if(lowerCasePrefix!==""){lowerCasePrefix=/__$/.test(lowerCasePrefix)?lowerCasePrefix:lowerCasePrefix+"__"}return lowerCasePrefix}}else{var resolvedNs=null;return function(){if(resolvedNs){return resolvedNs}try{var tofind=lowerCasePrefix.replace("__","");var name;var scanObjectForNs=function(object,alreadySeen){if(object&&object!==window&&alreadySeen.indexOf(object)==-1){alreadySeen.push(object);Object.keys(object).forEach(function(key){if(key==="ns"){if(typeof object[key]==="string"&&object[key].toLowerCase()===tofind){name=object[key]+"__";return false}}if(Object.prototype.toString.call(object[key])==="[object Array]"){object[key].forEach(function(value){var result=scanObjectForNs(value,alreadySeen);if(result){name=result;return false}})}else if(typeof object[key]=="object"){var result=scanObjectForNs(object[key],alreadySeen);if(result){name=result;return false}}if(name){return false}});if(name){return name}}};if(typeof Visualforce!=="undefined"){scanObjectForNs(Visualforce.remoting.Manager.providers,[])}else{return lowerCasePrefix}if(name){return resolvedNs=name}else{return resolvedNs=lowerCasePrefix}}catch(e){return lowerCasePrefix}}}}();var fileNsPrefixDot=function(){var prefix=fileNsPrefix();if(prefix.length>1){return prefix.replace("__",".")}else{return prefix}};
(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
/*
 * Assets app using Card Framework and CPQ Hybrid
 */
angular.module('assets', ['vlocity', 'CardFramework' , 'sldsangular', 'ngSanitize', 'forceng', 'tmh.dynamicLocale', 'cfp.hotkeys', 'hybridCPQ'])

.run(['$rootScope', 'dataService', 'configService', '$window','userProfileService','tmhDynamicLocale',
         function($rootScope, dataService, configService, $window, userProfileService, tmhDynamicLocale) {
        'use strict';

        $rootScope.nsPrefix = fileNsPrefix();

        $rootScope.vlocityAssets = $rootScope.vlocityAssets || {};

        $rootScope.vlocityAssets.customSettings = $rootScope.vlocityAssets.customSettings || {};

}]);

require('./modules/hybridCPQ/controller/assets/AssetsController.js');
require('./modules/hybridCPQ/controller/assets/AssetsInfoPanelController.js');
require('./modules/hybridCPQ/controller/assets/AssetsMainController.js');
require('./modules/hybridCPQ/controller/assets/AssetsProductItemController.js');
require('./modules/hybridCPQ/factory/assets/AssetsService.js');

},{"./modules/hybridCPQ/controller/assets/AssetsController.js":2,"./modules/hybridCPQ/controller/assets/AssetsInfoPanelController.js":3,"./modules/hybridCPQ/controller/assets/AssetsMainController.js":4,"./modules/hybridCPQ/controller/assets/AssetsProductItemController.js":5,"./modules/hybridCPQ/factory/assets/AssetsService.js":6}],2:[function(require,module,exports){
angular.module('assets')
.controller('AssetsController', ['$scope', '$rootScope', '$log', 'pageService', 'dataService', 'CPQResponsiveHelper',
    function($scope, $rootScope, $log, pageService, dataService, CPQResponsiveHelper) {

    $scope.params = pageService.params;
    $scope.isMobileTablet = CPQResponsiveHelper.mobileTabletDevice;

    $rootScope.cartId = $scope.params.id;

    //Config panel is hidden on page load
    $scope.isConfigAttrsPanelEnabled = false;

    $scope.init = function() {
        $log.debug('Initializing the AssetsController');
        if (typeof Visualforce !== 'undefined') {
            $rootScope.forcetkClient = new forcetk.Client();
            $rootScope.forcetkClient.setSessionToken(sessionId);
        }
        $rootScope.vlocityAssets.enableChangeToCartButton = false;
        $rootScope.vlocityAssets.enableMoveButton = false;
    };

    // Event listener to enable the info panel
    $scope.$on('vlocity.assets.infopanel.enabled', function(event, isInfoPanelEnabled, itemObject, refreshMode) {
        // If the info panel is open and refreshMode is true, don't close the info panel. It avoids the FOUC.
        if (!(refreshMode && $scope.isConfigAttrsPanelEnabled)) {
            $scope.isConfigAttrsPanelEnabled = isInfoPanelEnabled;
        }
    });

    dataService.getCustomSettings($rootScope.nsPrefix + 'CpqConfigurationSetup__c').then(
        function(data) {
            $log.debug('retrieved custom setting ',data);
            $rootScope.vlocityAssets = $rootScope.vlocityAssets || {};
            $rootScope.vlocityAssets.customSettings = $rootScope.vlocityAssets.customSettings || {};
            angular.forEach(data, function(customSetting) {
                $rootScope.vlocityAssets.customSettings[customSetting.Name] = customSetting[$rootScope.nsPrefix + 'SetupValue__c'];
            });
            $log.debug($rootScope.vlocityAssets);
        }, function(error) {
            $log.debug('error retrieving custom setting ', error);
        }
    );

}]);

},{}],3:[function(require,module,exports){
angular.module('assets')
.controller('AssetsInfoPanelController', ['$scope', '$rootScope', 'pageService', 'AssetsService',
    function($scope, $rootScope, pageService, AssetsService) {

    $scope.attributesObj = null;
    $scope.configItemObject = null; // Under $scope because Telus PS team needs to access it from template
    var itemObject;

    /*********** CPQ CART ITEM CONFIG EVENTS ************/
    $scope.$on('vlocity.assets.infopanel.enabled', function(event, isInfoPanelEnabled, data) {
        var  itemKeys, lookupItem, infoItem, lookupDisplayValueItemKey, cartId, lineItemId;

        if (isInfoPanelEnabled && data) {
            itemObject = data;
            $scope.configItemObject = angular.copy(itemObject);
            $scope.attributesObj = itemObject.attributeCategories && itemObject.attributeCategories.records || [];

            itemKeys = AssetsService.getItemFieldsList(itemObject);
            $scope.lookupItemList = [];
            $scope.infoItemList = [];
            cartId = pageService.params.id;
            lineItemId = itemObject.Id.value;
            angular.forEach(itemKeys, function(key) {
                if (!itemObject[key].hidden && itemObject[key].label) {
                    if (itemObject[key].dataType === 'REFERENCE') {
                        lookupItem = angular.copy(itemObject[key]);
                        lookupDisplayValueItemKey = key.slice(0, -1) + 'r';
                        // if lookup field has null value in the __c object, then it would not have the __r object
                        if (itemObject[lookupDisplayValueItemKey]) {
                            lookupItem.displayValue = itemObject[lookupDisplayValueItemKey].Name;
                        } else {
                            lookupItem.displayValue = '';
                            $scope.configItemObject[lookupDisplayValueItemKey] = {'Id': null, 'Name': null};
                        }
                        lookupItem.cartId = cartId;
                        lookupItem.lineItemId = lineItemId;
                        $scope.lookupItemList.push(lookupItem);
                    } else {
                        infoItem = angular.copy(itemObject[key]);
                        $scope.infoItemList.push(infoItem);
                    }
                }
            });
        }
    });
    /*********** END CPQ CART ITEM CONFIG EVENTS ************/

    /**
     * close: Closes attributes infopanel panel for line item
     * @param  {object} itemObject
     */
    $scope.close = function() {
        // Publishes event to enable the info panel
        $rootScope.$broadcast('vlocity.assets.infopanel.enabled', false);
    };

}]);

},{}],4:[function(require,module,exports){
angular.module('assets')
.controller('AssetsMainController', ['$scope', '$rootScope', '$log', '$sldsToast', 'AssetsService', 'CPQService', 'CPQCustomViewsService',
 function($scope, $rootScope, $log, $sldsToast, AssetsService, CPQService, CPQCustomViewsService) {

    $scope.viewOpen = false;
    $scope.tabSelected = 'Assets';
    $scope.appliedPromotionsTypeSelected = 'All';
    $scope.appliedPromotionsCommitmentDateSelected = {};
    $scope.effectiveAssetsDateSelected = {'value': new Date()};

    /*********** EVENTS ************/
    var unbindEvents = [];

    unbindEvents[unbindEvents.length] =
        $scope.$on('vlocity.assets.reload', function(event, data) {
            var params = {};
            var localTimeDate = new Date(data.getTime() - (data.getTimezoneOffset() * 60000));
            params.effectiveAssetsDateFilter = localTimeDate;
            params.lastRecordId = '';
            // This would handle all layouts with datasource, which is perfect in the case of the Assets component,
            // because it has 3 layouts with datasources embedded.
            if ($scope.uniqueName && $scope.data.dataSource && $scope.data.dataSource.type) {
                $scope.updateDatasource(params); 
            }
        });
    /********* END EVENTS **********/

    $scope.$on('$destroy', function() {
        $log.debug('Assets Main Controller - Removes all listeners');
        //Removes all listeners
        unbindEvents.forEach(function (fn) {
            fn();
        });
    });

    /* Custom Labels */
    $scope.customLabels = {};
    var labelsArray = ['CPQPromotions', 'CPQAssets', 'CPQCartIsEmpty', 'CPQNoResultsFound', 'CPQLoadMore', 'ASSETChangeToQuote', 'ASSETChangeToOrder', 'ASSETMove', 'AllPromotions','ActivePromotions','ExpiredPromotions','CanceledPromotions','ASSETNoAssets'];
    CPQService.setLabels(labelsArray, $scope.customLabels);
    var toastCustomLabels = {};
    var toastLabelsArray =  ['ASSETChangeError','ASSETNoItemSelected','ASSETMoreThanOneItemSelected'];
    // Custom labels for toast messages
    CPQService.setLabels(toastLabelsArray, toastCustomLabels);
    /* End Custom Labels */

    $scope.dropDownLabel = {'value': $scope.customLabels['AllPromotions']};

    $scope.getStateData = function(cards) {
        if (cards && cards[0].states) {
            // Assign CPQCustomViewsService into $rootScope variable
            $rootScope.customViews = new CPQCustomViewsService($scope, cards[0].states, true);
        } else {
            $log.debug('There is no data for CustomView');
        }
    };

    $scope.changeCustomView = function(index) {
        var clearSelectedAssets = function(){
            AssetsService.clearAssetsSelected();
            $rootScope.vlocityAssets.enableChangeToCartButton = false;
            $rootScope.vlocityAssets.enableMoveButton = false;
        }
        // Contains the picklist switcher for the custom views
        $rootScope.customViews.currentCustomView = index;
        $rootScope.customViews.showExpandedActions();

        if (index !== 0) {
            $rootScope.$broadcast('cpq-non-cart-tab-selected', $scope.attrs.showProductList);
            clearSelectedAssets();
        } else {
            $rootScope.$broadcast('cpq-cart-tab-selected');
        }
    };

    $scope.nextPageAssets = function() {
        if ($scope.$parent.session.nextAssets) {
            nextPage($scope.$parent.session.nextAssets);
        }
    };

    $scope.nextPageProducts = function() { // testing
        if ($scope.$parent.session.nextProducts) {
            nextPage($scope.$parent.session.nextProducts);
        }
    };

    var nextPage = function(nextItems) {
        if (nextItems) {
            $log.debug('nextItems', nextItems);

            var params = {};
            var nextItemsObj = JSON.parse(nextItems); 
            params.lastRecordId = nextItemsObj.remote.params.lastRecordId;

            if (params.lastRecordId) {
                $scope.$parent.updateDatasource(params, true).then(
                    function(data) {
                        //this means there was an error with the last operation
                        if (!data[data.length - 1]) {
                            $scope.nextPage(params.lastRecordId); //try again with last record id
                        }
                    }, function(error) {
                        $log.debug('pagination next page error ',error);
                    }
                );
            }
        } else {
            $log.debug('no nextItems action - last page? ');
        }
    };

    $scope.changeAppliedPromotionsType = function(type) {
        var params = {};
        var labelName = type + 'Promotions';
        $scope.dropDownLabel = {'value': $scope.customLabels[labelName]};
        $log.debug('changeAppliedPromotionsType: type selected is: ' + type);
        params.appliedPromoStatusFilter = type;
        $scope.appliedPromotionsTypeSelected = type;
        delete $scope.appliedPromotionsCommitmentDateSelected.value;

        if ($scope.$parent.data.dataSource) {
            delete $scope.$parent.data.dataSource.value.inputMap.commitmentDateFilter;
            $scope.$parent.updateDatasource(params);
        }
    };

    $scope.changeAppliedPromotionsCommitmentDate = function() {
        var params = {};
        $log.debug('changeAppliedPromotionsCommitmentDate: date selected is: ' + $scope.appliedPromotionsCommitmentDateSelected.value);
        params.appliedPromoStatusFilter = 'Active';
        params.commitmentDateFilter = $scope.appliedPromotionsCommitmentDateSelected.value;

        if ($scope.$parent.data.dataSource) {
            $scope.$parent.updateDatasource(params);
        }
    };

    $scope.changeEffectiveAssetsDate = function() {
        $log.debug('changeEffectiveAssetsDate: date selected is: ' + $scope.effectiveAssetsDateSelected.value);
        $rootScope.$broadcast('vlocity.assets.reload', $scope.effectiveAssetsDateSelected.value);
    };

    $scope.getEffectiveDate = function() {
        var dateTimeFiltter = $scope.effectiveAssetsDateSelected.value;
        return new Date(dateTimeFiltter.getTime() - (dateTimeFiltter.getTimezoneOffset() * 60000)).toISOString().slice(0,-1);   
    };

    $scope.sortBySequenceValue = $rootScope.nsPrefix + 'Sequence__c.value';

    $scope.assetChangeToQuote = function(accountId, assetIncludeType) {
        AssetsService.assetChangeToQuote(accountId, assetIncludeType, $scope.customLabels['ASSETChangeToQuote'],
            toastCustomLabels['ASSETChangeError'], toastCustomLabels['ASSETNoItemSelected']);
    };

    $scope.assetChangeToOrder = function() {
       AssetsService.assetChangeToOrder($scope.customLabels['ASSETChangeToOrder'],
            toastCustomLabels['ASSETChangeError'], toastCustomLabels['ASSETNoItemSelected']);
     };

    $scope.assetMove = function() {
       AssetsService.assetMove($scope.customLabels['ASSETMove'],
            toastCustomLabels['ASSETChangeError'], toastCustomLabels['ASSETNoItemSelected'], toastCustomLabels['ASSETMoreThanOneItemSelected']);
    };

}]);

},{}],5:[function(require,module,exports){
angular.module('assets')
.controller('AssetsProductItemController', ['$scope', '$rootScope', '$log', '$timeout', 'AssetsService', 'CPQAdjustmentService', 'CPQCustomViewsService', 'CPQLevelBasedApproachService', 'CPQResponsiveHelper',
    function($scope, $rootScope, $log, $timeout, AssetsService, CPQAdjustmentService, CPQCustomViewsService, CPQLevelBasedApproachService, CPQResponsiveHelper) {

        $scope.isMobileTablet = CPQResponsiveHelper.mobileTabletDevice;
        // isSelected set to true when user opens a config attributes for edit:
        $scope.isSelected = false;

        $scope.clickOnAssetCheckbox = function(object) {
            AssetsService.recordAssetSelectedForModification(object);
            if (AssetsService.getNumberOfAssetsSelected() === 0) {
                $rootScope.vlocityAssets.enableChangeToCartButton = false;
                $rootScope.vlocityAssets.enableMoveButton = false;
            } else if (AssetsService.getNumberOfAssetsSelected() === 1) {
                $rootScope.vlocityAssets.enableChangeToCartButton = true;
                $rootScope.vlocityAssets.enableMoveButton = true;
            } else if (AssetsService.getNumberOfAssetsSelected() > 1) {
                $rootScope.vlocityAssets.enableChangeToCartButton = true;
                $rootScope.vlocityAssets.enableMoveButton = false;
            }
        };

        $scope.openAdjustmentModal = function(field, type) {
            var modalScope = $scope.$new();
            var parentObj =  $scope.$parent.obj;

            CPQAdjustmentService.openDetailsModal(modalScope, parentObj, field, type, true);
        };

        // Enter full screen if child level reaches 5
        $scope.fullScreen = function(level, show) {
            if (show && level > 4 && $scope.attrs.showProductList) {
                $rootScope.$broadcast('cpq-hide-product-list');
            }
        };


        /* Siblings of non root item use the same intance of cartItemController
         * Exposing selected item id to the scope for comparision in templates
         * isSelectedItemObjId is used in border highlighting logic of the selected item */
        $scope.isSelectedItemObjId = '';

        //is expand mode enabled?
        $scope.expandMode = ($rootScope.vlocityAssets.customSettings['Product Configuration Mode'] ? ($rootScope.vlocityAssets.customSettings['Product Configuration Mode'].toLowerCase() === 'expand') : false);

        /*********** CPQ CART ITEM EVENTS ************/
        var unbindEvents = [];

        //Modal events for cross rules update.
        //Accepts dynamic function arguments
        unbindEvents[unbindEvents.length] = $scope.$on('vlocity.cpq.cartitem.actions', function(event, actionType, obj) {
            crossAction (event, actionType, obj);
        });

        // When the info panel is closed, set the isSelected variable to false
        // Removes selected border for line item
        unbindEvents[unbindEvents.length] = $scope.$on('vlocity.assets.infopanel.enabled', function(event, isInfoPanelEnabled) {
            if (!isInfoPanelEnabled) {
                $scope.isSelected = false;
                $scope.isSelectedItemObjId = '';
            }
        });

        $scope.$on('$destroy', function() {
            if ($scope.isSelected) {
                //Publish an event to close the info panel
                $rootScope.$broadcast('vlocity.assets.infopanel.enabled', false);
            }

            //Removes all listeners
            unbindEvents.forEach(function (fn) {
                fn();
            });
        });

        /*********** END CPQ CART ITEM EVENTS ************/
        if ($rootScope.customViews === undefined) {
            $rootScope.customViews = new CPQCustomViewsService($scope);
        }

        function setupViewModel(records) {
            $log.debug('PROCESS RECORDS BEFORE: ', records);
            if (!records) {
                return;
            }
            $scope.viewModelRecords = [];

            if (records.lineItems && records.lineItems.records) {
                angular.forEach(records.lineItems.records, function(value) {
                    $scope.viewModelRecords.push(value);
                });
            }

            if (records.childAssets && records.childAssets.records) {
                angular.forEach(records.childAssets.records, function(childProd) {
                    $scope.viewModelRecords.push(childProd);
                });
            }

            if (records.productGroups && records.productGroups.records) {
                angular.forEach(records.productGroups.records, function(value) {
                    $scope.viewModelRecords.push(value);
                });
            }
            $log.debug('PROCESS RECORDS AFTER: ', $scope.viewModelRecords);
        }

        if (!angular.isArray($scope.records)) {
            setupViewModel($scope.records);
        }

        /**
         * config: Launches attributes configuration for line item in cart
         * @param  {object} itemObject
        */
        $scope.config = function(parent, itemObject) {
            var refreshMode = true;
            // Refresh opened vdf in info panel if any, to avoid FOUC. Dont refresh the entire info panel
            $rootScope.$broadcast('vlocity.assets.infopanel.enabled', false, null, refreshMode);

            // Run after the current call stack is executed
            $timeout(function() {
                $scope.isSelected = true;
                $scope.isSelectedItemObjId = itemObject.Id;
                // Publishes Event to enable the info panel
                $rootScope.$broadcast('vlocity.assets.infopanel.enabled', true, itemObject);
            }, 0);
        };

        function crossAction (event, type, data) {
            // var toBeAddedLineItem, parentInCardData, grandParentInCardData, productGroupParentInCardData, productGroupParentFromAPI, sessionStorageLayoutLoaded;

            //WIP cross actions feature
            switch (type) {
                case 'viewmodel':
                    // Update view model after preview modal is closed
                    if ($scope.$parent.obj && (data.item.Id.value === $scope.$parent.obj.Id.value) && (data.item.Id.scopeId === $scope.$parent.obj.Id.scopeId)) {
                        setupViewModel(data.item);
                    }
                    // Publish an event to update data if configpanel enabled for this item
                    if ($scope.isSelected) {
                        $rootScope.$broadcast('vlocity.assets.infopanel.enabled', true, data.item);
                    }
                    break;
            }
        }

        // Level Based Approach
        $scope.determineChildProdOpenOrCloseInitially = function(childProd) {
            // if custom setting dictates node to open initially (if possible)
            if ($scope.expandMode) {
                return CPQLevelBasedApproachService.determineChildProdOpenOrCloseInitially(childProd);
            // if custom setting dictates node to close initially
            } else {
                // Display close icon
                return false;
            }
        };

        $scope.determineChildProdOpenOrCloseAfterClick = function(childProd, childProdState) {
            return CPQLevelBasedApproachService.determineChildProdOpenOrCloseAfterClick(childProd, childProdState, null, $scope.$id);
        };

        $scope.determineIfChildProdOpenOrCloseIconShouldBeHidden = function(childProd) {
            return CPQLevelBasedApproachService.determineIfChildProdOpenOrCloseIconShouldBeHidden(childProd);
        };

        $scope.checkIfChildProdHasChildren = function(childProd) {
            return CPQLevelBasedApproachService.checkIfChildProdHasChildren(childProd);
        };
        // End Level Based Approach

    }
]);

},{}],6:[function(require,module,exports){
angular.module('hybridCPQ')
.factory('AssetsService', ['$log', '$rootScope', '$sldsToast', 'CPQService', function($log, $rootScope, $sldsToast, CPQService) {

    var launchUrl = function(launchUrl, title) {
        if (typeof sforce !== 'undefined') {
            if (sforce.console && sforce.console.isInConsole()) {
                sforce.console.openPrimaryTab(null, launchUrl, true, title,null, title);
            } else {
                if(typeof sforce.one === 'object') {
                    sforce.one.navigateToURL(launchUrl, false);
                } else {
                    window.parent.location.href = launchUrl;
                }
            }
        } else {
            // I found out that sforce is always defined in all my testing, but to be defensive, we will also handle it for some reason not being there
            window.parent.location.href = launchUrl;
        }
    };

    return {

        selectedAssetIdsForModification : [],

        recordAssetSelectedForModification : function(item) {
            if (!_.includes(this.selectedAssetIdsForModification, item.Id.value)) {
                this.selectedAssetIdsForModification.push(item.Id.value);
            } else {
                _.pull(this.selectedAssetIdsForModification, item.Id.value);
            }
        },

        getNumberOfAssetsSelected : function() {
            return this.selectedAssetIdsForModification.length;
        },

        getAssetIdsSelected : function() {
            var i;
            var selectedAssetIds = '';
            for (i = 0; i < this.selectedAssetIdsForModification.length; i++) {
                selectedAssetIds += this.selectedAssetIdsForModification[i];
                if (i < this.selectedAssetIdsForModification.length - 1) {
                    selectedAssetIds += '+';
                }
            }
            return selectedAssetIds;
        },

        getItemFieldsList : function(itemObject) {
            var itemKeys, fieldsList;

            fieldsList = $rootScope.customViews.cpqCustomViews[$rootScope.customViews.currentCustomView].fields;
            fieldsList = fieldsList.map(function(field) { return field.fieldName; });
            itemKeys = _.keys(itemObject);
            // Exclude all CustomView fields
            _.pullAll(itemKeys, fieldsList);

            return itemKeys;
        },
        //HYB-1961 Clearing the preselected values once tab changes
        clearAssetsSelected : function(){
            this.selectedAssetIdsForModification.length = 0; 
        },

        assetChangeToQuote : function(accountId, assetIncludeType, title, errorTitle, errorMsg) {
            var assetIdsSelected = this.getAssetIdsSelected();
            var assetTypeSelected, changeToQuoteOSTargetUrl;
            if (assetIncludeType === 'noContractAssets') {
                assetTypeSelected = ':all:';
            } else if (assetIncludeType === 'allAssets') {
                assetTypeSelected = ':all:';
            } else if (assetIncludeType === 'billedAssets') {
                assetTypeSelected = ':billing:';
            } else if (assetIncludeType === 'serviceAssets') {
                assetTypeSelected = ':service:';
            }
            changeToQuoteOSTargetUrl = '/apex/' + $rootScope.nsPrefix + 'OmniScriptUniversalPage?id=' + accountId + assetTypeSelected + assetIdsSelected +
                    '#/OmniScriptType/MACD/OmniScriptSubType/ChangeToQuote/OmniScriptLang/English/ContextId/' + accountId + assetTypeSelected + assetIdsSelected +
                    '/PrefillDataRaptorBundle//true';
            if (this.selectedAssetIdsForModification.length === 0) {
                $sldsToast({
                    title: errorTitle,
                    content: errorMsg,
                    severity: 'error',
                    icon: 'warning',
                    autohide: true,
                    show: CPQService.toastEnabled('error')
                });
            } else {
                launchUrl(changeToQuoteOSTargetUrl,title);
            }
        },

        assetChangeToOrder : function(title, errorTitle, errorMsg) {
            var assetIdsSelected = this.getAssetIdsSelected();
            var changeToOrderOSTargetUrl = '/apex/' + $rootScope.nsPrefix + 'MACDFdo?id=' + assetIdsSelected +
                    '#/OmniScriptType/MACD/OmniScriptSubType/FDO/OmniScriptLang/English/ContextId/' + assetIdsSelected +
                    '/PrefillDataRaptorBundle//true';
            if (this.selectedAssetIdsForModification.length === 0) {
                $sldsToast({
                    title: errorTitle,
                    content: errorMsg,
                    severity: 'error',
                    icon: 'warning',
                    autohide: true,
                    show: CPQService.toastEnabled('error')
                });
            } else {
                launchUrl(changeToOrderOSTargetUrl,title);
             }
        },

        assetMove : function(title, errorTitle, errorMsgNoItemSelected, errorMsgMoreThanOneItemSelected) {
            var assetIdsSelected = this.getAssetIdsSelected();
            var moveOSTargetUrl = '/apex/MoveInAccount?id=' + assetIdsSelected;
            if (this.selectedAssetIdsForModification.length === 0) {
                $sldsToast({
                    title: errorTitle,
                    content: errorMsgNoItemSelected,
                    severity: 'error',
                    icon: 'warning',
                    autohide: true,
                    show: CPQService.toastEnabled('error')
                });
            } else if (this.selectedAssetIdsForModification.length > 1) {
                $sldsToast({
                    title: errorTitle,
                    content: errorMsgMoreThanOneItemSelected,
                    severity: 'error',
                    icon: 'warning',
                    autohide: true,
                    show: CPQService.toastEnabled('error')
                });
            } else {
                launchUrl(moveOSTargetUrl,title);
            }
        }

    };
}]);

},{}]},{},[1]);

})();