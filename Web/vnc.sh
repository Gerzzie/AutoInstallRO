#!/usr/bin/expect
set password [lindex $argv 0]
spawn vncserver

expect "Password:"
send "$password\r"

expect "Verify:"
send "$password\r"

expect "Would you like to enter a view-only password (y/n)?"
send "n\r"

interact