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
# change the ownership of a directory
sudo chown -R newuser:newgroup <directory>
```
