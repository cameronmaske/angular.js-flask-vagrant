nodejs:
  pkgrepo.managed:
    - ppa: "chris-lea/node.js"
    - require_in:
        - pkg: nodejs
  pkg:
    - latest

npm:
  pkg.installed:
    - require:
        - pkg: nodejs

npm-global:
  npm.installed:
    - names:
      - grunt-cli
      - karma
    - require:
      - pkg: npm

package-json:
  npm.installed:
    - dir: /vagrant/
    - require:
      - pkg: npm
