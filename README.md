# par-jaintor
Clean up old files in the ring buffer

`Jantior` is the tool used to ensure that full packet capture data does not fill the harddrive.



## Configuring Janitor

Janitor can be tuned.. 

```
# Define the directory to check
DIR="/opt/filed-capture"

# Define constants
Minimum=100   # Minimum space below which files will be deleted (MB)
DeleteTo=200  # Delete files until this value is reached (MB)
NumtoDel=25  # Number of files to delete between each free disk space check
```
