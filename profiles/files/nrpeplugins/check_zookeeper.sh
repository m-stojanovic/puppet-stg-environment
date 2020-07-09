#!/bin/bash
#set -o nounset
#set -o errexit
#set -o pipefail

# returns 0 when zookeeper is happy

IP="127.0.0.1"
if [ -z $1 ];
then
  CLIENTPORT="2181"
else
  CLIENTPORT="$1"
fi;

RUOK=$(echo ruok | nc $IP $CLIENTPORT | grep "imok")
RET=$?

if [ "$RET" -ne 0 ]
then
  echo "Zookeeper is not OK, restart me" >&2
  exit 2
fi

ZROLE=$(echo stat | nc $IP $CLIENTPORT | grep Mode |grep 'leader\|follower')
RET=$?

if [ "$RET" -ne 0 ]
then
  echo "Zookeeper not part of quorum, restart me" >&2
  exit 2
fi

echo $ZROLE
exit 0
