#!/bin/bash

set -e

registry_path="registry.cn-hangzhou.aliyuncs.com"
repository_path="${registry_path}/zhiliangyun/spc2022"

repoPwd=$1
version=$2
macAddr=$3

if [ -z "$version" ]; then
	echo "����ȱʧ, ������Ҫ�����İ汾�ţ�"
	exit 1
fi
#���Ѵ����������л�ȡmacAddr
if [ -z "$macAddr" ]; then
	macAddr=`docker ps -a | awk -F ' ' '{if($2~/spc/) print $1}' | xargs -I {} docker inspect -f '{{.Config.MacAddress}}' {}`
	echo "get macAddr from container: $macAddr"
fi

if [ -z "$macAddr" ]; then
	echo "����ȱʧ, �����������Ӧ��MAC��ַ��"
	exit 1
fi


docker login --username=zhanlizhen123 --password=$repoPwd registry.cn-hangzhou.aliyuncs.com 


docker pull registry.cn-hangzhou.aliyuncs.com/zhiliangyun/spc2022:$version



old_container=`docker ps -a | awk -F ' ' '{if($2~/spc/) print $1}'`
echo "��ǰ���е�container id: ${old_container}"

if [ -n "${old_container}" ]; then
	docker stop ${old_container}
	echo  "${old_container} has stoped!"
fi

echo ""


echo "��ʼ��������...."

container_name="spc_$version"

docker run -e LANG=C.UTF-8 --name=$container_name --privileged --restart=always -it -d -p 80:80 -p 5432:5432 -p 8095:8095 -p 6379:6379 --mac-address $macAddr $repository_path:$version /root/spc.sh

docker rm ${old_container}

