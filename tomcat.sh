#定义要监控的页面地址
WebUrl=10.10.115.151:8080
# 日志输出
GetPageInfo=/tmp/TomcatMonitor.Info
TomcatMonitorLog=/tmp/TomcatMonitor.log

#获取tomcat进程
TomcatID=$(ps -ef |grep tomcat |grep -v grep | awk '{print $2}')
TomcatServiceCode=`curl -o /dev/null -s -w "%{http_code}" "${WebUrl}"`
#发送邮件地址
email_address=499573899@qq.com
#当前服务器ip
IP=$(ifconfig -a|awk '/(cast)/ {print $2}'|cut -d':' -f2|head -1)

# tomcat启动程序(tomcat实际安装的路径)
StartTomcat=/home/hanxuzhao/j-tomcat/bin/startup.sh
#tomcat的缓存
TomcatCache=/home/hanxuzhao/j-tomcat/work

echo tomcat_ID:"$TomcatID"
echo TomcatStatus:"$TomcatServiceCode"
Monitor()
{
 echo "[info]开始监控tomcat...[$(date +'%F %H:%M:%S')]"
   # 这里判断TOMCAT进程是否存在
  if [ $TomcatID ] ; then  
   echo "[info]当前tomcat进程ID为:$TomcatID,继续检测页面..."
   # 检测是否启动成功(成功的话页面会返回状态"200")
	if [ $TomcatServiceCode -eq 200 ] ; then
        echo "[info]页面返回码为$TomcatServiceCode,tomcat启动成功,测试页面正常......"
	 else
        echo "[error]tomcat页面出错,状态码为$TomcatServiceCode,错误日志已输出到$GetPageInfo"
        echo "[error]页面访问出错,开始重启tomcat"
	echo "[error]发送告警开启邮件"  
        #echo "$IP的访问系统接口出错，$IP的tomcat开始自动重启 [$(date +'%F %H:%M:%S')]" | mail -s "魔售项目告警开启" $email_address
        # kill -9 $TomcatID  # 杀掉原tomcat进程
        # sleep 3
        # rm -rf $TomcatCache # 清理tomcat缓存
        $StartTomcat
	fi
    else
    echo "[error]tomcat进程不存在!tomcat开始自动重启..."
    echo "[info]$StartTomcat,请稍候......"
    echo "[error]发送告警开启邮件"  
    #echo "由于$IP的tomcat进程不存在 tomcat开始自动重启 [$(date +'%F %H:%M:%S')]" | mail -s "魔售项目告警开启" $email_address
    rm -rf $TomcatCache
    $StartTomcat 
  fi
 echo "------------------------------"
}
Monitor>>$TomcatMonitorLog