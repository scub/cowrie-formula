{% if grains['id'].startswith('cowrie') %}

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

install_py_deps:
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

cowrie:
  user.present:
    - fullname: cowrie
    - home: /home/cowrie
    - empty_password: True
    - shell: /bin/bash

git clone http://github.com/micheloosterhof/cowrie /home/cowrie/cowrie:
  cmd.run:
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
    
iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222:
  cmd.run:
    - shell: /bin/bash

./start.sh:
  cmd.run:
    - user: cowrie
    - cwd: /home/cowrie/cowrie
    - shell: /bin/bash
    
{% elif grains['id'].startswith('mysql_cowrie') %}

mysql-server:
  pkg.installed

mysql-client:
  pkg.installed

cowrie_db:
  mysql_database.present:
    - name: cowrie

cowrie:
  mysql_user.present:
    - host: localhost
    - password: <MYSQL_PASSWORD>

cowrie_grants:
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
