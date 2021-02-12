#!/usr/bin/env nextflow

input_data1 = Channel.fromPath('/mnt/1000G.EUR.QC.1.bim')
input_data2 = Channel.fromPath('/mnt/lifted_EN01.bed')

process singularity_test {
    echo true
 
    input:
    file input_data1
    file input_data2 

    
     "python /ldsc/make_annot.py --bed-file ${input_data2} --bimfile ${input_data1} --annot-file /rds/general/user/xyz16/home/annot_singularity_test/EN01_singularity_test.annot.gz"
    
 
} 