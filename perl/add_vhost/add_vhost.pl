#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use English;
use feature 'say';
use autodie qw(:all);
use File::Slurp qw(:all);

=pod

    for ubuntu and debian:
    apache.conf should NOT include DocumentRoot and default settings looks like this:
    <Directory />
	    Options Indexes FollowSymLinks
	    AllowOverride All
	    Require all granted
    </Directory>

=cut

my $WWW_DIR = '/home/raziel/srcs';
my $APACHE_CONF_DIR = '/etc/apache2/sites-available';
my $SITE_PREFIX = '.local';
my $HOSTS_FILE = '/etc/hosts';

die "Must run as root\n" if $EUID != 0;

print "Enter vhost domain name: \n";
my $domain_name = <STDIN>;
chomp $domain_name; # Get rid of newline character at the end
exit if ($domain_name eq ""); # If empty string, exit.


my $site_conf =
    "<VirtualHost *:80>
     ServerAdmin webmaster\@example.com
     ServerName $domain_name$SITE_PREFIX
     DocumentRoot $WWW_DIR/$domain_name
     ErrorLog \${APACHE_LOG_DIR}/error.log
     CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>";

say 'Creating apache conf file...';
overwrite_file("$APACHE_CONF_DIR/$domain_name.conf", $site_conf);

say "Enabling conf file (a2ensite $domain_name)...";
system "a2ensite $domain_name";

say 'Adding site to hosts...';
append_file($HOSTS_FILE, "127.0.0.1  $domain_name$SITE_PREFIX\n");

say 'Reloading apache...';
system 'systemctl reload apache2';

unless (-d "$WWW_DIR/$domain_name") {
    mkdir "$WWW_DIR/$domain_name";
    system "chown raziel:raziel $WWW_DIR/$domain_name";
    #chown $EFFECTIVE_USER_ID, $EFFECTIVE_GROUP_ID, "$WWW_DIR/$domain_name";
}
