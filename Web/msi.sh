#!/usr/bin/expect
spawn /usr/bin/mysql_secure_installation

expect "Enter current password for root (enter for none):"
send "ragnarok\r"

expect "Change the root password?"
send "n\r"

#expect "Set root password?"
#send "y\r"

#expect "New password:"
#send "ragnarok\r"

#expect "Re-enter new password:"
#send "ragnarok\r"

expect "Remove anonymous users?"
send "y\r"

expect "Disallow root login remotely?"
send "y\r"

expect "Remove test database and access to it?"
send "y\r"

expect "Reload privilege tables now?"
send "y\r"

interact