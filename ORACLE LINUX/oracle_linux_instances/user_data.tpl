#cloud-config
output:
  all: "| tee -a /var/log/cloud-init-output.log"
runcmd:
  # Inject our hostname into /etc/hosts so localhost resolves correctly
  - sed -i 's/127\.0\.0\.1.*/127.0.0.1 localhost ${hostname}/' /etc/hosts
  - hostnamectl set-hostname ${hostname}

%{ if service_proxy_host != "" }
  - echo "proxy=http://${service_proxy_host}:3128" >> /etc/yum.conf
%{ endif }

  - yum install -y https://repo.saltproject.io/py3/redhat/salt-py3-release-latest.noarch.rpm

  # Refresh yum’s cache so it sees the new repo
  - yum clean expire-cache

  # Install the Salt Minion agent
  - yum install -y salt-minion

  # Ensure the Salt config directory exists and set our minion ID
  - mkdir -p /etc/salt
  - printf "%s" "${hostname}" > /etc/salt/minion_id

  # Block until Salt’s first “highstate” run succeeds
  - |
    until test -f /var/run/salt/minion/last_successful_run; do
      salt-call state.highstate || sleep 60
    done
