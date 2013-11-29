ruby1.9.3:
  pkg:
    - installed

gems:
  gem.installed:
    - names:
      - foreman
      - sass
    - require:
      - pkg: ruby1.9.3