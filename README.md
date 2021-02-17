# Nextflow_with_Singularity_on_PBS
This is a guide for beginners to use Nextflow with Singularity on the PBS cluster (it could be applicable to other HPC too with just a little modification)
This guide will be seperated into the below sections:
1. Prerequisites 
2. A little background on the example 
3. BUilding a singularity container 
4. Creating the nextflow process 
5. Running NF process in singularity container 
6. Potential errors and useful commands 


- prerequisites 
Singularity needs to be installed.
Since this is a guide for singularity to be used with HPC, whether singularity is installed on the HPC you use depends on your institution. 
Normally you do not have the admin privlige to install singularity, remember to ask a member of your HPC support staff, make sure it's installed. 
For Imperial College London 'Singularity' is already installed on our PBS pro cluster. 

To use, 

```
module load singularity
``` 


- Example
Here instead of the easy "Hello world" example. I will be using a slightly more difficult example with potentially more operational.  
This is a part of the LD score estimation for LD scoreregression, by Dr Finucane and Dr Bulik-Sullivan. 

LDSC is a method to "accurately estimate genetic heritability and its enrichment in both homogenous and admixed populations with summary statistics 
and in-sample LD estimates". 
[This] (https://github.com/bulik/ldsc/wiki/LD-Score-Estimation-Tutorial)is the link to the LDSC github repositry if you wish to learn more. You do not really need to know LDSC to understand this tutorial, it is just to provide more contexts. 

Here we use a ".bed" file in combination with a ".bim" file from the 1000 Genome project to create a ".annot.gz" file. 
```
python make_annot.py \
		--bed-file Brain_DPC_H3K27ac.bed \
		--bimfile 1000G.EUR.QC.22.bim \
		--annot-file Brain_DPC_H3K27ac.annot.gz  
```
- Building Singulairy container 

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
In the current case, where we are trying to run singularity from HPC with nextflow, so the command for mounting data should be within the nextflow config file, which will be disected in a little more detail below. 

- Creating the Nextflow process 
The above ldsc script when wrapped into a nextflow process, can be found in the "singularity_ldsc_NF_pbs_test.nf" file. 
There are a few things that I would like to clarify:
1. Original script is already calling python in bash so there is not need to treat this as a python script for Nextflow. 
Hence, no need to specify python versions etc. If you are trying to wrap python codes into nextflow, you can go to my other [repo](https://github.com/roxyisat-rex/nextflow_with_python/tree/master), I have also written a little guide for that, especially tagetted towards translating python and bash variables. 

2. For the channels, paths must be from where you have mounted your data in the container. 
In the example, I have mounted my input data (.bed and .bim) files into the "mnt" folder in the container by using ```runOptions``` in the nextflow config file. Therefore, 

- Running your NF process in your singularity container 

- Nextflow config file, detailed explanation of potential errors 


