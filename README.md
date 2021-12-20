# nano_circ
nano_circ is a pipeline to detect circRNA from naopore Direct RNA sequencing. It uses backsplice target fasta sequence to detect the circRNA in the nanopore data.

# Create backsplice target library
The linear target sequence is just required to create the backsplice target sequence with the help of script backsplice.sh. 

`sh backsplice.sh ./test_data/circBase_3000_linear_sequence.fa`

# Exonic circRNA library
For detecting the novel circRNA, first create the all possible combination of exons library in a gene. So for making exonic library we need transcript id file; and a file which contain transcript id, exon no.,exon id, coordinates;genome.fa file and the function_code.js file which present in the exonic circRNA library file.

`bash exonic_forward_gene.sh $1 $2 $3 $4`

`bash exonic_reverse_gene.sh $1 $2 $3 $4`

$1= bed file containg coordinates,transcript id,exon id,exon no.

$2= transcript id file

$3= genome fasta file

$4= function_code.js (present in script file)

# Detection of circRNA through DRS
Run the script nano_circ.sh to detect the circRNA in Nanopore data. First, convert the nanopore data from fastq to fasta file. To use the pblat and csvtk first untar it and make a executable.

`sh nano_circ.sh backsplice.100bp.fa ./test_data/test_read.fa`

$1= target backsplice fasta library of 100bp (which comes from backsplice.sh command).

$2= Query fasta read.

The main output file of this script is final.psl and $query.count.txt file.

# circRNA list preparation
So after run the nano_circ.sh pipeline the output of count file utilized for making the list of circRNA with count and coordinates. 3scripts are there to form a complete list of circRNA:
1st script is to make a list of circRNA from the circBase and circatlas libary:

`sh databasecircRNA.sh $1 $2 $3 $4`

$1=output file of circBAse library

$2=circBase bed file containg coordinates, gene name, circBase id 

$3=output file of circatlas library 

$4=circatlas bed file containg coordinates, gene name, circatlas id

# calculation of Precision and Recall
Run the script precision_recall.sh to know the precision and recall of the pipeline we did for circBase circRNA. So its better to check in circBase.

`sh precision_recall.sh final.psl backsplice.fa ./test_data/test_read.fa`

$1=output of nano_circ.sh script (i.e. $query.overlap.mismatch.gap.psl)

$2= full backsplice fasta sequence (comes from the backsplice.sh script)

$3= Query fasta read

# Test data
In this folder there is query file i.e. test_read.fa file which is the simulated file which get from running the NanoSim pipeline. The another file i.e. the circBase_3000_linear_sequence.fa which is used to generate the backsplice library. 

# Generate the simulated read
You can find complete pipeline for nanosim on their github page. https://github.com/bcgsc/NanoSim . For generation of circRNA simulated reads first we have to convert the target linear fasta file into backsplice fasta file and then use genome mode in the NanoSim for generation of simulated reads. In the `-i` option we have to give the nanopore fasta file. The dataset from the paper "Nanopore sequencing of brain-derived full-length circRNAs reveals circRNA-specific exon usage, intron retention and microexons" is used in the example below.

`wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR132/005/SRR13225505/SRR13225505_1.fastq.gz`

`gunzip SRR13225505_1.fastq.gz`

Conversion of fastq to fasta file command:

`seqtk seq -A SRR13225505_1.fastq > SRR13225505.fa` 

So 1st step is Characterization stage in genome mode:

`/home/aclab/apps/NanoSim/src/read_analysis.py genome -i SRR13225505.fa -rg backsplice.fa -o ./backsplice_out`

So 2nd step is Simulation stage in genome mode:

`/home/aclab/apps/NanoSim/src/simulator.py genome -rg backsplice.fa -c ./backsplice_out -n 12000000 -o ./backsplice_simulate`
