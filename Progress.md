# Progress in the project

So, for my project there is a fictional small company that has a problem managing all of their computers. In my project, I'm going to solve that using Salt. Every computer will be managed from a master computer using Salt-states. The computers will be set up with company decided default programs and configurations. This way the set up will be near automatic and done with one command.

Since it's a fictional problem, I'm going to simulate a small company myself using virtual machines with vagrant. I'll start the whole thing with an empty virtual Linux.

First of all I'm going to make everything manually and test that everything works. After that I'm going start with the automation of it. So for now, I've got a fresh Debian and I'll start with installing everything thats needed and configuring the programs. Update after hours of troubleshooting --> I legit battled with getting vagrant and a new virtual Debian working but after 4 or more hours, I could not solve it. So for now I'm actually starting with a real PC that has Debian 11 running on it.

I setup the with "debian-live-11.2.0-amd64-xfce+nonfree.iso" that was put on an USB stick. After that I installed the OS normally and everything went fine. After that I installed a few programs like SSH, Vagrant and Virtualbox. Virtualbox was not available in the Debian repo so I had to go with their instructions that were on their site. (https://wiki.debian.org/VirtualBox). Next, I took the Vagrantfile from [Tero's](https://terokarvinen.com/2021/two-machine-virtual-network-with-debian-11-bullseye-and-vagrant/) article about Vagrant and two machines. That way the Vagrant machines popped up normally without any problems. Next up was putting the the master machine itself to the way it should be manually.

However, when I tried to set the vagrantfile with a static IP, no matter what I put in as a static IP the creating of the virtual machines is stopped. So now, as this is kind of the same problem as before I'm going to simulate the project without Vagrant and actually using the master laptop and a virtual linux with my desktop PC.


So at the start I was not sure about what programs should be installed. Now I've decided on Git, SSH, Apache2, Micro, Nano and Flameshot. Now I'll install and configure them automatically before making each of them a Salt-state. UPDATE 16.5 for the programs that will be installed, I'll add important tools curl and wget.


## Installing Apache manually
First I went with Apache. I installed it with "sudo apt-get install apache2" and started of with changing the default homepage in Apache. That is done by changing the file /var/www/html/index.html. After that I enabled user directories as well as changed my own homepage. Changing the users homepage is done by creating /public_html/index.html file.

![Apache](https://i.imgur.com/pgfLGwb.png)

Older picture, realised it didn't contain enough info: https://i.imgur.com/2iMnnH1.pn

![userdir](https://i.imgur.com/uX4Pou9.png)


Now I should move on to automating it all with a Salt-state. Obviously I need to install Salt-master first which is done by "sudo apt-get install salt-master".

### UPDATE ABOUT VAGRANT 16.5
So with changing the Vagrantfile from Tero's to my classmate Jami's one. I got it all running in a way that boots 4 Vagrant machines up and automatically updates them and installs Salt-minion and connects it to the master. All credits from this go to Jami Lohilahti and his configuration. I would link the article but its password-protected. I'll share the few scripts used with the automation process. Everything with Vagrant works now so I'm easily able to simulate 1 master PC and 4 minions. 

The first script is used incase you want to set up one of your Vagrant machines as the Salt-master.

		#!/bin/bash
		
		apt-get -y install salt-master
		
		mkdir -p /srv/salt

The other one is used to setup the minions automatically and configure the /etc/salt/minion file.

		#!/bin/bash
		
		apt-get -y install salt-minion
		
		echo "master: 192.168.1.9" >> /etc/salt/minion
		echo "id: $(hostname)" >> /etc/salt/minion
		
		systemctl restart salt-minion.service
		
The last one is the prov.sh which automatically updates the Vagrant machines.

		#!/bin/bash
		
		apt-get update
		


#### Making Apache installation a Salt-state

First, I need to create a directory /srv/salt. This is where all the states will have their own folders. For Apache, I'm creating a directory called /srv/salt/apache. In there I need an init.sls file which tells what the state actually does. I'll also need the configuration files wich will be used to overwrite the slaves default configurations.

![init.sls](https://i.imgur.com/2fl4LdQ.png)



After this, I'll copy my already manually configured and tested file in there aswell. Now I'll test the file on slave vg04. It seems that atleast the files are being changed as they are supposed to.

![vg04](https://i.imgur.com/dYq0coJ.png)

I accidentally ran the state on all the minions. After that I tried to run it again only on vg04 and nothing changed so the state works.

![state](https://i.imgur.com/1cIHZN5.png)


##### Installing Git

So I've actually installed git for the master so that I'm able to write this while doing the project. Just like with Apache, first I'll create the folder for Git in /srv/salt. In there I need the init.sls file aswell. Right now I'm not going to do any configurations for Git so it will just be a simple pkg.installed inside the init.slsI'll just test the state with 'vg03' this time.

![vg03](https://i.imgur.com/q6ONOw8.png)

###### Installing and configuring Nano

Just like Git, I've got Nano already installed on the master. Now I just need to configure it to my liking. The default configuration file is in /etc/nanorc. In there I switched a few things like put on linenumber and automatic backups on. Now I need to automate it with salt. I'll create a directory /srv/salt/nano. In there I need the init.sls and also the configuration file from /etc/nanorc.

![nano](https://i.imgur.com/1IwpCtD.png)

Again, I'll test it on minion vg03.

![nanotest](https://i.imgur.com/3nsStAv.png)

Everything seems to be working.

####### Installing and configuring SSH

Like the others, I've manually already installed SSH but not configured it. I'll change the configuration to default to a different port than 22. First I'll go and change the configuration file in /etc/ssh/sshd_config. I changed it to port 5431. Then I tested that it worked on the master as it should.

![master](https://i.imgur.com/EHfbtFC.png)

Next up, I needed to create a directory for the state. Like the others, its /srv/salt/ssh. In there I need an init.sls file and the already configurated file sshd_config.

![state](https://i.imgur.com/Ru2vETT.png)

I'll test this one with the minion vg03 aswell. After this I noticed that obviously changing SSH configuration has an effect on me being able to use SSH with Vagrant. I'll be able to focus more on it later but for now, I'll change the port back to the default one. I had already applied the state with the wrong number so I needed to apply the state again after making changes to the configuration. However to use my setup with any of the ports wanted for SSH, only that number will need to be changed in the configuration file.


######## Installing Flameshot and configuring it

This is getting kind of old but I already installed Flameshot to take screenshots for this report. Now I'll manually configure it and after that I'll automate it all with Salt. With flameshot, the configuration file is a bit different since it's always in the users home directory(~/.config/flameshot/flameshot.ini). I changed the program to always start when the pc is started up and changed a custom savepath ~/Flameshot SS.

![flameshot](https://i.imgur.com/Ru2vETT.png)

I tested applying the state but there seems to be a problem with the configuration since the configuration file itself is in the home directory. I'll comeback to this later.

![flame](https://i.imgur.com/3SIHTrY.png)

######## Installing Micro, Wget and Curl

Same old story, I've already installed Micro but I have not configured it at all. It's in the same place as Flameshots configuration file, in ~/.config directory. Because of this I'm not sure how to apply the changes for each minion with Salt. 

Anyway, I'm going to make a Salt state that installs Micro, Wget and Curl, but I'm going to look into the Micro configuration later if I have the time. I'll create the /srv/salt/triple directory and list them all under pkg.installed.

After trying the state on vg03, everything else worked except installing Micro. I suspect that this is due to some changes I had to do while testing out different programs and repositories on this master pc.

![micro](https://i.imgur.com/CmbjbxA.png)


######## Some additional things

I decided that since its a company I'm simulating, it would be nice that they have the same desktop wallpaper on them. For this I figured I could use a program called xwallpaper to automate it. I tried it out but no luck, nothing seemed to change with it, no matter what I did. So I unfortunately didn't find a way to automate this.

I was also interested in configuring filesharing from the master to the minions. After looking around official Salt documents I found out that you can copy any files from the master to the minions with a single command. In my mind that was actually enough as the master is able to copy whatever they want on to the minions computer. The command used for this is "salt-cp '*' [ options ] SOURCE [SOURCE2 SOURCE3 ...] DEST".

######## Setting up UFW for and making a Salt-state for it

Since I'm simulatin a business, I guess it would be smart to have a firewall. I'll start by installing it manually and making a few configurations to it. First, I allowed a few ports with the command "sudo ufw allow portnumber". I used 80, 22, and 443. These are for SSH and Apache2.

![ufw](https://i.imgur.com/Umq9JIF.png)

Now I'll need to make the Salt-state. I started by creating directory for UFW called /srv/salt/ufw. In there I would need the init.sls and three separate configuration files that UFW uses. Those files are in /etc/ufw and they are user.rules, user6.rules and ufw.conf. I made the same files in the /srv/salt/ufw folder.

![ufw](https://i.imgur.com/a4nicfN.png)

Now I started to run to some error with my Vagrant machines so I decided to destroy them and create new ones. I'll test the UFW state on the vg01 machine.

![testii](https://i.imgur.com/DyL01RJ.png)




######### Finishing up

So now, it all is starting to be ready. I have configured states for Apache, Flameshot, Git, Nano, UFW, SSH, Micro, Wget and Curl. Now I just need to create top.sls file in the /srv/salt directory that tells which states will be applied with it. In the top.sls I put in all the states I have created while doing this project.

![top.sls](https://i.imgur.com/y9ZoKSs.png)

So, I had my 4 Vagrant minions all up and running and I applied the top.sls. Everything went as expected since I wrote earlier that I did not know how to configure Flameshot since it's configuration file is in the users home directory. That was the only thing that failed with the top.sls state.



![finished](https://i.imgur.com/u8jRof8.png)




I'll continue to report on the progress of the project when I get more of a start with it.
