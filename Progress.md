# Progress in the project

So, for my project there is a fictional small company that has a problem managing all of their computers. In my project, I'm going to solve that using Salt. Every computer will be managed from a master computer using Salt-states. The computers will be set up with company decided default programs and configurations. This way the set up will be near automatic and done with one command.

Since it's a fictional problem, I'm going to simulate a small company myself using virtual machines with Vagrant. I'll start the whole thing with an empty virtual Linux.

First of all I'm going to make everything manually and test that everything works. After that I'm going start with the automation of it. So for now, I've got a fresh Debian and I'll start with installing everything thats needed and configuring the programs. Update after hours of troubleshooting --> I legit battled with getting Vagrant and a new virtual Debian working but after 4 or more hours, I could not solve it. So for now I'm actually starting with a real PC that has Debian 11 running on it. Its an old laptop with 8GB of RAM and an Intel i7 processor.

I setup the with "debian-live-11.2.0-amd64-xfce+nonfree.iso" that was put on an USB stick. After that I installed the OS normally and everything went fine. After that I installed a few programs like SSH, Vagrant and Virtualbox. Virtualbox was not available in the Debian repo so I had to go with their instructions that were on their [site](https://wiki.debian.org/VirtualBox). Next, I took the Vagrantfile from Jami Lohilahti's homework on Vagrant and multiple machines. Next up was putting the the master machine itself to the way it should be manually.

However, when I tried to set the Vagrantfile with a static IP, no matter what I put in as a static IP the creating of the virtual machines is stopped. Later I realised that I don't even need a static IP for the minions, only the Salt-master needs an IP that is known to the minions. So all in all my earlier struggles were actually pointless, had I only realised the IP thing earlier.

I got it all running in a way that boots 4 Vagrant machines up and automatically updates them and installs Salt-minion and connects it to the master. All credits from this go to Jami Lohilahti and his configuration. I would link the article but its password-protected. I'll share the few scripts used with the automation process. Everything with Vagrant works now so I'm easily able to simulate 1 master PC and 4 minions. I'll put the scipts as well as the vagrantfile used under this. Those are all you need to automate Vagrant machines setting up as minions.

The vagrantfile looks like this.

		Vagrant.configure("2") do |config|
		  config.vm.synced_folder ".", "/vagrant", disabled: true
		  config.vm.synced_folder "shared/", "/home/vagrant/shared", create: true
		  config.vm.provision "shell", path: "prov.sh"
		 
		  config.vm.box = "debian/bullseye64"
		 
		 
		  # Pakota pienet resurssit
		  config.vm.provider "virtualbox" do |vb|
		    vb.memory = 1024
		    vb.cpus = 1
		  end
		 
		  # Master
		  config.vm.define "vg01" do |vg01|
		    vg01.vm.hostname = "vg01"
		      # Saltin master-asennus
		    # Saltin minion-asennus
		    vg01.vm.provision "shell", path: "salt-minion.sh"
		  end
		 
		  # Minion 1
		  config.vm.define "vg02" do |vg02|
		    vg02.vm.hostname = "vg02"
		    # Saltin minion-asennus
		    vg02.vm.provision "shell", path: "salt-minion.sh"
		  end
		 
		  # Minion 2
		  config.vm.define "vg03" do |vg03|
		    vg03.vm.hostname = "vg03"
		    # Saltin minion-asennus
		    vg03.vm.provision "shell", path: "salt-minion.sh"
		  end
		 
		  # Minion 3
		  config.vm.define "vg04" do |vg04|
		    vg04.vm.hostname = "vg04"
		    # Saltin minion-asennus
		    vg04.vm.provision "shell", path: "salt-minion.sh"
		  end
		 
		end
		

The first script(salt-master.sh) is used in case you want to set up one of your Vagrant machines as the Salt-master.

		#!/bin/bash
		
		apt-get -y install salt-master
		
		mkdir -p /srv/salt

The other one(salt-minion.sh) is used to setup the minions automatically and configure the /etc/salt/minion file.

		#!/bin/bash
		
		apt-get -y install salt-minion
		
		echo "master: 192.168.1.9" >> /etc/salt/minion
		echo "id: $(hostname)" >> /etc/salt/minion
		
		systemctl restart salt-minion.service
		
The last one is the prov.sh which automatically updates the Vagrant machines.

		#!/bin/bash
		
		apt-get update
		

So at the start I was not sure about what programs should be installed. Now I've decided on Git, SSH, Apache2, Micro, Nano and Flameshot. Now I'll install and configure them automatically before making each of them a Salt-state. UPDATE 16.5 for the programs that will be installed, I'll add important tools curl and wget.


## Installing Apache manually

First I went with Apache. I installed it with "sudo apt-get install apache2" and started of with changing the default homepage in Apache. That is done by changing the file /var/www/html/index.html. After that I enabled user directories as well as changed my own homepage. Changing the users homepage is done by creating /public_html/index.html file.

![Apache](https://i.imgur.com/pgfLGwb.png)

Older picture, realised it didn't contain enough info: https://i.imgur.com/2iMnnH1.png

![userdir](https://i.imgur.com/uX4Pou9.png)


Now I should move on to automating it all with a Salt-state. Obviously I need to install Salt-master first which is done by "sudo apt-get install salt-master".

#### Making Apache installation a Salt-state

First, I need to create a directory /srv/salt. This is where all the states will have their own folders. For Apache, I'm creating a directory called /srv/salt/apache. In there I need an init.sls file which tells what the state actually does. I'll also need the configuration files wich will be used to overwrite the slaves default configurations.

![init.sls](https://i.imgur.com/2fl4LdQ.png)

In the above picture is the init.sls for Apache2. First it configures that apache2 package, then it copies my updated index.html file from the salt-master to the minions /var/www/html/ directory. After that it enables the user specific homepages and finally it restarts the service.


After this, I'll copy my already manually configured and tested file in there aswell. Now I'll test the file on slave vg04. It seems that atleast the files are being changed as they are supposed to.

![vg04](https://i.imgur.com/dYq0coJ.png)

I accidentally ran the state on all the minions. After that I tried to run it again only on vg04 and nothing changed so the state works.

![state](https://i.imgur.com/1cIHZN5.png)


### Installing Git

So I've actually installed git for the master so that I'm able to write this while doing the project. Just like with Apache, first I'll create the folder for Git in /srv/salt. In there I need the init.sls file aswell. Right now I'm not going to do any configurations for Git so it will just be a simple pkg.installed inside the init.sls. I'll just test the state with 'vg03' this time.

![vg03](https://i.imgur.com/q6ONOw8.png)

### Installing and configuring Nano

Just like Git, I've got Nano already installed on the master. Now I just need to configure it to my liking. The default configuration file is in /etc/nanorc. In there I switched a few things like put on linenumbers and automatic backups. Now I need to automate it with salt. I'll create a directory /srv/salt/nano. In there I need the init.sls and also the configuration file from /etc/nanorc.

![nano](https://i.imgur.com/1IwpCtD.png)

Again, I'll test it on minion vg03.

![nanotest](https://i.imgur.com/3nsStAv.png)

Everything seems to be working.

### Installing and configuring SSH

Like the others, I've manually already installed SSH but not configured it. I'll change the configuration to default to a different port than 22. First I'll go and change the configuration file in /etc/ssh/sshd_config. I changed it to port 5431. Then I tested that it worked on the master as it should.

![master](https://i.imgur.com/EHfbtFC.png)

Next up, I needed to create a directory for the state. Like the others, its /srv/salt/ssh. In there I need an init.sls file and the already configurated file sshd_config.

![state](https://i.imgur.com/Ru2vETT.png)

I'll test this one with the minion vg03 aswell. After this I noticed that obviously changing SSH configuration has an effect on me being able to use SSH with Vagrant. I'll be able to focus more on it later but for now, I'll change the port back to the default one. I had already applied the state with the wrong number so I needed to apply the state again after making changes to the configuration. However to use my setup with any of the ports wanted for SSH, only that number will need to be changed in the configuration file.


### Installing Flameshot and configuring it

This is getting kind of old but I already installed Flameshot to take screenshots for this report. Now I'll manually configure it and after that I'll automate it all with Salt. With flameshot, the configuration file is a bit different since it's always in the users home directory(~/.config/flameshot/flameshot.ini). I changed the program to always start when the pc is started up and changed a custom savepath ~/Flameshot SS.

![flameshot](https://i.imgur.com/inTI1v0.png)

I tested applying the state but there seems to be a problem with the configuration since the configuration file itself is in the home directory. I'll comeback to this later.

![flame](https://i.imgur.com/3SIHTrY.png)

### Installing Micro, Wget and Curl

Same old story, I've already installed Micro but I have not configured it at all. It's in the same place as Flameshots configuration file, in ~/.config directory. Because of this I'm not sure how to apply the changes for each minion with Salt. 

Anyway, I'm going to make a Salt state that installs Micro, Wget and Curl, but I'm going to look into the Micro configuration later if I have the time. I'll create the /srv/salt/triple directory and list them all under pkg.installed.

After trying the state on vg03, everything else worked except installing Micro. I suspect that this is due to some changes I had to do while testing out different programs and repositories on this master pc.

![micro](https://i.imgur.com/CmbjbxA.png)


### Some additional things

I decided that since its a company I'm simulating, it would be nice that they have the same desktop wallpaper on them. For this I figured I could use a program called xwallpaper to automate it. I tried it out but no luck, nothing seemed to change with it, no matter what I did. So I unfortunately didn't find a way to automate this.

I was also interested in configuring filesharing from the master to the minions. After looking around official Salt documents I found out that you can copy any files from the master to the minions with a single command. In my mind that was actually enough as the master is able to copy whatever they want on to the minions computer. The command used for this is "salt-cp '*' [ options ] SOURCE [SOURCE2 SOURCE3 ...] DEST".

### Setting up UFW for and making a Salt-state for it

Since I'm simulating a business, I guess it would be smart to have a firewall. I'll start by installing it manually and making a few configurations to it. First, I allowed a few ports with the command "sudo ufw allow portnumber". I used 80, 22, and 443. These are for SSH and Apache2.

![ufw](https://i.imgur.com/Umq9JIF.png)

Now I'll need to make the Salt-state. I started by creating directory for UFW called /srv/salt/ufw. In there I would need the init.sls and three separate configuration files that UFW uses. Those files are in /etc/ufw and they are user.rules, user6.rules and ufw.conf. I made the same files in the /srv/salt/ufw folder.

The init.sls file installs the ufw package, then copies the updated configuration files from the Salt-master to the minions /etc/ufw directory. Lastly it restarts the service if any of the files are updated.

![ufw](https://i.imgur.com/a4nicfN.png)

Now I started to run to some errors with my Vagrant machines so I decided to destroy them and create new ones. I'll test the UFW state on the vg01 machine.

![testii](https://i.imgur.com/DyL01RJ.png)


### Finishing up

So now, it all is starting to be ready. I have configured states for Apache, Flameshot, Git, Nano, UFW, SSH, Micro, Wget and Curl. Now I just need to create top.sls file in the /srv/salt directory that tells which states will be applied with it. In the top.sls I put in all the states I have created while doing this project.

![top.sls](https://i.imgur.com/y9ZoKSs.png)

So, I had my 4 Vagrant minions all up and running and I applied the top.sls. Everything went as expected since I wrote earlier that I did not know how to configure Flameshot since it's configuration file is in the users home directory. That was the only thing that failed with the top.sls state.



![finished](https://i.imgur.com/u8jRof8.png)

After running it once, just to be sure I'm gonna apply the state once again. This time I'll only apply it to one of the Vagrant machines to save time. Applying the state to all 4 clean Vagrant machines takes a bit of time. So everything went smootly again, only the Flameshot configuration fails.

![reappliedstate](https://i.imgur.com/fzYj0et.png)

Now I'll destroy one machine and make one more apply to a fully empty machine. Everything seemed to work fine.

![vg01](https://i.imgur.com/Jt6ZVYe.png)

![apache2](https://i.imgur.com/qdT2QxA.png)

I created the /public_html/index.html file to the Vagrant just to test that the user specific homepages work.

Nano works fine with the updated config file, the UFW rules were updated as they should be, everything seemed just fine. I was able to uses ssh aswell without any problems.

![sshh](https://i.imgur.com/2AOJrMe.png)

For now, I'm going to write the instructions on how to use this setup I've created as well as upload the files to github.
