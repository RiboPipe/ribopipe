#!/bin/bash
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH -o slurmjob-%j
#SBATCH --partition=kingspeak

#Create reference folder
mkdir human_reference_star
cd human_reference_star
mkdir source_files
cd source_files
#Download chromosome fasta files
for CHR in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 X Y MT; do
  curl -O ftp://ftp.ensembl.org/pub/release-94/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.chromosome.${CHR}.fa.gz; done

#Download GTF
wget ftp://ftp.ensembl.org/pub/release-94/gtf/homo_sapiens/Homo_sapiens.GRCh38.94.gtf.gz

#Download ncrna fasta
wget ftp://ftp.ensembl.org/pub/release-94/fasta/homo_sapiens/ncrna/Homo_sapiens.GRCh38.ncrna.fa.gz

#Unzip files
gzip -d *.gz

#make copy of gtf in main folder
cp Homo_sapiens.GRCh38.94.gtf ../transcripts.gtf
cd ../

#Remove any ncrna from gtf file
ribopipe truncate -i transcripts.gtf

#Make refFlat file
#conda install -y -c bioconda ucsc-gtftogenepred
gtftogenepred transcripts.gtf transcripts_refFlat.txt.tmp
awk '{print $1 "\t" $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7 "\t" $8 "\t" $9 "\t" $10}' transcripts_refFlat.txt.tmp > transcripts_refFlat.txt
rm transcripts_refFlat.txt.tmp

gtftogenepred transcripts_coding.gtf transcripts_coding_refFlat.txt.tmp
awk '{print $1 "\t" $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7 "\t" $8 "\t" $9 "\t" $10}' transcripts_coding_refFlat.txt.tmp > transcripts_coding_refFlat.txt
rm transcripts_coding_refFlat.txt.tmp

gtftogenepred transcripts_truncated.gtf transcripts_truncated_refFlat.txt.tmp
awk '{print $1 "\t" $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7 "\t" $8 "\t" $9 "\t" $10}' transcripts_truncated_refFlat.txt.tmp > transcripts_truncated_refFlat.txt
rm transcripts_truncated_refFlat.txt.tmp

#metagene prep
metagene generate transcripts_cds_start --landmark cds_start --annotation_files transcripts.gtf --downstream 200

#Build
mkdir genome
STAR --runThreadN 16 --runMode genomeGenerate --genomeDir genome/ --genomeFastaFiles source_files/*dna.chromosome.*.fa --sjdbGTFfile transcripts.gtf --genomeSAindexNbases 15

mkdir ncrna
STAR --runThreadN 16 --runMode genomeGenerate --genomeDir ncrna/ --genomeFastaFiles source_files/Homo_sapiens.GRCh38.ncrna.fa --genomeSAindexNbases 12

cd ../
