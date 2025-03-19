#!/bin/bash

echo -n "> "
read input_string
md5_hash=$(echo -n "$input_string" | md5sum | awk '{ print $1 }')
echo $md5_hash
