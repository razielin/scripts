#!/usr/bin/env bash

docker run --name elasticsearch --network elastic --rm -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:6.4.1

docker run -ti --name kibana --network elastic --rm -p 5601:5601 docker.elastic.co/kibana/kibana:6.4.1

docker run -ti --name metricbeat --rm --mount type=bind,source=/proc,target=/hostfs/proc,readonly --mount type=bind,source=/sys/fs/cgroup,target=/hostfs/sys/fs/cgroup,readonly --mount type=bind,source=/,target=/hostfs,readonly --network elastic docker.elastic.co/beats/metricbeat:6.4.1 -system.hostfs=/hostfs


