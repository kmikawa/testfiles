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
endpoint='https://image.adobe.io/pie/psdService/smartObjectV2'
method='POST'

payload='{
  "inputs": [
    {
      "href": "https://github.com/kmikawa/testfiles/raw/main/psd/smartObject_filter.psd",
      "storage": "external"
    }
  ],
  "options": {
    "layers": [
      {
        "name": "so1",
        "input": {
          "href": "https://as2.ftcdn.net/jpg/02/16/53/79/500_F_216537946_ODYbV4mHvMYtcpS6zUQ1nilKBkHnaazp.jpg",
          "storage": "external"
        }
      },
      {
        "name": "so3",
        "smartObject": {
          "layers": [
            {
              "name": "so3-1",
              "smartObject": {
                "layers": [
                  {
                    "name": "so3-2",
                    "input": {
                      "href": "https://as1.ftcdn.net/jpg/02/09/20/56/500_F_209205609_pTnyKKoslI8bHrF2LoatzPDXRI99ucuZ.jpg",
                      "storage": "external"
                    }
                  }
                ]
              }
            }
          ]
        }
      },
      {
        "name": "so4",
        "input": {
          "href": "https://as2.ftcdn.net/jpg/00/80/88/51/500_F_80885101_vwW81el2bQcXNMnN9mLiNx1wbHjeChrx.jpg",
          "storage": "external"
        }
      }
    ]
  },
  "outputs": [
    {
      "storage": "adobe",
      "type": "image/jpeg",
      "overwrite": true,
      "width": 0,
      "quality": 7,
      "href": "files/example/output2.jpeg"
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
