#!/bin/bash
#splitbytaxa in=<infile> out=<outfile>

usage(){
echo "
Written by Brian Bushnell
Last modified December 15, 2015

Description:   Splits sequences according to their taxonomy,
as determined by the sequence name.  Sequences should
be labeled with a gi number, NCBI taxID, or species name.

Usage:  splitbytaxa.sh in=<input file> out=<output pattern> tree=<tree file> table=<table file> level=<name or number>

Input may be fasta or fastq, compressed or uncompressed.


Standard parameters:
in=<file>       Primary input.
out=<file>      Output pattern; must contain % symbol.
overwrite=f     (ow) Set to false to force the program to abort rather than
                overwrite an existing file.
showspeed=t     (ss) Set to 'f' to suppress display of processing speed.
ziplevel=2      (zl) Set to 1 (lowest) through 9 (max) to change compression
                level; lower compression is faster.

Processing parameters:
level=phylum    Taxonomic level, such as phylum.  Filtering will operate on
                sequences within the same taxonomic level as specified ids.
tree=           A taxonomic tree made by TaxTree, such as tree.taxtree.gz.
table=          A table translating gi numbers to NCBI taxIDs.
                Only needed if gi numbers will be used.
* Note *
Tree and table files are in /global/projectb/sandbox/gaag/bbtools/tax
For non-Genepool users, or to make new ones, use taxtree.sh and gitable.sh

Java Parameters:
-Xmx            This will be passed to Java to set memory usage, overriding the program's automatic memory detection.
                -Xmx20g will specify 20 gigs of RAM, and -Xmx200m will specify 200 megs.  The max is typically 85% of physical memory.

Please contact Brian Bushnell at bbushnell@lbl.gov if you encounter any problems.
"
}

pushd . > /dev/null
DIR="${BASH_SOURCE[0]}"
while [ -h "$DIR" ]; do
  cd "$(dirname "$DIR")"
  DIR="$(readlink "$(basename "$DIR")")"
done
cd "$(dirname "$DIR")"
DIR="$(pwd)/"
popd > /dev/null

#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
CP="$DIR""current/"

z="-Xmx4g"
z2="-Xms4g"
EA="-ea"
set=0

if [ -z "$1" ] || [[ $1 == -h ]] || [[ $1 == --help ]]; then
	usage
	exit
fi

calcXmx () {
	source "$DIR""/calcmem.sh"
	parseXmx "$@"
	if [[ $set == 1 ]]; then
		return
	fi
	freeRam 1000m 84
	z="-Xmx${RAM}m"
	z2="-Xms${RAM}m"
}
calcXmx "$@"

splitbytaxa() {
	if [[ $NERSC_HOST == genepool ]]; then
		module unload oracle-jdk
		module load oracle-jdk/1.7_64bit
		module load pigz
	fi
	local CMD="java $EA $z -cp $CP tax.SplitByTaxa $@"
	echo $CMD >&2
	eval $CMD
}

splitbytaxa "$@"
