

vagrant@folr-master ~/folr/ansible $ docker ps                                                                                                                                                                                                                 [ruby-2.1.5p273]
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                              NAMES
931b3f0e52a8        swarm               "/swarm manage -H :40"   2 hours ago         Up 2 hours          2375/tcp, 0.0.0.0:4000->4000/tcp   fervent_torvalds
996673b80ba8        progrium/consul     "/bin/start --bind 10"   2 hours ago         Up 2 hours                                             consul

vagrant@folr-master ~/folr/ansible $ node1 'docker ps'                                                                                                                                                                                                         [ruby-2.1.5p273]
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                              NAMES
ff793d73c38a        swarm               "/swarm manage -H :40"   2 hours ago         Up 2 hours          2375/tcp, 0.0.0.0:4000->4000/tcp   loving_franklin

vagrant@folr-master ~/folr/ansible $ node2 'docker ps'                                                                                                                                                                                                         [ruby-2.1.5p273]
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
2e6171504855        swarm               "/swarm join --advert"   About an hour ago   Up About an hour    2375/tcp            elated_hoover

vagrant@folr-master ~/folr/ansible $ node3 'docker ps'                                                                                                                                                                                                         [ruby-2.1.5p273]
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
9163a48315d4        swarm               "/swarm join --advert"   About an hour ago   Up About an hour    2375/tcp            adoring_galileo

vagrant@folr-master ~/folr/ansible $ docker -H :4000 ps                                                                                                                                                                                                        [ruby-2.1.5p273]
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES


vagrant@folr-master ~/folr/ansible $ docker -H :4000 info                                                                                                                                                                                                      [ruby-2.1.5p273]
Containers: 4
 Running: 2
 Paused: 0
 Stopped: 2
Images: 9
Server Version: swarm/1.2.3
Role: primary
Strategy: spread
Filters: health, port, containerslots, dependency, affinity, constraint
Nodes: 2
 folr-node2: 10.100.199.202:2375
  └ ID: 74HS:QKDP:ZNMX:3GMP:6JG7:3EUO:PIJP:ULLN:IZV3:5SXW:YWUP:JCUK
  └ Status: Healthy
  └ Containers: 2
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 2.061 GiB
  └ Labels: executiondriver=, kernelversion=3.16.0-4-amd64, operatingsystem=Debian GNU/Linux 8 (jessie), storagedriver=aufs
  └ UpdatedAt: 2016-07-29T06:29:35Z
  └ ServerVersion: 1.11.2
 folr-node3: 10.100.199.203:2375
  └ ID: VJZO:2UBL:MK6N:CIBF:FF5A:J3CJ:LFCE:ECCF:UQKK:LDL6:DVIA:5SEA
  └ Status: Healthy
  └ Containers: 2
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 2.061 GiB
  └ Labels: executiondriver=, kernelversion=3.16.0-4-amd64, operatingsystem=Debian GNU/Linux 8 (jessie), storagedriver=aufs
  └ UpdatedAt: 2016-07-29T06:30:11Z
  └ ServerVersion: 1.11.2
Plugins:
 Volume:
 Network:
Kernel Version: 3.16.0-4-amd64
Operating System: linux
Architecture: amd64
CPUs: 2
Total Memory: 4.123 GiB
Name: 931b3f0e52a8
Docker Root Dir:
Debug mode (client): false
Debug mode (server): false
WARNING: No kernel memory limit support



vagrant@folr-master ~/folr/ansible $ docker -H :4000 ps -a                                                                                                                                                                                                     [ruby-2.1.5p273]
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS                          PORTS               NAMES
4c0d6152802d        hello-world         "/hello"                 About a minute ago   Exited (0) About a minute ago                       folr-node3/happy_euclid
8d3e6e01d403        hello-world         "/hello"                 About a minute ago   Exited (0) About a minute ago                       folr-node2/pedantic_morse
9163a48315d4        swarm               "/swarm join --advert"   About an hour ago    Up About an hour                2375/tcp            folr-node3/adoring_galileo
2e6171504855        swarm               "/swarm join --advert"   2 hours ago          Up 2 hours                      2375/tcp            folr-node2/elated_hoover



vagrant@folr-master ~/folr/ansible $ docker -H :4000 run --name some-redis -d redis                                                                                                                                                                            [ruby-2.1.5p273]
93415ad886d469073ce7f4cfbb302e54f80b76003469443f9f281f1979586846
vagrant@folr-master ~/folr/ansible $ docker -H :4000 ps                                                                                                                                                                                                        [ruby-2.1.5p273]
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
93415ad886d4        redis               "docker-entrypoint.sh"   7 seconds ago       Up 7 seconds        6379/tcp            folr-node2/some-redis
vagrant@folr-master ~/folr/ansible $ docker -H :4000 ps -a                                                                                                                                                                                                     [ruby-2.1.5p273]
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                     PORTS               NAMES
93415ad886d4        redis               "docker-entrypoint.sh"   12 seconds ago      Up 11 seconds              6379/tcp            folr-node2/some-redis
4c0d6152802d        hello-world         "/hello"                 6 minutes ago       Exited (0) 6 minutes ago                       folr-node3/happy_euclid
8d3e6e01d403        hello-world         "/hello"                 6 minutes ago       Exited (0) 6 minutes ago                       folr-node2/pedantic_morse
9163a48315d4        swarm               "/swarm join --advert"   2 hours ago         Up 2 hours                 2375/tcp            folr-node3/adoring_galileo
2e6171504855        swarm               "/swarm join --advert"   2 hours ago         Up 2 hours                 2375/tcp            folr-node2/elated_hoover



docker run -d --name=registrator --net=host --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest consul://10.100.199.200:8500
    
    
    
    
      


ster ~/folr/ansible $ docker -H :4000 run --name some-redis -d redis                                                                                                                                                                            [ruby-2.1.5p273]
7a53747f8224274619dc704528f721292f5c530a74dc170ee0d5fe145dc02f3f
vagrant@folr-master ~/folr/ansible $ docker -H :4000 ps                                                                                                                                                                                                        [ruby-2.1.5p273]
CONTAINER ID        IMAGE                           COMMAND                  CREATED             STATUS              PORTS               NAMES
7a53747f8224        redis                           "docker-entrypoint.sh"   8 seconds ago       Up 8 seconds        6379/tcp            folr-node2/some-redis
287e4b417ab4        gliderlabs/registrator:latest   "/bin/registrator con"   13 minutes ago      Up 13 minutes                           folr-node3/registrator
7223e4692fb9        gliderlabs/registrator:latest   "/bin/registrator con"   13 minutes ago      Up 13 minutes                           folr-node2/registrator
vagrant@folr-master ~/folr/ansible $ pry -r diplomat                                                                                                                                                                                                           [ruby-2.1.5p273]
gem install awesome_print  # <-- highly recommended
2.1.5 (main):0 > Diplomat::Service.get_all
=> #<OpenStruct consul=[]>
2.1.5 (main):0 > Diplomat::Node.get_all
=> [#<OpenStruct Node="folr-master", Address="10.100.199.200">]



