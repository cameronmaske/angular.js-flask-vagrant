# Downloads, extracts and install redis.

{% set version = '2.6.14' -%}

include:
    - requirements

# Get and extract redis.
get-redis:
    file.managed:
        - name: /usr/local/redis-{{ version }}.tar.gz
        - source: http://redis.googlecode.com/files/redis-{{ version }}.tar.gz
        - source_hash: sha1=f56a5d4891e94ebd89f7e63c3e9151d1106dedd5
        - require:
            - pkg: requirements
    cmd.wait:
        - cwd: /usr/local
        - names:
            - tar -zxvf /usr/local/redis-{{ version }}.tar.gz -C /usr/local
        - watch:
            - file: get-redis

# Make redis and ensure is running.
make-redis:
    cmd.wait:
        - cwd: /usr/local/redis-{{ version }}
        - names:
            - make
            - make install
        - watch:
            - cmd: get-redis