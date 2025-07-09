out=/run/report
function backend_addr() {
  rm -f $out
  kill -RTMAX-14 $(pidof aoe)
  sleep 0.5
  cat $out|tr -d "\0"
}
function push() {
  filename=$(basename "$1")
  cat $1 | ssh root@$(backend_addr) "cat > $filename"
}
function pull() {
  filename=$(basename "$1")
  ssh root@$(backend_addr) "cat $1" > $filename
}
function lsaoe() {
  if [ `systemctl is-active vsound` = "inactive" ];then
    echo "vsound service is not running"
  else
    rm -f $out
    kill -USR1 $(pidof aoe)
    sleep 0.7
    if [ ! -e $out ];then
      echo "No response" > $out
    fi
    cat $out
  fi
}
function aoestat() {
  if [ `systemctl is-active vsound` = "inactive" ];then
    echo "vsound service is not running"
  else
    rm -f $out
    kill -USR2 $(pidof aoe)
    sleep 0.5
    if [ ! -e $out ];then
      echo "No response" > $out
    fi
    head -n8 $out
  fi
}
function getlog() {
  ssh root@$(backend_addr) "cd /var/log;/sbin/ifconfig>ifconfig.log;cat /sys/kernel/aoe_vital>vital.log;dmesg>dmesg.log;cat /proc/cpuinfo>cpuinfo.log;cd /var;tar cf aoelog.tar log;cat aoelog.tar" > aoelog.tar
  journalctl -u vsound > front_vsound.log
  lsaoe > front_lsaoe.log
  uname -a > front_uname.log
  ip -s address > front_ip.log
  tar -rf aoelog.tar --remove-files front_vsound.log front_lsaoe.log front_uname.log front_ip.log
  gzip aoelog.tar
  if [ -e ./aoelog.tar.gz ];then
    echo "ログファイルを取得しました。putlogコマンドでアップロードしてください。"
  else
    echo "ログファイルを取得できませんでした。"
  fi
}
function putlog() {
  read -p "ログファイルをアップロードします。よろしいですか？ (y/n): " response
  if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
    if [ -e ./aoelog.tar.gz ];then
      curl -F "file=@aoelog.tar.gz" https://www.symphonic-mpd.com/logbox/
    else
      echo "ログファイル(aoelog.tar.gz)がありません。処理を中断しました。"
    fi
  elif [ "$response" = "n" ] || [ "$response" = "N" ]; then
    echo "処理を中止しました。"
  else
    echo "無効な入力です。処理を中断しました。"
  fi

}
alias aoereset='kill -RTMIN $(pidof aoe)'
alias aoesshon='kill -RTMAX-14 $(pidof aoe)'
alias aoesshoff='kill -RTMAX-13 $(pidof aoe)'
alias aoepoweroff='kill -RTMAX-12 $(pidof aoe)'
alias aoereboot='kill -RTMAX-11 $(pidof aoe)'

