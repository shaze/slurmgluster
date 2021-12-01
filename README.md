# slurmgluster
Taking jobs to storage 

Gluster is a distributed file system -- this means that files are distributed across many physical disks, probably on many machines. For example on the Wits
cluster diskC is 60 disks on 20 machines. This can improve performance for disk access as there isn't one physical disk that is the bottleneck although there 
are some use cases where this doesn't work well.

There can also be replication of files so that files are stored twice or times -- this supports redundancy and also improved performance -- two processes accsing the same file can access different copies.

Usually and desirably this distributed nature is transparent to the user -- the user just seems a disk/file system and is unaware of the fact that it is distributed.

However sometimes we may want to exploit the physical locality. Suppose you have 100 BAM files on the disk. These will be semi-randomly
