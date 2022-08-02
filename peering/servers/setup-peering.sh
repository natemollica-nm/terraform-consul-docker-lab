#!/bin/sh

set -x

# Create partition foo
curl -k -s "${FOO_API}/v1/partition" \
   -X PUT \
   -H "Authorization: Bearer ${FOO_TOKEN}" \
   -d '{"Name": "foo"}'

# Create partition bar
curl -k -s "${BAR_API}/v1/partition" \
   -X PUT \
   -H "Authorization: Bearer ${BAR_TOKEN}" \
   -d '{"Name": "bar"}'

# Create the Peering Token
PEERING_TOKEN_RESP=$(curl -k -s "${FOO_API}/v1/peering/token" \
   -X POST \
   -H "Authorization: Bearer ${FOO_TOKEN}" \
   -H "X-Consul-Partition: foo" \
   -d '{"PeerName": "bar"}')
   
PEERING_TOKEN=$(jq -r '.PeeringToken' <<< "${PEERING_TOKEN_RESP}")
   
# Establish the peering
curl -k -s "${BAR_API}/v1/peering/establish" \
   -X POST \
   -H "Authorization: Bearer ${BAR_TOKEN}" \
   -H "X-Consul-Partition: bar" \
   -d "{\"PeerName\": \"foo\", \"PeeringToken\": \"${PEERING_TOKEN}\"}"
   
# Also peer the default partitions

# Create the Peering Token
PEERING_TOKEN_RESP=$(curl -k -s "${FOO_API}/v1/peering/token" \
   -X POST \
   -H "Authorization: Bearer ${FOO_TOKEN}" \
   -H "X-Consul-Partition: default" \
   -d '{"PeerName": "cluster2"}')
   
PEERING_TOKEN=$(jq -r '.PeeringToken' <<< "${PEERING_TOKEN_RESP}")
   
# Establish the peering
curl -k -s "${BAR_API}/v1/peering/establish" \
   -X POST \
   -H "Authorization: Bearer ${BAR_TOKEN}" \
   -H "X-Consul-Partition: default" \
   -d "{\"PeerName\": \"cluster1\", \"PeeringToken\": \"${PEERING_TOKEN}\"}"
   