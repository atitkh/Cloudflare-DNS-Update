# Cloudflare DNS Update

This is a simple shell script that allows you to update DNS records on Cloudflare using their API.

## Requirements
1. A Cloudflare account
2. A domain hosted on Cloudflare
3. A valid Cloudflare API key with permissions to edit DNS records

## Setup

1. Clone the repository or download the ip_update.sh script.
2. Fill in your account and DNS details.
* You can find your Cloudflare API key and your domain's zone ID in the "API Tokens" and "Zone ID" sections of the Cloudflare dashboard, respectively.
3. Make the script executable by running chmod +x ip_update.sh.

# Usage

To update a DNS record, run the script:
```
./ip_update.sh
```

# Notes
1. This script will only update existing DNS records. If the specified record does not exist, it will not be created.
2. The script will update all records with the specified name and type. If you have multiple records with the same name and type, they will all be updated.
