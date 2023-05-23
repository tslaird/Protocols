# Using the UC Davis FARM

The following contains information pertaining to using the FARM usage at UC Davis.

The direct resource is: https://wiki.cse.ucdavis.edu/support/systems/farm

Note that, "All researchers in CA&ES are entitled to free access to the original 8 nodes with 24 CPUs each and 64GB ram in the low, med, and high partitions" and Everyone gets free access to a common storage pool for 1TB per user.

#### Setting up a custom FARM Terminal
Once you have access to the FARM you will need to ssh in via a terminal. I prefer to set up a custom terminal dedicated to work on the FARM. To do this on linux you can:
 1) Open the terminal application
 2) Select Edit-->Preferences
 3) Click on the "+" sign to add a new profile and name it something like "FARM"
 4) Customize background color, text color, text size, etc to your liking.
 5) Add a custom command by selecting the checkbox that says "Run a custom command instead of my shell".
 6) Enter the custom command```ssh yourid@farm.cse.ucdavis.edu```

Now within the Terminal app you will be able to select New Window-->FARM and you will be automatically logged into the head node on the FARM.


**Using the terminal in Linux/MacOS may be different from how you use the shell or subsystem on Windows.**

#### Transfering files to and from the FARM

There are differnt types of file transfer protocols that can be used to mov efiles between your local computer and the FARM such as scp and rsynch. The below is information on rsynch because this protocol allows for reinitiating a transfer if there happens to be an interruption in internet connection.

```rsync -aP -e ssh username@farm.cse.ucdavis.edu:~/source_directory dest_directory```

where ```source_directory``` is the directory on the FARM that you want to transfer files from and ```dest_directory``` is a directory on your local computer you would like to transfer those files to.

You can do the reverse and transfer files to the FARM using a command like:

```rsync -aP -e ssh source_directory username@farm.cse.ucdavis.edu:~/dest_directory```

*Note: The ```-e ssh``` flag in the command specifies that there will be an ssh connection initiated by rsync. Thus, the commands above are run from a terminal on your local machine. You do not need to be logged into the FARM to run these command.

#### Setting up a reproducible computing environment on the FARM

Install conda/mamba:
```
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
bash Miniforge3-Linux-x86_64.sh
```

Install some base packages

```
mamba install snakemake
```

#### Running commands on the FARM

In order to do run large computational analysis on the FARM you will need to use the slurm job scheduler to manage those jobs. You may be able to run smaller jobs on the head node but if you try to run large jobs then the FARM administrators will get upset and perhaps revoke your access. There are many functions in slurm (see: https://slurm.schedmd.com/programmer_guide.html) but you will most likely use ```sbatch```, ```srun```, and ```squeue``` 

##### sbatch

```sbatch``` is the most common command you will use. With this command you can schedule a job to run, terminate your connection to the FARM head node, and the job will be distributed to nodes when they are available. This all happens without you having to be present at your computer and connected to the head node. You can schedule the job and let it go.

As in typical

##### srun
```srun``` will allow you to start and instance directly on one of the compute nodes (assuming the resources you request are available). This is differs from the ```sbatch``` in that you must be actively logged into the farm system to run the commands of your job.

An example ```srun``` command would be something like this:
``` srun -N 1 -c 8 -t 60 -p med --pty bash```

The above would specify that you would like 1 node (```-N 1```) with 8 cores (```-c 8```) and would like the session to run 60 minutes (```-t 60```) on the medium partion nodes (```-p med```) and you would like the shell to be bash (```--pty bash```).

You would run this command and when what you specify becomes available you would be logged into an interactive session on the FARM. However you will be kicked off of the session once you reach your specified time limit.

##### squeue
```squeue``` enables you to see the status of all the jobs running. The command by itself will show you all of the jobs for every user (which is probably not that helpful) so you can narrow the results to just your jibs with the ```-u``` flag.

```squeue -u username```

#### SLURM sbatch template

```
#!/bin/bash -l
#SBATCH -J job_name # Name of the job
#SBATCH -o %x-%j.out # create standard output files with name and job number
#SBATCH -e %x-%j.err create standard error files with the name and job number
#SBATCH --mail-type=ALL # get all possible updates via email
#SBATCH --mail-user=tslaird@ucdavis.edu # email address to send to
#SBATCH -N 1 # number of nodes to request
#SBATCH -n 16 # number of cores to request
#SBATCH -t 120:00:00 #maximum possible run time

#enter script below


```
