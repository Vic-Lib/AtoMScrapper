#!/bin/bash
#https://www.accesstomemory.org/en/docs/2.4/admin-manual/maintenance/cli-import-export/#cli-bulk-import-xml

localDir="/home/maximus/xml"

# Open STDOUT as a file for write.
exec 1>$localDir/log/scrapeAtoM.txt

# Redirect STDERR
exec 2>$localDir/log/stderr.txt

#remove any existing files
rm -R $localDir/scrape/*

echo "######## UNZIPPIING FONDS FROM UPLOAD FOLDER ########"

tar -xf /home/upload/victoria-university-archives.tar.gz -C /home/maximus/xml/scrape/

cp $localDir/scrape/victoria-university-archives/descRecs/* $localDir/scrape

echo "####### PURGING LOCAL DATABASE ########"
#The database has to be purged because it doesn't delete the slug and clear database so AtoM gets too many records
php /usr/share/nginx/atom/symfony tools:purge --demo
php /usr/share/nginx/atom/symfony cc

echo "######## CHANGE SETTINGS IN ATOM #######"
#if you want to set AtoM settings (e.g. change display to RAD)
export PHANTOMJS_EXECUTABLE=/usr/local/bin/phantomjs
/usr/local/bin/casperjs /home/maximus/xml/atom.js

exec 1>$localDir/log/import.txt

echo "######## IMPORTING #######"

php /usr/share/nginx/atom/symfony import:bulk --update="delete-and-replace" /home/maximus/xml/scrape

echo "######## REBUILDING CACHE #######"
#if you want the local AtoM instance to show the collection
php /usr/share/nginx/atom/symfony cc & php /usr/share/nginx/atom/symfony search:populate

echo "######## SUCCESS #######"
