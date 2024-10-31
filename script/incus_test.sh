#!/bin/bash -e

# dockerイメージをlxcコンテナで使えるように
incus remote add docker https://docker.io --protocol=oci
incus remote list

# nginxのdockerイメージをlxcコンテナでたてる
incus launch docker:nginx my-nginx

# ubuntu 24.04 コンテナ起動 
incus launch images:ubuntu/noble my-noble

# nobleコンテナからnginxコンテナ
incus exec my-noble -- ping my-nginx -c 3
