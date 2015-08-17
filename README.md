# (Semi-) Automatic creation of StartSSL certificates
This bash script is based on two [blog](https://konklone.com/post/switch-to-https-now-for-free) [posts](https://joshemerson.co.uk/blog/secure-your-site) about securing your website using free SSL certificates from [StartSSL](https://www.startssl.com). It generates a 'certificate request file' that is automatically pasted to your clipboard to fill in on the StartSSL website. As soon as you generated the certificate you can paste it back to the script and it is saved in the same folder and (if wanted) uploaded to you webserver using scp.

## Dependencies
- curl
- openssl
- scp

## Installation
```bash
git clone https://github.com/thomastweets/setupSSL.git
cd setupSSL
chmod +x generateCertificate.sh
```
## Configuration
There are some parameters to configure the script at the top ('Settings').

## Usage
```bash
./generateCertificate.sh
```

2015 [Thomas Emmerling](http://blog.thomasemmerling.de)
