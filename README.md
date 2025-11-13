
# 🧑‍💻 User Management Automation (SysOps Challenge)

## 📘 Overview

This project automates the process of creating and managing Linux user accounts for newly hired developers.  
It reads user details from a text file, creates accounts, assigns groups, sets secure passwords, and logs all actions.

Script name: **create_users.sh**  
Input file: **users.txt**



## 🧩 Features

✅ Automatically creates new users and their home directories  
✅ Assigns users to multiple groups  
✅ Generates secure random 12-character passwords  
✅ Logs all activities and errors  
✅ Stores passwords securely with strict file permissions  
✅ Handles existing users and groups gracefully  
✅ Ignores commented (`#`) and blank lines  
✅ Provides clear terminal feedback and audit logs  

---

## 📄 Input File Format

Each line in `users.txt` contains a username and its groups separated by a semicolon:
