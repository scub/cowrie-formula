{% if grains['id'].startswith('honeypot') %}

git:
  pkg.installed

virtualenv:
  pkg.installed

libmpfr-dev:
  pkg.installed

libssl-dev:
  pkg.installed

libmpc-dev:
  pkg.installed

libffi-dev:
  pkg.installed

build-essential:
  pkg.installed

libpython-dev:
  pkg.installed

python2.7-minimal:
  pkg.installed

libmysqlclient-dev:
  pkg.installed
  
python-pip:
  pkg.installed
  
pip_upgrade:
  pip.installed:
    - name: pip
    - upgrade: True
    
py_deps:
  pip.installed:
    - names:
      - twisted >= 15.2.1
      - cryptography
      - configparser
      - pyopenssl
      - gmpy2
      - service_identity
      - pycrypto
      - python-dateutil
      - tftpy
      - csirtgsdk
      - mysql-python
    - upgrade: True

cowrie_user:
  user.present:
    - fullname: cowrie
    - home: /home/cowrie
    - empty_password: True
    - shell: /bin/bash

clone_cowrie:
  git.latest:
    - name: https://github.com/micheloosterhof/cowrie.git
    - branch: master
    - target: /home/cowrie/cowrie
    - user: cowrie
 
ssh-keygen -t dsa -b 1024 -f ssh_host_dsa_key:
  cmd.run:
    - user: cowrie
    - cwd: /home/cowrie/cowrie/data
    - shell: /bin/bash

/home/cowrie/cowrie/cowrie.cfg:
  file.managed:
    - user: cowrie
    - group: cowrie
    - mode: 644
    - source: salt://cowrie/files/cowrie.cfg
  
/home/cowrie/cowrie/data/userdb.txt:
  file.managed:
    - user: cowrie
    - group: cowrie
    - mode: 644
    - source: salt://cowrie/files/userdb.txt
    
/etc/ssh/sshd_config:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://cowrie/files/sshd_config
    
forward_ssh:
  iptables.append:
    - table: nat
    - chain: PREROUTING
    - jump: REDIRECT
    - proto: tcp
    - dport: 22
    - sport: 2222
    - save: true

./start.sh:
  cmd.run:
    - user: cowrie
    - cwd: /home/cowrie/cowrie
    - shell: /bin/bash
    
{% elif grains['id'].startswith('database') %}

mysql-server:
  pkg.installed

mysql-client:
  pkg.installed

cowrie_database:
  mysql_database.present:
    - name: cowrie

cowrie_database_user:
  mysql_user.present:
    - name: cowrie
    - host: localhost
    - password: <MYSQL_PASSWORD>

cowrie_database_grants:
  mysql_grants.present:
    - grant: all privileges
    - database: cowrie.*
    - user: cowrie

/root/mysql.sql:
  file.managed:
    - source: salt://cowrie/files/mysql.sql
 
mysql -u cowrie --password=<MYSQL_PASSWORD> cowrie < /root/mysql.sql:
  cmd.run:
    - shell: /bin/bash

{% endif %}
