# Nextflow_with_Singularity_on_PBS
This is a guide for beginners to use Nextflow with Singularity on the PBS cluster (it could be applicable to other HPC too with just a little modification)
This guide will be seperated into the below sections:
1. 
2.
3.
4. 
5. 


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
https://github.com/bulik/ldsc/wiki/LD-Score-Estimation-Tutorial
This is the link to the LDSC github repositry if you wish to learn more. You do not really need to know LDSC to understand this tutorial, it is just to provide more contexts. 

Here we use a ".bed" file in combination with a ".bim" file from the 1000 Genome project to create a ".annot.gz" file. 
```
python make_annot.py \
		--bed-file Brain_DPC_H3K27ac.bed \
		--bimfile 1000G.EUR.QC.22.bim \
		--annot-file Brain_DPC_H3K27ac.annot.gz  
```




- Building Singulairy container 

https://hub.docker.com/r/zijingliu/ldsc 

Singularities can be built using docker images. Here I have created singularity using 

- Creating the Nextflow process 



- Running your NF process in your singularity container 

- Nextflow config file, detailed explanation of potential errors 


