# Raspberry Pi setup

Install `jessie-lite` image

## Update

    sudo apt-get update

# Setup passwordless SSH access:

On Pi:

    install -d -m 700 ~/.ssh

on Mac:

    cat ~/.ssh/id_rsa.pub | ssh pi@<IP_ADDRESS> 'cat >> .ssh/authorized_keys'

Run `raspi-config`

* Set Locale (en-utf8)
* Set Timezone
* Expand FS
* Set Password
* Set Hostname

Reboot

# Install a few things we'll need

    sudo apt-get install git postgresql postgresql-contrib libpq-dev nginx upstart redis-server

Reboot

    sudo reboot

# Install Ruby

https://gist.github.com/blacktm/8302741

Last time I checked the command to run was:

    bash <(curl -s https://gist.githubusercontent.com/blacktm/8302741/raw/88272ec7e5d6d74b305980ca1c7f6e71bdff7651/install_ruby_rpi.sh)

Takes 16 minutes.

    sudo reboot
    # After reboot
    gem install bundler

# Setup Postgresql

    sudo -i -u postgres
    createuser -s -P rails # No password
    exit

    sudo nano /etc/postgresql/9.4/main/pg_hba.conf
    # change all the 'peer' to 'md5' EXCEPT FOR THE "Database administrative login by Unix domain socket" ENTRY

    sudo service postgresql restart

# Install AWS CLI

    sudo apt-get install awscli

This has a bagillian dependencies so this may take a few minutes.

# Instal ffmpeg

Pulled from here: https://www.bitpi.co/2015/08/19/how-to-compile-ffmpeg-on-a-raspberry-pi/

    sudo apt-get update;
    sudo apt-get -y --force-yes install libmp3lame-dev libx264-dev yasm git autoconf automake build-essential libass-dev libfreetype6-dev libtheora-dev libtool libvorbis-dev pkg-config texi2html zlib1g-dev

### Compile the libfaac library
This can't be distributed in binary form because of some license crap. Well, let's install it.

    cd ~;
    wget http://downloads.sourceforge.net/faac/faac-1.28.tar.gz;
    tar -xvf faac-1.28.tar.gz;
    cd faac-1.28/;

We've gotta make a tweak to the source:

    nano +126 common/mp4v2/mpeg4ip.h; # Opens up to line 126 (should start with "char *strcasestr")

Delete that line. Then complete the install

    ./configure
    make;
    sudo make install;

> Last step is to run the command "ldconfig" which will help ffmpeg load up the dynamic library of libfaac.

    sudo ldconfig;

### Download and compile ffmpeg from source

    cd ~;
    git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg;

Configure:

    cd ffmpeg;
    ./configure --enable-libfreetype --enable-gpl --enable-nonfree --enable-libx264 --enable-libass --enable-libfaac --enable-libmp3lame --bindir="/usr/local/bin"


**********************
NOTES FROM 1/25/2016
libfaac support was removed from ffmpeg. I installed libfdk-aac as follows:


    cd ~
    wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/master
    tar xzvf fdk-aac.tar.gz
    cd mstorsjo-fdk-aac*
    autoreconf -fiv
    ./configure --enable-shared
    make -j2
    sudo make install
    sudo ldconfig;

Then compile ffmpeg with this:

    ./configure --enable-libfreetype --enable-gpl --enable-nonfree --enable-libx264 --enable-libass --enable-libfdk-aac  --enable-libmp3lame --bindir="/usr/local/bin"


*******




Make:

    make

Go get a beer. (Seriously. This takes a long time)

Install:

    sudo make install

Test

    ffmpeg -version


# Configure Nginx

Find the nginx config file in the `deploy/nginx` directory in this repository

Copy the `greateye.conf` file to `/etc/nginx/sites-available/greateye.conf`

Add a symlink for `sites-available/greateye.conf` to `sites-enabled/`

    sudo ln -s /etc/nginx/sites-available/greateye.conf /etc/nginx/sites-enabled

Remove the symlink for `sites-enabled/default`

    sudo rm /etc/nginx/site-enabled/default

Restart nginx:

    sudo service nginx restart

If this fails, you can view the log with:

    sudo tail -n 100  /var/log/nginx/error.log

You should now be able to connect to your server at port 80. ex:

    http://192.168.12.208

You will get an error (probably 502, bad gateway). But this means NGINX is running.

# Install the Rails codebase

### Set up the directory structure

    sudo mkdir /www
    sudo chown pi:pi /www
    cd /www
    mkdir greateye
    cd greateye
    mkdir shared
    cd shared
    mkdir config

### Config files

Set up:

    /www/greateye/shared/config/secrets.yml
    /www/greateye/shared/config/application.yml

### Upstart files

Find the upstart config files in the `deploy/upstart` directory in this repository

Copy them to:

    /etc/init/sidekiq.conf
    /etc/init/puma.conf
    /etc/init/clockwork.conf

### Deploy

Set up `config/deploy/production.rb` and then on development machine:

    cap production deploy #(this will fail, but it still is necessary as it gets the code on the Pi)

This first deploy will take a long time (~30 min) as it runs `bundle install` and the pi isn't the fastest.


### Setup the database

NOTE: Last time I set it up (and when I wrote these docs) I was recovering PSQL from a crashed server. I did that at this point in the process.

Presumably you would need to db:create and db:migrate on a fresh setup about now, but after copying the psql the database appeared to be in good shape.

### Start the services

    sudo start puma
    sudo start sidekiq
    sudo start clockwork

# Misc

I like htop:

    sudo apt-get install htop
    htop

To copy the psql data from a crashed Pi I used this command (after mounting the old SD card to /Volumes/Untitled):


    scp -r /Volumes/Untitled/var/lib/postgresql/9.4 pi@192.168.12.207:~/postgres_data

Then on the Pi I copied it to the correct place with:

    sudo cp -a postgres_data/ /var/lib/postgresql/9.4_copy/
    sudo service postgresql stop
    sudo mv /var/lib/postgresql/9.4 /var/lib/postgresql/9.4_empty
    sudo mv /var/lib/postgresql/9.4_copy /var/lib/postgresql/9.4
    sudo chown postgres:postgres 9.4/ -R # Fix permissions
    sudo service postgresql start
