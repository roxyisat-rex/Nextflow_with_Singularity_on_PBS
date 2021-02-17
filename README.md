# Nextflow_with_Singularity_on_PBS
This is a guide for beginners to use Nextflow with Singularity on the PBS cluster (it could be applicable to other HPC too with just a little modification)
This guide will be seperated into the below sections:
1. Prerequisites 
2. A little background on the example 
3. BUilding a singularity container 
4. Creating the nextflow process 
5. Running NF process in singularity container (nextflow config file) 
6. Potential errors and useful commands 

###### Prerequisites
Singularity needs to be installed.
Since this is a guide for singularity to be used with HPC, whether singularity is installed on the HPC you use depends on your institution. 
Normally you do not have the admin privlige to install singularity, remember to ask a member of your HPC support staff, make sure it's installed. 
For Imperial College London 'Singularity' is already installed on our PBS pro cluster. 

To use, 

```
module load singularity
``` 

###### Example
Here instead of the easy "Hello world" example. I will be using a slightly more difficult example with potentially more operational.  
This is a part of the LD score estimation for LD scoreregression, by Dr Finucane and Dr Bulik-Sullivan. 
LDSC is a method to "accurately estimate genetic heritability and its enrichment in both homogenous and admixed populations with summary statistics 
and in-sample LD estimates". 
[This](https://github.com/bulik/ldsc/wiki/LD-Score-Estimation-Tutorial) is the link to the LDSC github repositry if you wish to learn more. You do not really need to know LDSC to understand this tutorial, it is just to provide more contexts. 
 
Here we use a ".bed" file in combination with a ".bim" file from the 1000 Genome project to create a ".annot.gz" file. 
```
python make_annot.py \
		--bed-file Brain_DPC_H3K27ac.bed \
		--bimfile 1000G.EUR.QC.22.bim \
		--annot-file Brain_DPC_H3K27ac.annot.gz  
```
###### Building Singulairy container 

You can use the ```pull``` and ``` build ``` commands to download pre-built images from an external resource like the Container
Library or Docker Hub.
When called on a native Singularity image like those provided on the Container Library, ```pull```simply downloads the image file to your system. 
But you don't really need to pull the image file to your system before you build, as Singularity recognizes URI beginning with ```shub://``` or ``` docker://```. 
Meaning you can use build to download layers from Docker Hub and assemble them into Singularity containers, which is what I will demonstrate here using a pre-built docker image that another member of our lab made and uploaded to docker hub. 
```
$ singularity build ldsc.simg docker://zijingliu/ldsc
```
[Here is the link to the docker image](https://hub.docker.com/r/zijingliu/ldsc). 
You can explore if interested, this image can be used to run a docker container as well using the commands provided on the page. 
This is only a basic example, there are many more ways you can build a singularity however that is not the focus on this documentation. More on building singularities can be found [here](https://singularity.lbl.gov/docs-build-container#creating---writable-images-and---sandbox-directories). 

I must stress that for most images, including the one in the example above, **you must mount your data into the container** when running it to be able to use it properly. Syntax to mounting and binding paths for docker containers and singularity containers are slightly different. You can find the relative documentations for mounting data for [docker container](https://docs.docker.com/engine/reference/commandline/run/) and [singularity containers](https://sylabs.io/guides/3.0/user-guide/bind_paths_and_mounts.html#:~:text=If%20enabled%20by%20the%20system,the%20host%20system%20with%20ease.) here. 
In the current case, we are trying to run singularity from HPC with nextflow, so the command for mounting data should be within the nextflow config file, which will be disected in a little more detail below. 

###### Creating the Nextflow process 
The above ldsc script when wrapped into a nextflow process, can be found in the "singularity_ldsc_NF_pbs_test.nf" file. 
There are a few things that I would like to clarify:
1. Original script is already calling python in bash so there is not need to treat this as a python script for Nextflow. 
Hence, no need to specify python versions etc. If you are trying to wrap python codes into nextflow, you can go to my other [repo](https://github.com/roxyisat-rex/nextflow_with_python/tree/master), I have also written a little guide for that, especially tagetted towards translating python and bash variables. 

2. For the channels, paths must be from where you have binded your data in the container. 
In the example, I have binded my input data (.bed and .bim) files into the "mnt" folder in the container by using ```runOptions``` in the nextflow config file. Therefore, as you can see in the .nf script, Path is from the singularity container. 
```
input_data1 = Channel.fromPath('/mnt/1000G.EUR.QC.1.bim')
```

###### Running your NF process in your singularity container

Usually running your NF processes with singularity containers is using the below codes. 
```
nextflow run <your script> -with-singularity [singularity image file]
```
However when you factor in HPC, then you must include the nextflow config file. The config file I have used to run the ".nf" script attached in this repo on PBS Pro is also attached under the name "nextflow.config". It is recommanded that this name is used for the config file because "when a pipeline script is launched Nextflow looks for a file named nextflow.config in the current directory and in the script base directory (if it is not the same as the current directory). Finally it checks for the file $HOME/.nextflow/config." 
In order to specify that the process/ pipeline needs to be ran with singularity, it should be specificed in the config file.  
```
process.container = '/rds/general/user/your_user_name/home/singularity_image_name.simg'
```
You must also include scope singularity in the config file.  
```
singularity {
  enabled = true 
  runOptions = "-B /rds/general/user/your_user_name/home/input_for_NF_ldsc:/mnt"
}
``` 
**Here in the runOptions settings, you will put down how/ where you want to mount and bind your data!** Or else, singularity will NOT be able to find your data and your process will not run successfully. You can see here, I have binded my input data for my NF script into the "mnt" folder of the singularity container. 
You can bind multiple directories at the same time as well, this should be described in more detail in the link for mounting and binding for singularity above. Simply put your commends for this in the runOptions settings. 
If this is a NF pipeline you are running, you can use ```cacheDir``` settings in scope singularity like such:  
```
cacheDir = "/rds/general/user/user_name/home/live/.singularity-cache"
``` 
This is a directory with all remote singularity images, and different singularities can be used for different processes. When using a computing cluster it must be a shared folder accessible to all computing nodes. There is also more on this Nextflow config file [page](https://www.nextflow.io/docs/latest/config.html#scope-singularity).

###### Potential errors and useful commends 

**PBS related**   
1. Failed to submit process to grid scheduler for execution.
You need to use scope executor to specify for PBS in the nextflow config file, ex:
```
executor {
    name = 'pbspro'
    queueSize = 50
    cpus = 1
    memory = '32 GB'
    }
``` 
2. PBS tells you to config for walltime or memory etc in a certain manner 
Configuration for wall time usually happenes in the .PBS file. However, my experience with nextflow with singularity is that you need to put the PBS config in the nextflow config file as well, ex: 
```
process {
  beforeScript = 'module load singularity'
  executor = 'pbspro'
  withName: singularity_test { 
  clusterOptions = '-l select=1:ncpus=1:mem=2gb'
  time = '1h'
  }
}
``` 
In clusterOptions as you can see, I have configed according to PBS requirements/ syntax. 

3. You also need to ```module load nextflow``` before running. This can either be in the nextflow config file (beforeScript settings, yes you can put multiple things there) or in the .PBS file before the ```nextflow run myscript.nf```. 

**Singularity related** 
1. container creation failed. mount input_data->/mnt error: while mounting input_data:mount source doesn't exist. 
Solution to this is to give the abosulte path for the directory you wish to mount. 

**Useful commends** 

Something I found particularly useful here is the command.
```
singularity exec -B docker_test:/mnt name_of_container.simg ls /mnt
```
This mounts the input directory to the mnt folder in the singularity container while running the container, and lets you view whether the mounting had been successful by listing all the contents of the mnt folder. Before you run your NF script full one, you may wish to check whether your singularity image is running ok and whether your data had been binded in the correct files this way. 

If you would like to view inside your container to see its contents use: 
```
singularity exec name_of_container.simg ls /
``` 
This lets you see what is really in the container. 

If you  use ```singularity shell singularity_test.simg``` and then use ```ls``` to try to view your container contents, you will not get an error message but you are not doing it correctly. ```Singularity shell``` creates an interactive shell with the container, and if you ```ls```, you probably get the full directory of your HPC home or full directory of where your singularity.simg is based, but this is not what is really inside your container. This is something to be aware of. 

If there are any questions or issues, feel free to raise an issue. Will try to see if I can be of any help. 
Best of luck! 
