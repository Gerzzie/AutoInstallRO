#!/usr/bin/expect
set password [lindex $argv 0]
spawn adduser rathena

expect "New password:"
send "$password\r"

expect "Retype new password:"
send "$password\r"

expect "Full Name"
send "\r"

expect "Room Number"
send "\r"

expect "Work Phone"
send "\r"

expect "Home Phone"
send "\r"

expect "Other"
send "\r"

expect "Is the information correct?"
send "y\r"

interact