#!/usr/bin/env bash
# This script is derived from the pipeline. It only implements functional annotation starting from a fasta and a GFF containing gene models from an external source.
# It assumes that docker is available, you have installed funannotate in your current environment and setup the databases as described in the docs.
# cmdoret, 20210624

# Exit upon error (-e) or use of unset variable (-u). Return value of a pipeline is the value of the last command to fail, or zero if all commands exit successfully (pipefail).
set -euo pipefail

function usage() {
	cat << EOS
Generate functional annotation for input gene models.
usage: $0 -f genome.fasta -g annotations.gff -s strain_name -o out_dir
EOS
}

while [[ "$#" -gt 0 ]]; do
	case $1 in
		-f|--fasta) FASTA="$2"; shift;;
		-g|--gff) GFF="$2"; shift;;
		-o|--out) OUT_DIR="$2"; shift;;
		-s|--strain) STRAIN="$2"; shift;;
		*) usage; exit 1;;
	esac
	shift
done

export EGGNOG_DATA_DIR="$PWD/tmp/emapper_db/"

# Generate interproscan annotations
funannotate iprscan -m docker -i "$FASTA" -c 12 -o "$OUT_DIR/iprscan.xml"
# Combine functional annotations from interpro, eggnog, phobius, Pfam, UniProtKB, MEROPS, CAZyme, and GO ontology.
funannotate annotate \
	--gff "$GFF" \
	--fasta "$FASTA" \
	--species "Acanthamoeba castellanii" \
	--strain "$STRAIN" \
	-o "$OUT_DIR" \
	--cpus 12 \
	--sbt "docs/template_${STRAIN}.sbt" \
	--iprscan "${OUT_DIR}/iprscan.xml"
