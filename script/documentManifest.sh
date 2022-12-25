 #!/bin/bash

# ************************************
# Check if jq is installed
# ************************************
if [ ! `which jq` ]; then
	echo "************************************"
	echo "Please install jq: brew install jq"
	echo "************************************"
	exit 1
fi

# ************************************
# Set variables
# ************************************
# set -x
token=''
apiKey=''
endpoint='https://image.adobe.io/pie/psdService/documentManifest'
method='POST'

payload='{
  "inputs": [
    {
      "href": "https://github.com/kmikawa/testfiles/raw/main/psd/3Layers.psd",
      "storage": "external"
    }
  ]
}'

# ************************************
# Call API
# ************************************
res=$(curl -k -Ss -H "Authorization: Bearer $token" -H "Content-Type:application/json" -H "x-api-key: $apiKey" -X "$method" -d "$payload" "$endpoint")
myerror=$(echo $res | jq -r .code)
if [ $myerror != "null" ]; then
	echo "ERROR: $res"
	exit 1
fi
jobid=$(echo $res | jq -r ._links.self.href)
echo "JOBID: $jobid"

# ************************************
# Check Status
# ************************************
while [ "x$jobstatus" != "xsucceeded" ] && [ "x$jobstatus" != "xfailed" ]; do
	output=$(curl -k -Ss -H "Authorization: Bearer $token" -H "Content-Type:application/json" -H "x-api-key: $apiKey" -X GET "$jobid" | jq -r '.outputs[0]')
	jobstatus=$(echo $output | jq -r '.status')
	echo "JOBSTATUS: $jobstatus"
done

# ************************************
# Result
# ************************************
echo "************************************"
echo "RESULT"
echo ""
echo $output | jq
echo "************************************"
