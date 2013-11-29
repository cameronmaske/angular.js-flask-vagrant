An AngularJS clientside with Flask server boilerplate all on top of Vagrant.

To setup Vagrant, the only requirement is VirtualBox. You can (download it here)[https://www.virtualbox.org/wiki/Downloads].

Once VirtualBox is installed, go ahead and download and setup (Vagrant 1.2.7)[http://downloads.vagrantup.com/tags/v1.2.7]

[SaltStack](https://github.com/saltstack/salty-vagrant) (An infrastructure management tool written in Python) is used with Vagrant to configure
the VM with all the required dependancies.
To allow Vagrant to use it as it's provisoner run...

    vagrant plugin install vagrant-salt

Next, let's setup our virtual machine. Run the following command

    vagrant up

You may need to sudo in. Once that is done, co grab a tea/coffee. This process may take a while (5 minutes +). Once done, you can ssh into the VM using.

    vagrant ssh

From there you can run the server with

    python server/web.py

And start grunt with

    grunt watch


### Todo!

* Setup Fabric
* Procfile + Heroku integration.
* Improve README.
* Use bower.
* Clean up bootstrap.
* Add in test structure.
* Setup basic user + DB.
* Clean package.json + requirements.