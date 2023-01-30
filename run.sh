#!/bin/sh

if ! aws sso login ; then
    echo "aws sso login failed"
    exit 1
fi

if ! aws sts get-caller-identity ; then
    echo "aws sts get-caller-identity failed"
    exit 1
fi

CLI_CACHE_FILE=$(ls -t /root/.aws/cli/cache/ | head -1)
ACCESS_KEY_ID=$(cat /root/.aws/cli/cache/${CLI_CACHE_FILE} | jq -r .Credentials.AccessKeyId)
SECRET_ACCESS_KEY=$(cat /root/.aws/cli/cache/${CLI_CACHE_FILE} | jq -r .Credentials.SecretAccessKey)
SESSION_TOKEN=$(cat /root/.aws/cli/cache/${CLI_CACHE_FILE} | jq -r .Credentials.SessionToken)

echo "[default]" > /tmp/credentials
/root/.local/bin/crudini --set /tmp/credentials default aws_access_key_id ${ACCESS_KEY_ID}
/root/.local/bin/crudini --set /tmp/credentials default aws_secret_access_key ${SECRET_ACCESS_KEY}
/root/.local/bin/crudini --set /tmp/credentials default aws_session_token ${SESSION_TOKEN}

echo "#!/bin/sh" > /tmp/credentials-wrapper.sh
echo "export AWS_ACCESS_KEY_ID=${ACCESS_KEY_ID}" >> /tmp/credentials-wrapper.sh
echo "export AWS_SECRET_ACCESS_KEY=${SECRET_ACCESS_KEY}" >> /tmp/credentials-wrapper.sh
echo "export AWS_SESSION_TOKEN=${SESSION_TOKEN}" >> /tmp/credentials-wrapper.sh
echo "exec \"\$@\"" >> /tmp/credentials-wrapper.sh
chmod 755 /tmp/credentials-wrapper.sh

cat /tmp/credentials
