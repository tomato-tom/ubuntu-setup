#!/bin/bash -e

# dockerイメージをlxcコンテナで使えるように
if ! incus remote list | grep -q 'https://docker.io'; then
    incus remote add docker https://docker.io --protocol=oci
fi

# nginxのdockerイメージをlxcコンテナでたてる
if ! incus list | grep -q 'my-nginx'; then
    incus launch docker:nginx my-nginx
fi

while ! incus list | grep -q my-nginx; do
    sleep 1
done
echo my-nginx running

# ubuntu 24.04 コンテナ起動 
if ! incus list | grep -q 'my-noble'; then
    incus launch images:ubuntu/noble my-noble
fi

while ! incus list | grep -q my-noble; do
    sleep 1
done
echo my-noble running

# nginxコンテナのIPアドレスを取得するまで待機
addr=""
while [ -z "$addr" ]; do
    echo "Waiting for IP address to be assigned to my-nginx..."
    addr=$(incus info my-nginx | grep -E 'inet:.*global' | cut -d ':' -f2 | cut -d'/' -f1)
    sleep 1  # 1秒待機
done

# ポート80で接続テスト
incus exec my-noble -- nc -zv $addr 80

# 終了時にコンテナを削除しますか？
echo "終了時にコンテナを削除しますか？(y/n): "
read input

if [ "$input" == 'y' ] || [ -z "$input" ]; then
    incus stop my-noble
    incus delete my-noble
    incus stop my-nginx
    incus delete my-nginx
fi
