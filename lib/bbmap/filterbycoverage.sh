#!/bin/bash
#filterbycoverage in=<infile> out=<outfile>

function usage(){
echo "
Written by Brian Bushnell
Last modified May 3, 2016

Description:  Filters an assembly by contig coverage.

Usage:  filterbycoverage.sh in=<assembly> cov=<coverage stats> out=<filtered assembly> mincov=5

in2 and out2 are for paired reads and are optional.
If input is paired and there is only one output file, it will be written interleaved.


Parameters:
in=<file>        File containing input assembly.
cov=<file>       File containing coverage stats generated by pileup.
cov0=<file>      Optional file containing coverage stats before normalization.
out=<file>       Destination of clean output assembly.
outd=<file>      (outdirty) Destination of dirty output containing only removed contigs.
minc=5           (mincov) Discard contigs with lower average coverage.
minp=40          (minpercent) Discard contigs with a lower percent covered bases.
minr=0           (minreads) Discard contigs with fewer mapped reads.
minl=1           (minlength) Discard contigs shorter than this (after trimming).
trim=0           (trimends) Trim the first and last X bases of each sequence.
ratio=0          If cov0 is set, contigs will not be removed unless the coverage ratio (of cov to cov0) is at least this (0 disables it).
ow=t             (overwrite) Overwrites files that already exist.
app=f            (append) Append to files that already exist.
zl=4             (ziplevel) Set compression level, 1 (low) to 9 (max).

Java Parameters:
-Xmx             This will be passed to Java to set memory usage, overriding the program's automatic memory detection.
                 -Xmx20g will specify 20 gigs of RAM, and -Xmx200m will specify 200 megs.  The max is typically 85% of physical memory.

To read from stdin, set 'in=stdin'.  The format should be specified with an extension, like 'in=stdin.fq.gz'
To write to stdout, set 'out=stdout'.  The format should be specified with an extension, like 'out=stdout.fasta'

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

z="-Xmx800m"
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
	freeRam 800m 84
	z="-Xmx${RAM}m"
	z2="-Xms${RAM}m"
}
calcXmx "$@"

function filterbycoverage() {
	if [[ $NERSC_HOST == genepool ]]; then
		module unload oracle-jdk
		module unload samtools
		module load oracle-jdk/1.7_64bit
		module load pigz
		module load samtools
	fi
	local CMD="java $EA $z -cp $CP jgi.FilterByCoverage $@"
	echo $CMD >&2
	eval $CMD
}

filterbycoverage "$@"
