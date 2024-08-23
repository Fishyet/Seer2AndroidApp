package com.taomee.seer2.app {
import com.taomee.seer2.app.init.LoginInfo;
import com.taomee.seer2.app.net.CommandSet;
import com.taomee.seer2.app.net.Connection;
import com.taomee.seer2.app.netForRelogin.ConnectionForRelogin;
import com.taomee.seer2.app.popup.AlertManager;
import com.taomee.seer2.core.manager.GlobalsManager;
import com.taomee.seer2.core.net.LittleEndianByteArray;
import com.taomee.seer2.core.net.MessageEvent;

import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.media.Sound;
import flash.media.SoundMixer;
import flash.media.SoundTransform;
import flash.net.SharedObject;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

public class ReEntry {

    public static var isTrying:Boolean = false;

    private static var _socketTimeOut:int;

    private static var consistentFailNum:uint = 0;

    private static var _mainServerLoginInfo:MainServerLoginInfo;

    public function ReEntry() {
    }

    public static function reLogin():void {
        isTrying = true;
        ConnectionForRelogin.initialize();
        if (consistentFailNum > 2) {
            SoundMixer.soundTransform = new SoundTransform(1);
            var sound:Sound = new DisconnectionAlert();
            sound.play(0, 5);
            AlertManager.showAutoCloseAlert("重连失败, 退出游戏!", 4, NativeApplication.nativeApplication.exit);
            return;
        }
        addConnectionErrorListener();
        addConnectionEventListener();
        var onSocketTimeOut:Function = function ():void {
            onSocketError(null);
        }
        try {
            _socketTimeOut = setTimeout(onSocketTimeOut, 6000);
            if (Connection.netType == Connection.CNC) {
                ConnectionForRelogin.connect("118.89.150.23", 1863);
            } else {
                ConnectionForRelogin.connect("118.89.150.43", 1863);
            }
        } catch (e:SecurityError) {
            trace("SecurityError");
            AlertManager.showAutoCloseAlert("出错!");
        }
    }

    private static function accountLogin(param1:Event):void {
        removeConnectionErrorListener();
        removeConnectionEventListener();
        clearTimeout(_socketTimeOut);

        var _loc2_:LittleEndianByteArray = new LittleEndianByteArray();
        var p:String = getPassword();
        _loc2_.writeUTFBytes(p);
        _loc2_.length = 32;
        var verifyCodeInfo:VerifyCodeInfo = new VerifyCodeInfo(null);
        ConnectionForRelogin.addCommandListener(103, onLoginCommandResponse);
        ConnectionForRelogin.send(103, _loc2_, 65, 10, 0, verifyCodeInfo.getVerifyImgIdData(), verifyCodeInfo.getVerifyCodeData(), getTopLeftTmcid());
    }

    private static function onLoginCommandResponse(param1:com.taomee.seer2.app.netForRelogin.MessageEvent):void {
        //连接成功
        ConnectionForRelogin.removeCommandListener(103, onLoginCommandResponse);
        _mainServerLoginInfo = new MainServerLoginInfo(param1.message.getRawData());
        if (_mainServerLoginInfo.resultFlag > 0 && _mainServerLoginInfo.resultFlag < 6) {
            trace("login error!");
            onSocketError(null);
        } else {
            _mainServerLoginInfo.account = LoginInfo.account.toString();
            //ConnectionForRelogin.send(111, _mainServerLoginInfo.session);
            ConnectionForRelogin.addCommandListener(105, onGetServerList);
            ConnectionForRelogin.send(105, _mainServerLoginInfo.session, 65);

        }
    }

    private static function onGetServerList(param1:com.taomee.seer2.app.netForRelogin.MessageEvent):void {
        ConnectionForRelogin.removeCommandListener(105, onGetServerList);
        param1.message.getRawData().readUnsignedInt();
        var list:OnlineServerListInfo = new OnlineServerListInfo(param1.message.getRawData());
        connectGameServer(list.serverInfoVector[2].serverId, list.serverInfoVector[2].serverIp, list.serverInfoVector[2].serverPort);
        //随便选一个服务器,这里就选第三个;不能直接用之前连接的服务器,会出现"用户重复登录弹窗"
    }

    private static function connectGameServer(id:uint, ip:String, port:uint):void {
        var onSocketTimeOut:Function = function ():void {
            onSocketError(null);
        }
        LoginInfo.session = _mainServerLoginInfo.session;
        LoginInfo.serverId = id;
        LoginInfo.onlineServerIp = ip;
        LoginInfo.onlineServerPort = port;
        //与登录服务器通信结束,开始和游戏服务器通讯
        trace("connectGameServer!");
        Connection.addEventListener(Event.CONNECT, onGameServerConnect);
        try {
            _socketTimeOut = setTimeout(onSocketTimeOut, 6000);
            Connection.connect(ip, port);
        } catch (e:SecurityError) {
            trace("SecurityError");
            onSocketError(null);
        }
    }

    private static function onGameServerConnect(param1:Event):void {
        clearTimeout(_socketTimeOut);
        trace("onGameServerConnect!");
        ConnectionForRelogin.dispose();
        Connection.removeEventListener(Event.CONNECT, onGameServerConnect);
        Connection.addCommandListener(CommandSet.ONLINE_LOGIN_1001, onReEntrySuccess);
        Connection.send(CommandSet.ONLINE_LOGIN_1001, GlobalsManager.fromGame, LoginInfo.session, getTopLeftTmcid());
    }


    private static function onSocketError(param1:Event):void {
        removeConnectionErrorListener();
        removeConnectionEventListener();
        consistentFailNum++;
        AlertManager.showAutoCloseAlert("重连失败" + consistentFailNum + "次, 再次尝试!", 2, reLogin);
    }

    private static function onReEntrySuccess(param1:MessageEvent):void {
        isTrying = false;
        consistentFailNum = 0;
        trace("ReEntrySuccess!");
        AlertManager.showAutoCloseAlert("重连成功!", 1);
        Connection.removeCommandListener(CommandSet.ONLINE_LOGIN_1001, onReEntrySuccess);
        LoginInfo.setFromOnline(param1.message.getRawData());
    }

    private static function getTopLeftTmcid():LittleEndianByteArray {
        var data:LittleEndianByteArray = new LittleEndianByteArray();
        data.length = 64;
        if (GlobalsManager.tab != null && GlobalsManager.tab != "none" && GlobalsManager.tab != "") {
            data.writeUTFBytes(GlobalsManager.tab);
        } else {
            data.writeUTFBytes("0");
        }
        return data;
    }

    private static function addConnectionErrorListener():void {
        ConnectionForRelogin.addErrorHandler(103, onSocketError);
        ConnectionForRelogin.addErrorHandler(101, onSocketError);
        ConnectionForRelogin.addErrorHandler(104, onSocketError);
    }

    private static function removeConnectionErrorListener():void {
        ConnectionForRelogin.removeErrorHandler(103, onSocketError);
        ConnectionForRelogin.removeErrorHandler(101, onSocketError);
        ConnectionForRelogin.removeErrorHandler(104, onSocketError);
    }

    private static function addConnectionEventListener():void {
        ConnectionForRelogin.addEventListener(Event.CONNECT, accountLogin);
        ConnectionForRelogin.addEventListener(IOErrorEvent.IO_ERROR, onSocketError);
        ConnectionForRelogin.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSocketError);
        ConnectionForRelogin.addEventListener(Event.CLOSE, onSocketError);
    }

    private static function removeConnectionEventListener():void {
        ConnectionForRelogin.removeEventListener(Event.CONNECT, accountLogin);
        ConnectionForRelogin.removeEventListener(IOErrorEvent.IO_ERROR, onSocketError);
        ConnectionForRelogin.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSocketError);
        ConnectionForRelogin.removeEventListener(Event.CLOSE, onSocketError);
    }

    private static function getPassword():String {
        var infoArr:Array = null;
        var i:int = 0;
        var shareObject:SharedObject = SharedObject.getLocal("seer2/common/login", "/");
        var getDecryptPassword:Function = function (param1:String):String {
            var _loc2_:String = param1.slice(0, 8);
            var _loc3_:String = param1.slice(8, 16);
            var _loc4_:String = param1.slice(16, 24);
            var _loc5_:String = param1.slice(24, 32);
            return _loc3_ + _loc2_ + _loc5_ + _loc4_;
        }
        if ("userAccount" in shareObject.data) {
            infoArr = shareObject.data["userAccount"] == null ? [] : shareObject.data["userAccount"];
            i = 0;
            while (i < infoArr.length) {
                if (parseInt(infoArr[i].account) == LoginInfo.account) {
                    return getDecryptPassword(infoArr[i].password);
                }
                i++;
            }
        }
        trace("password not found!");
        AlertManager.showAutoCloseAlert("出错!");
        return "";
    }
}
}

