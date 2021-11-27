# circ_nano
circ_nano is a pipeline to detect circRNA from naopore Direct RNA sequencing. It uses backsplice target fasta sequence to detect the circRNA in the nanopore data.

# Create backsplice target library
To create the backsplice target sequence with the help of script backsplice.sh. The linear target sequence just you have to given.

`sh backsplice.sh`

# Detection of circRNA through DRS
Run the script circ_nano.sh to detect the circRNA in Nanopore data. Convert the nanopore data from fastq to fasta file. The blat take query fasta file so we have to convert it into fasta format.  

`sh circ_nano.sh`
