#!/bin/bash
if ! rpm -q bind-utils > /dev/null 2>&1; then
    echo 'not installed'
    yum install -y bind-utils
    reboot
fi
