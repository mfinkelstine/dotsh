function jbclient(){
  ps aux | grep "RemoteDev"
}

function jbclientkill(){
  p=`ps aux | grep -v grep | grep "RemoteDev" | awk '{print $2}'`; 
  for pid in $p; do 
    kill -9 $pid; 
  done
}

