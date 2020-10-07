curl -s 'http://localhost:8080/JSON/ascan/action/scan/?url=https%3A%2F%2Fjuice-shop.herokuapp.com%2F&recurse=true&inScopeOnly=false&scanPolicyName=&method=&postData=&contextId='
echo "Started active scan... "

attempt_counter=0
max_attempts=100
statusResult=""

while
  if [ ${attempt_counter} -eq ${max_attempts} ];then
    echo "Max attempts reached, exiting"
    exit 1
  fi

  statusResult="$(curl -s 'http://localhost:8080/JSON/ascan/view/status/?scanId=0')"
  echo "Current active scan status: ${statusResult}"

  attempt_counter=$(($attempt_counter+1))
  sleep 5

  [[ "$statusResult" != "{\"status\":\"100\"}" ]]
do true; done

echo "Finished"