requirements:
  pkg.installed:
    - names:
      - python-virtualenv
      - python-dev
      - libpq-dev
      - python-pip
      - build-essential
      - git
      - libxml2-dev  # Required for lxml
      - libxslt1-dev  # Required fol lxml
      - libncurses5-dev

# Make it so we automatically cd into /vagrant/
cd_vagrant:
  file.append:
    - name: /home/vagrant/.bashrc
    - text:
      - cd /vagrant/