#!/bin/bash
date=$(date +%Y-%m-%d)
read -p "Bitte gib deinen Benutzernamen an: " username
echo $username
#read -p "Bitte gib dein passwort ein" $password
#read -p "Bitte gib deine E-Mail adresse ein" $email
# check if mkimage .sh exist and is up to date
if [ -d "$HOME/docker/contrib" ] ; then
(cd "$HOME/docker" || exit
git pull)
else
(cd "$HOME" || exit
git clone https://github.com/docker/docker.git)
fi
# check if a build directory with the date from today exist
if [ -d "$HOME/docker-debian-jessie-armv7/$date" ] ; then
# build the docker image with the tag "debian-jessie.$date"
(cd "$HOME/docker/contrib" || exit
sudo ./mkimage.sh -d "$HOME/docker-debian-jessie-armv7/$date" -t "$username/debian-jessie-armv7:$date" debootstrap --variant=minbase --include=inetutils-ping,iproute2 --components=main   jessie http://httpredir.debian.org/debian)
( cd "$HOME/docker-debian-jessie-armv7/$date" || exit
echo "$username/debian-jessie-armv7:$date"
echo $username
tag="${username}/debian-jessie-armv7:${date}"
docker build --no-cache=true -t "$tag" .)
else
# create the directory and build the docker image with the tag "debian-jessie.$date"
mkdir -p "$HOME/docker-debian-jessie-armv7/$date"
(cd "$HOME/docker/contrib" || exit
sudo ./mkimage.sh -d "$HOME/docker-debian-jessie-armv7/$date" -t "$username/debian-jessie-armv7:$date" debootstrap --variant=minbase --include=inetutils-ping,iproute2 --components=main   jessie http://httpredir.debian.org/debian)
( cd "$HOME/docker-debian-jessie-armv7/$date" || exit
echo "$username/debian-jessie-armv7:$date"
echo $username
tag="${username}/debian-jessie-armv7:${date}"
docker build --no-cache=true -t "$tag" .)
fi
docker rmi "$username/debian-jessie-armv7:latest"
patternrep="$username/debian-jessie-armv7"
patterntag="$date"
id=$(./get-id.sh $patternrep $patterntag)
docker tag "$id" "$username/debian-jessie-armv7:latest"
docker push "$username/debian-jessie-armv7"