import com.taomee.seer2.core.net.LittleEndianByteArray;

import flash.utils.IDataInput;

import org.taomee.utils.StringUtil;

class VerifyCodeInfo {
    private var _isNeedVerify:Boolean = false;

    private var _verifyImgIdData:LittleEndianByteArray;

    private var _verifyImgData:LittleEndianByteArray;

    private var _verifyCodeData:LittleEndianByteArray;

    public function VerifyCodeInfo(param1:IDataInput = null) {
        var _loc3_:uint = 0;
        super();
        if (param1 == null) {
            return;
        }
        var _loc2_:uint = uint(param1.readUnsignedInt());
        if (_loc2_ == 1) {
            this._verifyImgIdData = new LittleEndianByteArray();
            param1.readBytes(this._verifyImgIdData, 0, 16);
            _loc3_ = uint(param1.readUnsignedInt());
            this._verifyImgData = new LittleEndianByteArray();
            param1.readBytes(this._verifyImgData, 0, _loc3_);
            this._isNeedVerify = true;
        } else {
            this._isNeedVerify = false;
        }
    }

    public function getVerifyImgIdData():LittleEndianByteArray {
        var _loc1_:int = 0;
        if (this._verifyImgIdData == null) {
            this._verifyImgIdData = new LittleEndianByteArray();
            _loc1_ = 0;
            while (_loc1_ < 16) {
                this._verifyImgIdData.writeByte(0);
                _loc1_++;
            }
        }
        return this._verifyImgIdData;
    }

