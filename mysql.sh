#mysql正在running的线程数(排除了sleep的)
mysqlRunID=$(mysql -uagency -pagency -P3306 -BNe "select count(*)from information_schema.processlist where info is not null;")
echo "mysql正在running的线程数为$mysqlRunID"
#Mysql的全部线程
mysqlID=$(mysql -uagency -pagency -P3306 -BNe "select count(*)from information_schema.processlist;")
echo "mysql的全部线程数为$mysqlID"
#发送邮件地址
email_address=*****@qq.com
#当前服务器ip
IP=$(ifconfig -a|awk '/(cast)/ {print $2}'|cut -d':' -f2|head -1)
#日志输出
mysqlThreadLog=/tmp/mysqlThread.log

Monitor()
{
echo "[info]开始监控,mysql...[$(date +'%F %H:%M:%S')]"
 	# 这里判断mysql线程是否大于60
	if [ $mysqlID -gt 60 ] ; then
	 echo "[info]当前mysql的进程数为$mysqlID"
	 echo "[error]发送告警开启邮件"  
	 # | mail -s mail命令一定要有空格
	 echo "$IP的mysql线程数已经超过60，发送告警开启邮件 [$(date +'%F %H:%M:%S')],mysql的全部线程数为$mysqlID,mysql正在running的线程数为$mysqlRunID" | mail -s "魔售mysql报警开启" $email_address
	fi
	 echo "------------------------------"

}
Monitor>>$mysqlThreadLog

