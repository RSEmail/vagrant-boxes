# Vagrant Boxes #

Hey, it's some Vagrant boxes! Isn't that nifty?!

These configs originated from [Veewee](https://github.com/jedi4ever/veewee/)
and have been customized in some ways.

## Getting Set Up ##

Use and/or modification of these boxes requires Veewee, which requires
Vagrant, which requires Virtualbox.

* Install Virtualbox from their
[site](https://www.virtualbox.org/wiki/Downloads)
* Install Vagrant from the download link on their [site](http://vagrantup.com/)
* Install [Veewee](https://github.com/jedi4ever/veewee/)
  * gem install veewee
* You're all set!

## Customized Boxes ##

* centos6 - Points to the latest revision of CentOS6, if you don't want to
worry about updating your Vagrantfiles for minor version increments
* centos63-x86_64-512 - The same as CentOS 6.2 below
* centos62-x86_64-512 - Customized version of the CentOS-6.2-x86_64-minimal
template
** Upsize disk to 20GB
** Install Chef via Opscode's Omnibus Installer rather than a Gem
