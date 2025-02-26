package seer2.next.entry {
public class DynSwitch {
    // 布隆过滤器
    public static var bloomfilterFallbackUrl:String;
    // 内网工具
    public static var simulateSendingProtocolHint:String;
    // 更新公告
    public static var changeLogModifyTime:String;
    public static var changeLogModifyUser:String;
    public static var changeLogAnnouncement:String;

    public static var _xml:XML;

    public static function loadConfig(xml:XML):void {
        _xml = xml;

        // 解析布隆过滤器
        bloomfilterFallbackUrl = _xml.bloomfilter.@fallbackurl;

        // 解析模拟发送协议提示
        simulateSendingProtocolHint = _xml.simulatesendingprotocolhint;

        // 解析更新日志
        changeLogModifyTime = _xml.changelog.@modifytime;
        changeLogModifyUser = _xml.changelog.@modifyuser;
        changeLogAnnouncement = "温馨提示: 为了提升游戏进入速度, 动态配置表默认关闭, 但关闭帧数配置表或精灵配置表的同步会导致皮肤系统出问题, 您可以手动打开) \n\n" + _xml.changelog;
    }
}
}
