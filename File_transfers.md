# Aspera

NCBI hosts data on for download via Aspera (https://www.ncbi.nlm.nih.gov/public/). You can install Aspera COnnector which is a GUI
but you can also use Aspera on the command line.

I installed it via bioconda (https://bioconda.github.io/recipes/aspera-cli/README.html)
```
mamba create --name aspera bioconda::aspera-cli
```

To use the tool you can type the following to download a file (such as a blast database file):
```
/work2/10089/tlaird/miniforge3/envs/aspera/bin/ascp -T -k 1 -l 500M -i /work2/10089/tlaird/miniforge3/envs/aspera/etc/aspera/aspera_bypass_rsa.pem anonftp@ftp.ncbi.nlm.nih.gov:blast/db/v5/nr.10.tar.gz .
```
Per ncbi you can use these flags:

–Q (for adaptive flow control)
–l (maximum bandwidth of request, try 200M and go up from there)
–r recursive copy
–i <private key file>

