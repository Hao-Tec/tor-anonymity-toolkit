#!/bin/bash
PORT=9051
rm -f pipe
mkfifo pipe
trap "rm -f pipe" EXIT

# We use netcat to listen and pipe input/output
# This is a bit complex to mock reliably with simple tools, but let's try.
# We will use a simple perl script or python script for the mock server as it is more reliable than bash+nc for bidirectional protocol
