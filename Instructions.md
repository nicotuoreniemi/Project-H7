# Instructions

All you need to use this setup is 2 computers, either real ones or virtual machines like Vagrant. If you decide to go with virtual machine as your Salt-master, you also need to setup a static IP for it so that the minions always find it.

For the computer that is going to be the master, you need to download [Salt-master](https://repo.saltproject.io/#debian) to it. For the minions you need to download [Salt-minion](https://repo.saltproject.io/). If you only want to test this out, you can use the scripts provided to create a Vagrant machineas a minion. Salt provides great documentation on how to setup a Salt environment.

After configuring a Salt-master and the minions, you can just download my files to your /srv/salt/ directory and you are ready to go.
