# circDR-seq
circDR-seq is a pipeline to detect circRNA from nanopore Direct RNA sequencing. It uses backsplice target fasta sequence to search the circRNA in the nanopore data.

# Required Softwares
Bedtools ( v2.27.1)

pblat (http://icebert.github.io/pblat, http://icebert.github.io/pblat-cluster)

csvtk (https://github.com/shenwei356/csvtk)

bbmap:- dedupe.sh (it is used in making virtual exonic library)(https://sourceforge.net/projects/bbmap/)

These all software are executable to path. Other version of softwares might also work.

# To generate backsplice junction library using Database. (eg. circBase and circAtlas were used in this study)
The linear target sequence is required to create the backsplice target sequence with the help of script backsplice.sh. 

`sh backsplice.sh ./test_data/circBase_3000_linear_sequence.fa`

# Virtual Exonic circRNA library
For detecting the novel circRNA, first, create the all possible combination of exons library in a gene. So for making an exonic library, we need a transcript id file; and a file that contains transcript id, exon no., exon id, coordinates; genome.fa file and the function_code.js file which presents in the exonic circRNA library file.
This script gives the 100bp virtual exonic circRNA library.

Genes on forward strand of the chromosomes

`bash exonic_forward_gene.sh $1 $2 $3 $4`

Genes on reverse strand of the chromosomes

`bash exonic_reverse_gene.sh $1 $2 $3 $4`

$1= bed file containing coordinates,transcript id,exon id,exon no. in the given order (forward gene bed file/reverse gene bed file)

$2= Ensembl transcript id file in text or bed format. (forward/reverse transcript id file)

$3= genome fasta file (hg 38 human genome file)

$4= function_code.js (Provided in the script file)

cat uniq.forward.exon.fa uniq.reverse.exon.fa >exon.circRNA.library.fa (uniq.forward.exon.fa= output of exonic_forward_gene.sh), (uniq.reverse.exon.fa= output of exonic_reverse_gene.sh )

exon.circRNA.library.fa is the final fasta file of virtual exonic backsplice library. 

# Detection of circRNA through DRS
Run the script circDR-seq.sh to detect the circRNA in Nanopore data. First, nanopore data needs to be converted from fastq to fasta file. To use the `pblat` and `csvtk`.

`sh circDR-seq.sh $1 ./test_data/$2`

$1= Provide target as backsplice fasta file or use backsplice.100bp.fa for test run. Which should be obtained from backsplice.sh command.

$2= Provide query as fasta file or use test_read.fa for test run.

The main output file of this script is output.psl and $query.count.txt file.

# circRNA list preparation
So after run the circDR-seq.sh pipeline the output of count file utilized for making the list of circRNA with count and coordinates. 3 scripts are there to form a complete list of circRNA:
1st script is to make a list of circRNA from the circBase and circatlas libary:

`sh databasecircRNA.sh $1 $2 $3 $4`

$1=output file of circBAse library 

$2=circBase bed file containg coordinates, gene name, circBase id 

$3=output file of circatlas library 

$4=circatlas bed file containg coordinates, gene name, circatlas id

2nd script is to make a list of circRNA from the exonic library:

`sh 20exon.coord.sh $1 $2 $3 $4 $5`

$1= output file of exonic library from circDR-seq.sh (i.e. output.psl)

$2= forward gene transcript id file

$3= reverse gene transcript id file

$4= transcript id and gene name file (1st column is transcript id , 2nd column is gene name )

$5= database file(circBase and circatlas)(6 column file: 1st 3 are coordinate, 4th gene name, 5th circBase id and 6th circAtlas id)

3rd script is to compile the result of databasecircRNA.sh and 20exon.coord.sh script 

`sh circRNA.list.sh $1 $2`

$1= output of databasecircRNA.sh

$2= output of 20exon.coord.sh

Then the final output of this script is complete.list.circRNA.txt.

# calculation of Precision and Recall
Run the script precision_recall.sh to know the precision and recall of the pipeline we did for circBase circRNA. So its better to check in circBase.

`sh precision_recall.sh output.psl backsplice.fa ./test_data/test_read.fa`

$1=output of circDR-seq.sh script (i.e. output.psl)

$2= full backsplice fasta sequence (comes from the backsplice.sh script)

$3= Query fasta read

# Test data
In this folder there is query file i.e. test_read.fa file which is the simulated file which get from running the NanoSim pipeline. The another file i.e. the circBase_3000_linear_sequence.fa which is used to generate the backsplice library. circBase_3000_linear_sequence.fa

# Generate the simulated read
You can find complete pipeline for nanosim on their github page (https://github.com/bcgsc/NanoSim). For generation of circRNA simulated reads first we have to convert the target linear fasta file into backsplice fasta file and then use genome mode in the NanoSim for generation of simulated reads. In the `-i` option we have to give the nanopore fasta file. The dataset from the paper "Nanopore sequencing of brain-derived full-length circRNAs reveals circRNA-specific exon usage, intron retention and microexons" is used in the example below.

`wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR132/005/SRR13225505/SRR13225505_1.fastq.gz`

`gunzip SRR13225505_1.fastq.gz`

Conversion of fastq to fasta file command:

`seqtk seq -A SRR13225505_1.fastq > SRR13225505.fa` 

So 1st step is Characterization stage in genome mode:

`NanoSim/src/read_analysis.py genome -i SRR13225505.fa -rg backsplice.fa -o ./backsplice_out`

So 2nd step is Simulation stage in genome mode:

`NanoSim/src/simulator.py genome -rg backsplice.fa -c ./backsplice_out -n 12000000 -o ./backsplice_simulate`
