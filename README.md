# geonode-customisation
Customised files and everything required to get them on place.

Script in this repository is not ready to use yet!

## Usage

1) Clone repository on server hosting GeoNode:

    `git clone git@github.com:resilienceacademy/geonode-customisation.git`

2) Make .sh files executable

    `chmod u+x *.sh`

3) Change django container name on script process_files.sh if it is not django4geonode

4) Execute update.sh

    `./update.sh`

Update.sh will always pull latest version from git before updating files. All files will be backed up before updating. Process halts on error.
