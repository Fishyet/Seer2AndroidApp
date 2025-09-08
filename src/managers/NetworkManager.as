package managers {
import events.DNSResolveEvent;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.utils.ByteArray;

import net.DNSResolver;
import net.VersionInfoParser;

/**
 * 网络管理器
 * 负责DNS解析、文件下载、版本检查等网络操作
 */
public class NetworkManager {

    private var _dnsResolver:DNSResolver;
    private var _versionInfoStream:URLStream;
    private var _currentDownloadLoader:URLLoader;

    public function NetworkManager() {
    }

    /**
     * DNS解析
     */
    public function resolveDNS(domain:String, onComplete:Function, onError:Function):void {
        this._dnsResolver = new DNSResolver(domain);
        this._dnsResolver.addEventListener(DNSResolver.RESOLVE_COMPLETE, function (e:DNSResolveEvent):void {
            _dnsResolver.removeEventListener(DNSResolver.RESOLVE_COMPLETE, arguments.callee);
            _dnsResolver.removeEventListener(DNSResolver.RESOLVE_ERROR, onDNSError);
            onComplete(e.data);
        });

        var onDNSError:Function = function (e:Event):void {
            _dnsResolver.removeEventListener(DNSResolver.RESOLVE_COMPLETE, arguments.callee);
            _dnsResolver.removeEventListener(DNSResolver.RESOLVE_ERROR, onDNSError);
            onError("DNS解析失败");
        };

        this._dnsResolver.addEventListener(DNSResolver.RESOLVE_ERROR, onDNSError);
        this._dnsResolver.resolve();
    }

    /**
     * 检查版本信息
     */
    public function checkVersion(rootURL:String, versionURL:String, onComplete:Function, onError:Function):void {
        this._versionInfoStream = new URLStream();
        this._versionInfoStream.addEventListener(Event.COMPLETE, function (event:Event):void {
            _versionInfoStream.removeEventListener(Event.COMPLETE, arguments.callee);
            _versionInfoStream.removeEventListener(IOErrorEvent.IO_ERROR, onVersionError);

            var versionInfo:ByteArray = new ByteArray();
            _versionInfoStream.readBytes(versionInfo);
            _versionInfoStream.close();
            _versionInfoStream = null;

            var versionInfoParser:VersionInfoParser = new VersionInfoParser();
            var decryptionKey:String = versionInfoParser.parseVersionInfo(versionInfo);

            if (decryptionKey == VersionInfoParser.EXPIRED) {
                onComplete(decryptionKey);
            } else if (decryptionKey == VersionInfoParser.CLIENT_NEED_UPDATE) {
                onError("需要版本更新啦!");
            } else {
                onComplete(decryptionKey);
            }
        });

        var onVersionError:Function = function (e:IOErrorEvent):void {
            _versionInfoStream.removeEventListener(Event.COMPLETE, arguments.callee);
            _versionInfoStream.removeEventListener(IOErrorEvent.IO_ERROR, onVersionError);
            onError("版本检查失败: " + e.text);
        };

        this._versionInfoStream.addEventListener(IOErrorEvent.IO_ERROR, onVersionError);
        this._versionInfoStream.load(new URLRequest(rootURL + versionURL));
    }

    /**
     * 下载文件到本地
     */
    public function downloadFileToLocal(url:String, localPath:String, onComplete:Function, onError:Function, onProgress:Function = null):void {
        var urlRequest:URLRequest = new URLRequest(url);
        this._currentDownloadLoader = new URLLoader(urlRequest);
        var file:File = File.applicationStorageDirectory.resolvePath(localPath);

        // 如果文件已存在，删除它
        if (file.exists) {
            file.deleteFile();
        }

        var onDownloadComplete:Function = function (event:Event):void {
            _currentDownloadLoader.removeEventListener(Event.COMPLETE, onDownloadComplete);
            _currentDownloadLoader.removeEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
            _currentDownloadLoader.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);

            try {
                var fileStream:FileStream = new FileStream();
                fileStream.open(file, FileMode.WRITE);
                fileStream.writeBytes(_currentDownloadLoader.data);
                fileStream.close();
                onComplete(file.url);
            } catch (e:Error) {
                onError("文件保存失败: " + e.message);
            }
        };

        var onDownloadError:Function = function (event:IOErrorEvent):void {
            _currentDownloadLoader.removeEventListener(Event.COMPLETE, onDownloadComplete);
            _currentDownloadLoader.removeEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
            _currentDownloadLoader.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
            onError("文件下载失败: " + event.text);
        };

        var onDownloadProgress:Function = function (event:ProgressEvent):void {
            if (onProgress != null) {
                var percent:int = event.bytesLoaded / event.bytesTotal * 100;
                onProgress(percent);
            }
        };

        this._currentDownloadLoader.dataFormat = URLLoaderDataFormat.BINARY;
        this._currentDownloadLoader.addEventListener(Event.COMPLETE, onDownloadComplete);
        this._currentDownloadLoader.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
        this._currentDownloadLoader.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
        this._currentDownloadLoader.load(urlRequest);
    }

    /**
     * 检查本地文件是否存在
     */
    public function checkLocalFileExists(localPath:String):Boolean {
        var file:File = File.applicationStorageDirectory.resolvePath(localPath);
        return file.exists;
    }

    /**
     * 获取本地文件
     */
    public function getLocalFile(localPath:String):File {
        return File.applicationStorageDirectory.resolvePath(localPath);
    }

    /**
     * 销毁资源
     */
    public function dispose():void {
        if (this._dnsResolver) {
            this._dnsResolver = null;
        }

        if (this._versionInfoStream) {
            this._versionInfoStream.close();
            this._versionInfoStream = null;
        }

        if (this._currentDownloadLoader) {
            try {
                this._currentDownloadLoader.close();
            } catch (e:Error) {
                // 忽略关闭错误
            }
            this._currentDownloadLoader = null;
        }
    }
}
}
