const YandexSDK = (function () {

    let isDebug = false;

    let ysdk = null;
    let player = null;
    let leaderboards = null;
    let cloudDataCached = null;
    let safeStorageKey = '';
    let safeStorageDataCached = null;

    // constructor
    function YandexSDK(_isDebug, _safeStorageKey) {
        this.isDebug = _isDebug;
        this.safeStorageKey = Helpers.encodeBase64(_safeStorageKey);
    }

    function YandexSDKProto(_isDebug, _safeStorageKey) {
        const proto = {
            isSDKInitialized: function() {
                return this.ysdk != null;
            },
            isPlayerInitialized: function() {
                return this.player != null;
            },
            isLeaderboardsInitialized: function() {
                return this.leaderboards != null;
            },
            initSDK: function(params, callback) {
                this.isDebug && console.log('Yandex SDK start initialisation');
                YaGames.init(params).then(_sdk => {
                    this.ysdk = _sdk;
                    this.isDebug && console.log('Yandex SDK initialized');
                    callback();
                }).catch(err => {
                    this.isDebug && console.log(err);
                    this.isDebug && console.log('Yandex SDK initialization error');
                });
            },
            initGame: function() {
                this.ysdk.features.LoadingAPI?.ready();
                this.isDebug && console.log('Game initialized');
            },
            initPlayer: function(full, callback) {
                this.isDebug && console.log('Player start initialisation', full);
                this.ysdk.getPlayer(full).then(_player => {
                    this.player = _player;
                    this.isDebug && console.log('Player initialized');
                    // if (this.player.getMode() === 'lite') { // player not logged in
                    //     this.ysdk.auth.openAuthDialog().then(() => { // player is logged in after auth
                    //         this.initPlayer(full, callback).catch(err => {
                    //             this.isDebug && console.log('Player initialization error', err);
                    //             return callback();
                    //         });
                    //     }).catch(err => { // player not logged in after auth
                    //         this.isDebug && console.log('Player not logged in', err);
                    //         return callback();
                    //     });
                    // }
                    callback();
                 }).catch(err => {
                    this.isDebug && console.log('Player initialization error', err);
                });
            },
            initLeaderboards: function(callback) {
                this.ysdk.getLeaderboards().then(_lb =>{
                     this.leaderboards = _lb;
                     this.isDebug && console.log('Leaderboards initialized');
                    callback();
                });
            },
            setLeaderboardScore: function(leaderboardName, score) {
                this.ysdk.isAvailableMethod('leaderboards.setLeaderboardScore').then((isAvailable => {
                    if (isAvailable) {
                        this.leaderboards.setLeaderboardScore(leaderboardName, score);
                        this.isDebug && console.log('Leaderboard highscore set: ', score);
                    }
                    else {
                        this.isDebug && console.log('Leaderboard highscore not set: player not initialized');
                    }
                }));
            },
            showAd: function(callback) {
                this.isDebug && console.log('Show ad');
                this.ysdk.adv.showFullscreenAdv({
                    callbacks: {
                        onClose: function(wasShown) {
                            callback('closed')
                            this.isDebug && console.log('Ad shown');
                        },
                        onError: function(error) {
                            callback('error')
                            this.isDebug && console.log('Ad error');
                        }
                    }
                })
            },
            showAdRewardedVideo: function(callback) {
                this.isDebug && console.log('Show rewarded video');
                this.ysdk.adv.showRewardedVideo({
                    callbacks: {
                        onOpen: () => {
                            callback('opened')
                            this.isDebug && console.log('Rewarded video open.');
                        },
                        onRewarded: () => {
                            callback('rewarded')
                            this.isDebug && console.log('Rewarded!');
                        },
                        onClose: () => {
                            callback('closed')
                            this.isDebug && console.log('Rewarded video ad closed.');
                        }, 
                        onError: (e) => {
                            callback('error')
                            this.isDebug && console.log('Error while open rewarded video ad:', e);
                        }
                    }
                })
            },
            saveDataToCloud: function(data, force) {
                this.isDebug && console.log('Data save ', data);
                this.player.setData(data, force).then(() => {
                    this.cloudDataCached = data;
                    this.isDebug && console.log('Data saved');
                });
            },
            saveDataToSafeStorage: function(data) {
                this.ysdk.getStorage().then(safeStorage => {
                    // var storageKeyResult = this.loadDataAllFromSafeStorageInternal(safeStorage);
                    var storageKeyResultObj = {};
                    // if (Helpers.isJsonString(storageKeyResult)) {
                    //     storageKeyResultObj = JSON.parse(storageKeyResult);
                    // }
                    Object.keys(data).forEach(function(key) {
                        storageKeyResultObj[key] = data[key];
                    });
                    safeStorage.setItem(this.safeStorageKey, JSON.stringify(storageKeyResultObj));
                    this.isDebug && console.log('Data saved to safe storage ' + this.safeStorageKey, storageKeyResultObj);
                    this.safeStorageDataCached = data;
                })
            },
            saveStats: function(data) {
                this.isDebug && console.log('Stats save ', data);
                this.player.setStats(data).then(() => {
                    this.isDebug && console.log('Stats saved');
                });
            },
            loadDataFromCloud: function(keys, callback) {
                this.isDebug && console.log('Data load ');
                this.player.getData(keys).then(
                    result => {
                        this.cloudDataCached = result;
                        this.isDebug && console.log('Data loaded', result);
                        callback('loaded', result);
                    },
                    error => {
                        this.cloudDataCached = null;
                        this.isDebug && console.log('Data load error');
                        callback('error');
                    }
                );
            },
            loadDataAllFromCloud: function(callback) {
                this.isDebug && console.log('Data load ');
                this.player.getData().then(
                    result => {
                        this.cloudDataCached = result;
                        this.isDebug && console.log('Data loaded', result);
                        callback('loaded', result);
                    },
                    error => {
                        this.cloudDataCached = null;
                        this.isDebug && console.log('Data load error');
                        callback('error');
                    }
                );
            },
            getCachedDataFromCloud: function() {
                this.isDebug && console.log('Cached cloud data', this.cloudDataCached);
                return this.cloudDataCached;
            },
            loadDataAllFromSafeStorageInternal: function(safeStorage) {
                var storageKeyResult = safeStorage.getItem(this.safeStorageKey);
                if (storageKeyResult == null) {
                    this.isDebug && console.log('Key does not exist in safe storage ' + this.safeStorageKey);
                    storageKeyResult = {};
                }
                return storageKeyResult;
            },
            loadDataFromSafeStorage: function(keys, callback) {
                this.ysdk.getStorage().then(safeStorage => {
                    var storageKeyResult = this.loadDataAllFromSafeStorageInternal(safeStorage);
                    var storageKeyResultObj = {};
                    if (Helpers.isJsonString(storageKeyResult)) {
                        storageKeyResultObj = JSON.parse(storageKeyResult);
                    }
                    var result  = {};
                    keys.forEach(function(key) {
                        if (storageKeyResultObj.hasOwnProperty(key)){
                            var item = storageKeyResultObj[key];
                            result[key] = item;
                        }
                    });
                    this.isDebug && console.log('Data loaded from safe storage ' + this.safeStorageKey, result);
                    this.safeStorageDataCached = result;
                    callback(result);
                })
            },
            loadDataAllFromSafeStorage: function(callback) {
                this.ysdk.getStorage().then(safeStorage => {
                    var storageKeyResult = this.loadDataAllFromSafeStorageInternal(safeStorage);
                    var storageKeyResultObj = {};
                    if (Helpers.isJsonString(storageKeyResult)) {
                        storageKeyResultObj = JSON.parse(storageKeyResult);
                    }
                    var result = storageKeyResultObj;
                    this.safeStorageDataCached = result;
                    this.isDebug && console.log('Data loaded from safe storage', this.safeStorageDataCached);
                    callback(result);
                })
            },
            getCachedDataFromSafeStorage: function() {
                this.isDebug && console.log('Cached safe storage data', this.safeStorageDataCached);
                return this.safeStorageDataCached;
            },
            loadStats: function(keys, callback) {
                this.isDebug && console.log('Stats load ', keys);
                this.player.getStats(keys).then(
                    result => {
                        this.isDebug && console.log('Stats loaded');
                        callback('loaded', result);
                    },
                    error => {
                        this.isDebug && console.log('Stats load error');
                        callback('error');
                    }
                );
            },
            getLocale: function() {
                return this.ysdk.environment.i18n.lang;
            },
            removeDataFromSafeStorage: function(keys) {
                for (var i = 0, len = keys.length; i < len; ++i) {
                    const key = keys[i];
                    if (this.safeStorageDataCached && this.safeStorageDataCached.hasOwnProperty(key)) {
                        delete this.safeStorageDataCached[key];
                    }
                }
                this.isDebug && console.log('removed ', keys);
                this.saveDataToSafeStorage(this.safeStorageDataCached)
            },
            clearSafeStorage: function() {
                this.ysdk.getStorage().then(safeStorage => {
                    safeStorage.removeItem(this.safeStorageKey);
                    this.safeStorageDataCached = null;
                });
            },
        };

        YandexSDK.prototype = proto;
        YandexSDK.prototype['isSDKInitialized'] = YandexSDK.prototype.isSDKInitialized;
        YandexSDK.prototype['isPlayerInitialized'] = YandexSDK.prototype.isPlayerInitialized;
        YandexSDK.prototype['isLeaderboardsInitialized'] = YandexSDK.prototype.isLeaderboardsInitialized;
        YandexSDK.prototype['initSDK'] = YandexSDK.prototype.initSDK;
        YandexSDK.prototype['initGame'] = YandexSDK.prototype.initGame;
        YandexSDK.prototype['initPlayer'] = YandexSDK.prototype.initPlayer;
        YandexSDK.prototype['initLeaderboards'] = YandexSDK.prototype.initLeaderboards;
        YandexSDK.prototype['setLeaderboardScore'] = YandexSDK.prototype.setLeaderboardScore;
        YandexSDK.prototype['showAd'] = YandexSDK.prototype.showAd;
        YandexSDK.prototype['showAdRewardedVideo'] = YandexSDK.prototype.showAdRewardedVideo;
        YandexSDK.prototype['saveDataToCloud'] = YandexSDK.prototype.saveDataToCloud;
        YandexSDK.prototype['saveDataToSafeStorage'] = YandexSDK.prototype.saveDataToSafeStorage;
        YandexSDK.prototype['saveStats'] = YandexSDK.prototype.saveStats;
        YandexSDK.prototype['loadDataFromCloud'] = YandexSDK.prototype.loadDataFromCloud;
        YandexSDK.prototype['loadDataAllFromCloud'] = YandexSDK.prototype.loadDataAllFromCloud;
        YandexSDK.prototype['getCachedDataFromCloud'] = YandexSDK.prototype.getCachedDataFromCloud;
        YandexSDK.prototype['loadDataAllFromSafeStorageInternal'] = YandexSDK.prototype.loadDataAllFromSafeStorageInternal;
        YandexSDK.prototype['loadDataAllFromSafeStorage'] = YandexSDK.prototype.loadDataAllFromSafeStorage;
        YandexSDK.prototype['loadDataFromSafeStorage'] = YandexSDK.prototype.loadDataFromSafeStorage;
        YandexSDK.prototype['getCachedDataFromSafeStorage'] = YandexSDK.prototype.getCachedDataFromSafeStorage;
        YandexSDK.prototype['loadStats'] = YandexSDK.prototype.loadStats;
        YandexSDK.prototype['getLocale'] = YandexSDK.prototype.getLocale;
        YandexSDK.prototype['removeDataFromSafeStorage'] = YandexSDK.prototype.removeDataFromSafeStorage;
        YandexSDK.prototype['clearSafeStorage'] = YandexSDK.prototype.clearSafeStorage;

        return new YandexSDK(_isDebug, _safeStorageKey);
    };

    return YandexSDKProto;

}());