include:
  - requirements
  - python

# Create the Python Virtual enviroment.
/virtual-env:
  virtualenv.managed:
    - no_site_packages: True
    - python: python2.7
    - requirements: /vagrant/requirements.txt
    - require:
      - pkg: requirements
      - cmd: install-python

# Make it so we automatically activate the virtualenv.
auto_venv:
  file.append:
    - name: /home/vagrant/.bashrc
    - text:
      - source /virtual-env/bin/activate
