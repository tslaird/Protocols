# Systems administration (Sysadmin) tips for Ubuntu

## Access Control
```
# view the paswd file (entry structure: group_name:password:groupid:grouplist)
cat /etc/passwd
# view the group file 
cat /etc/group
# change a users password
sudo passwd <userid>
# change the ownership of a directory
sudo chown -R newuser:newgroup <directory>

```
