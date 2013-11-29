# Download the PhantomJS tarball
phantomjs:
  file.managed:
    - name: /tmp/phantomjs-1.9.2-linux-x86_64.tar.bz2
    - source: https://phantomjs.googlecode.com/files/phantomjs-1.9.2-linux-x86_64.tar.bz2
    - source_hash: sha1=c78c4037d98fa893e66fc516214499c58228d2f9

# Extract it
extract-phantomjs:
  cmd:
    - cwd: /tmp/
    - names:
      - tar -xvf phantomjs-1.9.2-linux-x86_64.tar.bz2 -C /usr/local/share
    - wait
    - watch:
      - file: phantomjs
    - require:
      - file: phantomjs

symlink-phantomjs:
  file.symlink:
    - names:
      - /usr/local/share/phantomjs
      - /usr/local/bin/phantomjs
      - /usr/bin/phantomjs
    - target: /usr/local/share/phantomjs-1.9.2-linux-x86_64/bin/phantomjs
    - require:
      - cmd: extract-phantomjs