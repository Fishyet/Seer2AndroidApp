package net {
import events.DNSResolveEvent;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.Timer;

public class DNSResolver extends EventDispatcher {
    private static const DNS_SERVERS:Array = [
        "https://223.5.5.5/resolve",
        "https://dns.google/resolve",
        "https://doh.360.cn/resolve",
        "https://cloudflare-dns.com/dns-resolve",
        "https://223.6.6.6/resolve"
    ];
    private static const TIMEOUT:int = 4000; // Timeout in milliseconds

    private var currentDNSIndex:int = 0;
    private var targetDomain:String;
    private var loader:URLLoader;
    private var timer:Timer;

    public static const RESOLVE_COMPLETE:String = "resolveComplete";
    public static const RESOLVE_ERROR:String = "resolveError";

    public function DNSResolver(domain:String) {
        this.targetDomain = domain;
        this.loader = new URLLoader();
        this.timer = new Timer(TIMEOUT, 1);
        setupListeners();
    }

    public function resolve():void {
        tryNextDNS();
    }

    private function setupListeners():void {
        loader.addEventListener(Event.COMPLETE, onLoadComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimeout);
    }

    private function tryNextDNS():void {
        if (currentDNSIndex >= DNS_SERVERS.length) {
            dispatchEvent(new Event(RESOLVE_ERROR));
            return;
        }

        var request:URLRequest = new URLRequest(DNS_SERVERS[currentDNSIndex] +
                "?name=" + targetDomain + "&type=TXT");
        trace(DNS_SERVERS[currentDNSIndex] + "?name=" + targetDomain + "&type=TXT");
        request.requestHeaders = [{name: "accept", value: "application/dns-json"}];

        try {
            loader.load(request);
            timer.start();
        } catch (e:Error) {
            onLoadError(null);
        }
    }

    private function onLoadComplete(event:Event):void {
        timer.stop();
        try {
            var response:Object = JSON.parse(loader.data);
            if (response.Answer && response.Answer.length > 0) {
                var txtRecord:String = response.Answer[0].data;
                txtRecord = txtRecord.replace(/"/g, ""); // Remove quotes
                dispatchEvent(new DNSResolveEvent(RESOLVE_COMPLETE, txtRecord));
                return;
            }
        } catch (e:Error) {
            // Parse error, try next DNS
        }

        currentDNSIndex++;
        tryNextDNS();
    }

    private function onLoadError(event:IOErrorEvent):void {
        timer.stop();
        currentDNSIndex++;
        tryNextDNS();
    }

    private function onTimeout(event:TimerEvent):void {
        loader.close();
        currentDNSIndex++;
        tryNextDNS();
    }

    public function dispose():void {
        loader.removeEventListener(Event.COMPLETE, onLoadComplete);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimeout);
        loader = null;
        timer = null;
    }
}
}