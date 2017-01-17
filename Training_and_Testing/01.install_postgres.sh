
code=$WC_TRAIN/01.Code
wd=$WC_TRAIN_DATA/01.work
output=$WC_TRAIN_DATA/01.output

# Install postgres
systemctl status postgresql.service | grep "PostgreSQL" > /dev/null
if [ $? -gt 0 ]
then
	sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
	wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
	sudo apt-get update
	sudo apt-get install -y postgresql postgresql-contrib postgis
fi



