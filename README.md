# FreePBX Azure VoicemailTranscriptions
A script to transcribe voicemail messages in FreePBX using Azure Cognitive Services and store them in the voicemail message email.

## Requirements

*Python 3.6 or higher
*FreePBX 15 or higher
*An Azure Cognitive Services account with a Speech Services resource

## Installation

# Install EPEL repository and Microsoft's repository
```Bash
sudo yum install epel-release
sudo rpm -Uvh https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm
```
# Install Python 3, pip and LAME
```Bash
sudo yum install python3 python3-pip
sudo rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
sudo rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
sudo yum install lame
```
# Install the compatible OpenSSL libraries:
```Bash
sudo yum install compat-openssl10
```
# Install the Azure Speech SDK for Python
```Bash
sudo pip3 install azure-cognitiveservices-speech
```
# Clone the Repo
```Bash
git clone https://github.com/Souced/FreePBX_AzureVoicemailTranscriptions.git
```
# Install the scripts
```Bash
cd FreePBX_AzureVoicemailTranscriptions
cp emailproc /usr/local/bin
cp sttparse /usr/local/bin
chmod +x /urs/local/bin/emailproc
chmod +x /urs/local/bin/sttparse
```
# Modify the sttparse script
    api_key = 'your_api_key_here'
    region = 'your_region_here'

# FreePBX Setup
In FreePBX browse to Settings -> Voicemail Admin -> Settings -> Email Config then add the transcription tag {{{{TRANSCRIPTION}}}} to the Email Body. The script will search for this tag to replace with the transcription text. The script will automatically change the content type to text/html. Here is a sample html email:

```html
<html>
<body>
<p>${VM_NAME},
<br><br>
There is a new voicemail in mailbox ${VM_MAILBOX}:</p>
<p>
<table>
  <tr>
    <th align="left">From (Name):</th>
    <td>${VM_CIDNAME}</th>
  </tr>
  <tr>
    <th align="left">From (Number):</th>
    <td><a href="tel://${VM_CIDNUM}">${VM_CIDNUM}</a></td>
  </tr>
  <tr>
    <th align="left">Length:</th>
    <td>${VM_DUR} seconds</td>
  </tr>
  <tr>
    <th align="left">Date:</th>
    <td>${VM_DATE}</td>
  </tr>
  <tr>
    <th align="left">Transcription:</th>
    <td>{{{{TRANSCRIPTION}}}}</td>
  </tr>
</table></p>
<p>Dial *98 to access your voicemail by phone.<br>
Visit <a href="https://your.pbxaddress.tld">https://your.pbxaddress.tld</a> to check your voicemail with a web browser.</p>
</body>
</html>
```
Finally, set the Mail Command value to /usr/local/bin/emailproc


## Contributing
Contributions are welcome! To contribute to this project, please fork the repository and submit a pull request.

## License
This project is licensed under the Unlicense - see the [LICENSE](LICENSE) file for details.