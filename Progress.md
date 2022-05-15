#Progress in the project

So, for my project there is a fictional small company that has a problem managing all of their computers. In my project, I'm going to solve that using Salt. Every computer will be managed from a master computer using Salt-states. The computers will be set up with company decided default programs and configurations. This way the set up will be near automatic and done with one command.

Since it's a fictional problem, I'm going to simulate a small company myself using virtual machines with vagrant. I'll start the whole thing with an empty virtual Linux.

First of all I'm going to make everything manually and test that everything works. After that I'm going start with the automation of it. So for now, I've got a fresh Debian and I'll start with installing everything thats needed and configuring the programs. So for an update, I legit battled with getting vagrant and a new virtual Debian working but after 4 or more hours, I could not solve it. So for now I'm actually starting with a real PC that has Debian 11 running on it.

I setup the with "debian-live-11.2.0-amd64-xfce+nonfree.iso" that was put on an USB stick. After that I installed the OS normally and everything went fine. After that I installed a few programs like SSH, Vagrant and Virtualbox. Virtualbox was not available in the Debian repo so I had to go with their instructions that were on their site. (https://wiki.debian.org/VirtualBox). Next, I took the Vagrantfile from [Tero's](https://terokarvinen.com/2021/two-machine-virtual-network-with-debian-11-bullseye-and-vagrant/) article about Vagrant and two machines. That way the Vagrant machines popped up normally without any problems. Next up was putting the the master machine itself to the way it should be manually.

However, when I tried to set the vagrantfile with a static IP, no matter what I put in as a static IP the creating of the virtual machines is stopped. So now, as this is kind of the same problem as before I'm going to simulate the project without Vagrant and actually using the master laptop and a virtual linux with my desktop PC.

So at the start I was not sure about what programs should be default installed. Now I've decided on Git, SSH, Apache2, Micro, Nano and Flameshot. Now I'll install and configure them automatically before making each of them a Salt-state.

First I went with Apache. I installed it with "sudo apt-get install apache2" and started of with changing the default homepage in Apache. 

![Apache](https://i.imgur.com/2iMnnH1.png)



I'll continue to report on the progress of the project when I get more of a start with it.
