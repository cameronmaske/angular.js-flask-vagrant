# Setup redis to auto-start when the server starts.
include:
    - redis.install

# Ensure the upstart script is preset.
redis-init-script:
    file.managed:
        - name: /etc/init/redis-server.conf
        - template: jinja
        - source: salt://redis/files/upstart.conf.jinja
        - mode: 0750
        - user: root
        - group: root
        - context:
                conf: /etc/redis/redis.conf
                user: root
        - require:
            - file: get-redis

# Disable the old init.d script.
redis-old-init-disable:
    cmd:
        - wait
        - name: update-rc.d redis-server remove
        - watch:
            - file: redis-init-script

# Ensure a directory is present for redis
redis-pid-dir:
    file.directory:
        - name: /var/db/redis
        - mode: 755
        - user: root
        - group: root
        - makedirs: True

# Ensure a log directory is present.
redis-log-dir:
    file.directory:
        - name: /var/log/redis
        - mode: 755
        - user: root
        - group: root
        - makedirs: True


# Ensure a log file is present.
redis-log-file:
    file.touch:
        - name: /var/log/redis
        - mode: 644
        - user: root
        - group: root
        - require:
            - file: redis-log-dir


# Ensure init.d script has been replace with our new fancy conf.upstart
redis-server:
    file:
        - name: /etc/redis/redis.conf
        - managed
        - template: jinja
        - source: salt://redis/files/redis.conf.jinja
        - require:
            - file: redis-init-script
            - cmd: redis-old-init-disable
            - file: redis-pid-dir
    service:
        - running
        - require:
            - file: redis-init-script
            - cmd: redis-old-init-disable
            - file: redis-server