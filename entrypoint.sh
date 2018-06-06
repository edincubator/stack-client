#!/bin/bash

read -p "Enter your username : " username
useradd $username
su $username
/bin/bash
