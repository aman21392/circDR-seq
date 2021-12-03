# nano_circ
nano_circ is a pipeline to detect circRNA from naopore Direct RNA sequencing. It uses backsplice target fasta sequence to detect the circRNA in the nanopore data.

# Create backsplice target library
The linear target sequence is just required to create the backsplice target sequence with the help of script backsplice.sh. 

`sh backsplice.sh test_data/circBase_3000_linear_sequence.fa`

# Detection of circRNA through DRS
Run the script nano_circ.sh to detect the circRNA in Nanopore data. First, convert the nanopore data from fastq to fasta file. To use the pblat and csvtk first untar it and make a executable.

`sh nano_circ.sh test_data/circBAse_3000sequence.fa.backsplice.100bp.fa test_data/test_read.fa`

$1= target backsplice fasta library of 100bp (which comes from backsplice.sh command).

$2= Query fasta read.

The main output file of this script is $overlap.mismatch.gap.psl and $count.txt file.

# calculation of Precision and Recall
Run the script precision_recall.sh to know the precision and recall of the pipeline we did for circBase circRNA. So its better to check in circBase.

`sh precision_recall.sh $query.overlap.mismatch.gap.psl circBAse_3000sequence.fa.backsplice.fa test_data/test_read.fa`

$1=output of nano_circ.sh script (i.e. $query.overlap.mismatch.gap.psl)

$2= full backsplice fasta sequence (comes from the backsplice.sh script)

$3= Query fasta read

# Test data
In this folder there is query file i.e. test_read.fa file which is the simulated file which get from running the NanoSim pipeline. The another file i.e. the circbase_spliced_seq_backsplice_100bp.fa which is the target test file which used in pblat. 

# Generate the simulated read
  You can find complete pipeline for nanosim on there github page. https://github.com/bcgsc/NanoSim . For generation of circRNA simulated reads first we have to convert the target linear fasta file into backsplice fasta file and then used genome mode in the NanoSim for genration of simulated reads. In the `-i` option we have to give the nanopore fasta file(ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR132/005/SRR13225505/SRR13225505_1.fastq.gz).
  Conversion of fastq to fasta file command:
  `seqtk seq -A input.fastq >output.fa` 

So 1st step is Characterization stage in genome mode:

NanoSim/src/read_analysis.py genome -i Input read for training -rg full backsplice fasta sequence -o ./backsplice

So 2nd step is Simulation stage in genome mode:

NanoSim/src/simulator.py genome -rg full backsplice fasta sequence -c ./backsplice -n -o ./backsplice_simulate
