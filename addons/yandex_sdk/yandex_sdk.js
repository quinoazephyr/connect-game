let ysdk;
function InitGame(params, callback) {
    console.log('Yandex SDK start initialisation');
    YaGames.init(params).then(_sdk => {
        ysdk = _sdk;
        console.log('Yandex SDK initialized');

        ysdk.features.LoadingAPI?.ready();
        console.log('Game initialized');
        
        callback();
    }).catch(err => {
        console.log(err);
        console.log('Game initialization error');
    });
}


let player;
function InitPlayer(full, callback) {
    console.log('Player start initialisation');
    ysdk.getPlayer(full).then(_player => {
        player = _player;
        console.log('Player initialized');
        
        callback();
     }).catch(err => {
        console.log(err);
        console.log('Player initialization error');
    });
}


let lb;
function InitLeaderboards(callback) {
    ysdk.getLeaderboards()
  .then(_lb =>{
         lb = _lb;
        callback();
    });
}

function SetLeaderboardScore(leaderboardName, score) {
    lb.setLeaderboardScore(leaderboardName, score);
    console.log("highscore: ", score);
}

function ShowAd(callback) {
    console.log('Show ad');
    ysdk.adv.showFullscreenAdv({
        callbacks: {
            onClose: function(wasShown) {
                callback('closed')
                console.log('Ad shown');
            },
            onError: function(error) {
                callback('error')
                console.log('Ad error');
            }
        }
    })
}


function ShowAdRewardedVideo(callback) {
    console.log('Show rewarded video');
    ysdk.adv.showRewardedVideo({
        callbacks: {
            onOpen: () => {
                callback("opened")
                console.log('Rewarded video open.');
            },
            onRewarded: () => {
                callback("rewarded")
                console.log('Rewarded!');
            },
            onClose: () => {
                callback("closed")
                console.log('Rewarded video ad closed.');
            }, 
            onError: (e) => {
                callback("error")
                console.log('Error while open rewarded video ad:', e);
            }
        }
    })
}


function SaveData(data, force) {
    console.log('Data save ', data);
    player.setData(data, force).then(() => {
        console.log('Data saved');
    });
}

function SaveDataToSafeStorage(data) {
    console.log('Data save to safe storage ', data);
    ysdk.getStorage().then(safeStorage => {
        Object.keys(data).forEach(function(key) {
            safeStorage.setItem(key, data[key]);
        });
        console.log('Data saved to safe storage');
    })
}


function SaveStats(data) {
    console.log('Stats save ', data);
    player.setStats(data).then(() => {
            console.log('Stats saved');
    });
}


function LoadData(keys, callback) {
    console.log('Data load ');
    player.getData(keys).then(
        result => {
            console.log('Data loaded', result);
            callback("loaded", result);
        },
        error => {
            console.log('Data load error');
            callback("error");
        }
    );
}

function LoadDataFromSafeStorage(keys, callback) {
    console.log('Data load from safe storage');
    ysdk.getStorage().then(safeStorage => {
        var result  = {};
        keys.forEach(function(key) {
            result[key] = safeStorage.getItem(key);
        });
         console.log('Data loaded from safe storage', result);
        callback("loaded", result);
    })
}


function LoadStats(keys, callback) {
    console.log('Stats load ', keys);
    player.getStats(keys).then(
        result => {
            console.log('Stats loaded');
            callback("loaded", result);
        },
        error => {
            console.log('Stats load error');
            callback("error");
        }
    );
}

function GetLocale(callback) {
    callback(ysdk.environment.i18n.lang);
}