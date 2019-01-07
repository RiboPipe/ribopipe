#!/bin/sh

#For local install of conda on an HPC, etc
cd $HOME

# Start with a clean env
module purge

# Get the latest anaconda3 distro
wget https://repo.anaconda.com/archive/Anaconda3-5.3.0-Linux-x86_64.sh

# Change the permissions -> make it executable
chmod 700 Anaconda3-5.3.0-Linux-x86_64.sh

# Run install
./Anaconda3-5.3.0-Linux-x86_64.sh

#This will launch an interactive script. Follow along, add conda to $PATh via .bashrc
#Exit out of terminal and log in again

#Install dependencies
conda install -y -c bioconda ucsc-gtftogenepred setuptools fastqc fastx_toolkit htseq picard samtools hisat2 star bedtools deeptools scipy plastid pandas numpy matplotlib seaborn pysam=0.14 fastp

pip install multiqc

sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
echo "export PATH='$(brew --prefix)/bin:$(brew --prefix)/sbin'":'"$PATH"' >> ~/.bash_profile
brew install git-lfs
git lfs install
