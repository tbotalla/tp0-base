#!/bin/bash

probe_message="Tomas Botalla, un gusto :)"
expected_response_prefix="Your Message has been received: "
response=$(echo "$probe_message" | nc -N server 12345)

if [ "$response" = "$expected_response_prefix$probe_message" ]; then
  echo "OK! The server is working properly."
else
  echo "ERROR! The server is not working properly. Received probe message response from server: $response"
fi
