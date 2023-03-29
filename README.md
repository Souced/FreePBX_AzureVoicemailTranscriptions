# FreePBX_AzureVoicemailTranscriptions
Scripts that insert voicemail transcriptions into emails created by freepbx and converts attachments to MP3

Install Instructions:
# install EPEL repository and Microsoft's repository
sudo yum install epel-release
sudo rpm -Uvh https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm

# install Python 3,pip and LAME
sudo yum install python3 python3-pip
sudo rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
sudo rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
sudo yum install lame

# install the compatible OpenSSL libraries:
sudo yum install compat-openssl10

# Install the Azure Speech SDK for Python
sudo pip3 install azure-cognitiveservices-speech

# Clone the Repo
