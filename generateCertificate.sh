#!/bin/bash
# Thomas Emmerling
#
# based on a blog post by Josh Emerson
# https://joshemerson.co.uk/blog/secure-your-site
# and a blog post by Eric Mill
# https://konklone.com/post/switch-to-https-now-for-free

# ===============
# Settings
# ===============
numbits=2048
certFolder="_certs"
rootCerts="sub.class1.server.ca.pem ca.pem"
startssl_certs="https://www.startssl.com/certs/"
server="server"
remotePath="~/certs"

# Colors
red='\033[0;31m'
yellow='\e[0;33m'
green='\033[0;32m'
NC='\033[0m'


printStep() {
  printf "$green$1\n$NC" "$2"
}

printError() {
  printf "$red$1\n$NC" "$2"
}

printQuestion() {
  printf "$yellow$1$NC" "$2"
}

printStep "Script for creating certificates at startssl.com"
printStep "================================================"
# ===============
# Step 0
# ===============
printStep "Checking _certs folder..."
if [ ! -d "$certFolder" ]; then
  printStep "_certs folder not found! Creating _certs folder..."
  mkdir "$certFolder"
fi
for cert in $rootCerts
do
  if [ ! -d "$certFolder/$cert" ]; then
    printStep "Downloading $startssl_certs$cert to _certs folder..."
    curl -o "$certFolder/$cert" "$startssl_certs$cert"
  fi
done

# ===============
# Step 1
# ===============
printQuestion "Please put the name of the (sub-) domain for which the certificate will be created: "
read domain

if [ ! -d "$domain" ]; then
  mkdir "$domain"
else
  printError "A folder with the name %s already exists! Exiting..." "$domain"
  exit 1
fi

printStep "Generating private key with %s bits..." "$numbits"
openssl genrsa 2048 > $domain/$domain.key
printStep "...done!\n"

printStep "Generating certificate request file..."
openssl req -new -subj "/CN=$domain" -key $domain/$domain.key -out $domain/$domain"_csr.pem"
printStep "...done!\n"

if hash pbcopy 2>/dev/null; then
  printStep "Copying certificate request file to clipboard"
  cat $domain/$domain"_csr.pem" | pbcopy
  printStep "...done!"
  cat $domain/$domain"_csr.pem"
else
  printStep "Printing certificate request file: "
  cat $domain/$domain"_csr.pem"
  printStep "\nPlease copy this to your clipboard!"
fi

printStep "Please paste the generated certificate request to the form at startssl.com!"

# ===============
# Step 2
# ===============
while true; do
    read -p "Have you generated the certificate? [y|n] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
    esac
done

touch $domain/$domain".crt"
if hash pbpaste 2>/dev/null; then
  printQuestion "Copy the generated certificate to your clipboard. Press ENTER when the certificate is in your clipboard!"
  read
  crt=$(pbpaste)
  printStep "This is your certificate:"
  printf "%s \n" "$crt"
else
  printQuestion "Copy the generated certificate to your clipboard. Paste certificate here and press ctrl-d (twice) when done!"
  crt=$(cat)
fi

printStep "Saving..."
echo -e "$crt" > $domain/$domain".crt"
printStep "...done!"

# ===============
# Step 3
# ===============
printStep "Saving intermediate and root certificates..."
bundleCert=""
for cert in $rootCerts
do
  bundleCert="$bundleCert\n$(cat $certFolder/$cert)"
done
echo -e "$bundleCert" > $domain/$domain".pem"
printStep "...done!"

# ===============
# Step 4
# ===============
printStep "...instructions..."
while true; do
    read -p "Do you wish to copy the generated files to the server? [y|n] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
    esac
done

printStep "Copying files to %s..." "$server"
scp $domain/$domain".crt" $domain/$domain".key" $domain/$domain".pem" $server":"$remotePath
