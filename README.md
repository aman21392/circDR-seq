# nano_circ
circ_nano is a pipeline to detect circRNA from naopore Direct RNA sequencing. It uses backsplice target fasta sequence to detect the circRNA in the nanopore data.

# Create backsplice target library
The linear target sequence is just required to create the backsplice target sequence with the help of script backsplice.sh. 

`sh backsplice.sh`

# Detection of circRNA through DRS
Run the script nano_circ.sh to detect the circRNA in Nanopore data. First, convert the nanopore data from fastq to fasta file. To use the pblat first untar it.

`sh nano_circ.sh $1 $2`

$1= target fasta library which comes from backsplice.sh command

$2= query fasta file
