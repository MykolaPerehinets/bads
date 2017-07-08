# bads
Bacula Agent Deploy Server (BADS)

Description

Bacula Agent Deploy Server (BADS) is a simple front-end web server writed on Golang for managing and deploy Backup Bacula Agent (bacula-client and additional configuration files) on host.
This web solution use additional ansible playbook for automation installation Bacula Agent in users` hosts.

Detail information about this in README file.

Installation

sudo su root   &&   cd /opt   &&   git clone https://github.com/MykolaPerehinets/bads.git   &&   cd /opt/bads   &&   ./install.sh

Usage

BADS about to listen on 8443 port. Go to https://127.0.0.1:8443 for verifing...

