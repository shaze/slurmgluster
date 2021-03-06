# slurmgluster
Taking jobs to storage 

Gluster is a distributed file system -- this means that files are distributed across many physical disks, probably on many machines. For example on the Wits
cluster diskC is 60 disks on 20 machines. This can improve performance for disk access as there isn't one physical disk that is the bottleneck although there 
are some use cases where this doesn't work well.

There can also be replication of files so that files are stored twice or times -- this supports redundancy and also improved performance -- two processes accsing the same file can access different copies.

Usually and desirably this distributed nature is transparent to the user -- the user just seems a disk/file system and is unaware of the fact that it is distributed.

However sometimes we may want to exploit the physical locality. Suppose you have 100 BAM files on the disk. These will be semi-randomly distributed on the disks across different nodes. Then when you run jobs via slurm they get allocated to nodes independently of where the files are allocated. Suppose you launch 100 jobs to analyse the BAM files -- only a small proportion of these jobs will run on the nodes on which files they are processing are allocated. Gluster can handle this of course, but at high loads this can add considerable network load reducing efficiency. 

The code below can be used in a Nextflow script to allocate jobs to the nodes which contain the a file of interest. This is done use the `clusterOptions` option, passing the node which would be used. One complication in this is that the node has to be passed as value to the process (see example below).


# How it works

In your Nextflow script you specify the files you want to use node allocation. The Groovy code here builds up a hash table that specifies for each file where a process for that file should run.  You can use `clusterOptions` and lookup in the hash table the value to pass.


# Guidelines

By default you should not use this code - it adds a layer of complication and also adds extra constraints on where jobs run. Gluster and slurm are pretty good. But you can consider using this if

* you are processing very large files (generally 10s of GB but YMMV)
* the processing is I/O bound -- that is the cost of reading from disk is a significant part of the overall processing
* you have lots of jobs and processes (if only a few it's not worth the effort)

# To use it

Include the Groovy code marked `common code` into your script. 

Adapt the code marked `sample`. In this example we are processing a bunch of BAM files and their indexes. We want to allocate jobs to nodes based on locations of the BAM file (the index file may well be on a different node but as BAI files are so small that doesn't matter).



# Weaknesses

Note a major weakness of this is that jobs are allocated based on the state of the cluster when the overall nextflow script first runs. Ideally this would be done dynamically when the process runs. Unfortunately it's not easy to do (there are ways but it makes the code more complicated). I try to mitigate this partially by radomising the order of files since there can be non-random allocation of files. In this example I use `randomSample(1000)` You should pick a number that is definitely greater than then number of files you will be processing -- doesn't have to be exact just bigger.


