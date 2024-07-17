# Systems administration (Sysadmin) tips for Ubuntu

## Access Control

*Note: any UID below 1000 should be reserved for system accounts/services/other special accounts. Regular UIDs and GIDs should be above 1000

```
# view the paswd file (entry structure: username:password:UID:GID:home_directory:shell)
cat /etc/passwd
```
```
# view the group file (entry structure: group_name:password:groupid:grouplist)
cat /etc/group
```
```
# change a users password
sudo passwd <userid>
```
```
# see the permissions and ownership of files or directories
ls -l
# change the ownership of a directory
sudo chown -R newuser:newgroup <directory>
# change the permisions of a file/directory
chmod ugo+wrx <file or directory>
# using octal signatures (see: https://chmod-calculator.com/)
chmod 777 <file or directory>
```
```
#change a users UID (use sudo below if needed)
#first make sure they don't have processes running and if they do run:
pkill -U <UID/username>
#then backup the passwd file just in case something goes wrong
cp -p /etc/passwd /etc/passwd.bkp
#then change the userid
usermod -u <new.UID> <username> 
```

```
#view the auth log
sudo cat /var/log/auth.log
```