    public function getVerifyCodeData():LittleEndianByteArray {
        var _loc1_:int = 0;
        if (this._verifyCodeData == null) {
            this._verifyCodeData = new LittleEndianByteArray();
            _loc1_ = 0;
            while (_loc1_ < 6) {
                this._verifyCodeData.writeByte(0);
                _loc1_++;
            }
        }
        return this._verifyCodeData;
    }
}

class MainServerLoginInfo {


    public var resultFlag:int;

    public var account:String;

    public var password:String;

    public var session:LittleEndianByteArray;

    public var hasRole:Boolean = false;

    public var verifyImgId:LittleEndianByteArray;

    public var verifyImgDataSize:int;

    public var verifyImgData:LittleEndianByteArray;

    public var lastLoginIP:String;

    public var lastLoginTime:uint;

    public var lastLoginCity:String;

    public var curLoginCity:String;

    public function MainServerLoginInfo(param1:LittleEndianByteArray) {
        super();
        if (param1 == null) {
            return;
        }
        this.resultFlag = param1.readUnsignedInt();
        if (this.resultFlag < 0) {
            return;
        }
        if (this.resultFlag == 0) {
            this.session = new LittleEndianByteArray();
            param1.readBytes(this.session, 0, 16);
            this.hasRole = param1.readUnsignedInt() > 0;
        } else if (this.resultFlag < 6) {
            this.verifyImgId = new LittleEndianByteArray();
            param1.readBytes(this.verifyImgId, 0, 16);
            this.verifyImgDataSize = param1.readUnsignedInt();
            this.verifyImgData = new LittleEndianByteArray();
            param1.readBytes(this.verifyImgData, 0, this.verifyImgDataSize);
        } else {
            this.session = new LittleEndianByteArray();
            param1.readBytes(this.session, 0, 16);
            this.hasRole = param1.readUnsignedInt() > 0;
            this.lastLoginIP = StringUtil.uintToIp(param1.readUnsignedInt());
            this.lastLoginTime = param1.readUnsignedInt();
            this.lastLoginCity = param1.readUTFBytes(64);
            this.curLoginCity = param1.readUTFBytes(64);
        }
    }
}

class ServerInfo {


    public var serverId:uint;

    public var serverIp:String;

    public var serverPort:uint;

    public var userCount:uint;

    public var friendCount:uint;

    public var _isNewSvr:uint;

    public var isRecommendSvr:uint;

    public function ServerInfo(param1:IDataInput = null) {
        super();
        if (param1) {
            this.serverId = param1.readUnsignedShort();
            this.serverIp = param1.readUTFBytes(16);
            this.serverPort = param1.readUnsignedShort();
            this.userCount = param1.readUnsignedInt();
            this.friendCount = param1.readUnsignedByte();
            this._isNewSvr = param1.readUnsignedByte();
        }
    }

    public function get isNewSvr():uint {
        return this._isNewSvr;
    }
}

class OnlineServerListInfo {


    public var serverInfoVector:Vector.<ServerInfo>;

    public var friendData:IDataInput;

    public var isNewPlayer:uint;

    public function OnlineServerListInfo(param1:IDataInput) {
        var _loc4_:ServerInfo = null;
        this.serverInfoVector = new Vector.<ServerInfo>();
        super();
        var _loc2_:uint = uint(param1.readUnsignedInt());
        var _loc3_:uint = 0;
        while (_loc3_ < _loc2_) {
            _loc4_ = new ServerInfo(param1);
            this.serverInfoVector.push(_loc4_);
            _loc3_++;
        }
        this.isNewPlayer = param1.readUnsignedByte();
        this.friendData = param1;
    }
}
