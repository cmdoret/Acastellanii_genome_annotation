#!/usr/bin/env bash
# This script is derived from the pipeline. It only implements functional annotation starting from a fasta and a GFF containing gene models from an external source.
# It assumes docker is available, you have installed funannotate in your current environment and setup the databases as described in the docs.
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
mkdir -p "$OUT_DIR"

# Extract protein fasta from genome + gff and remove stop codons
#funannotate util gff2prot --no_stop -g "$GFF" -f "$FASTA" | sed 's/\*//g' > "${OUT_DIR}/proteins.fa"
# Generate interproscan annotations
#funannotate iprscan -m docker -i "${OUT_DIR}/proteins.fa" -c 12 -o "${OUT_DIR}/iprscan.xml"
# Run phobius locally without funannotate on proteins with trimmed stop codons.
# If fd and seqkit are available, phobius is run in parallel on each protein
if command -v fd seqkit &> /dev/null; then
	seqkit split -i -O "${OUT_DIR}/split_prots" "${OUT_DIR}/proteins.fa"
	mkdir -p "${OUT_DIR}/split_phobius"
	fd . "${OUT_DIR}/split_prots/" \
		-x bash -c "phobius.pl -short {} > ${OUT_DIR}/split_phobius/{/.}.tsv"
	cat "${OUT_DIR}/split_phobius/"*tsv > "${OUT_DIR}/phobius.tsv"
else
	phobius.pl -short "${OUT_DIR}/proteins.fa" > "${OUT_DIR}/phobius.tsv"
fi

# Combine functional annotations from interpro, eggnog, phobius, Pfam, UniProtKB, MEROPS, CAZyme, and GO ontology.
funannotate annotate \
	--gff "$GFF" \
	--fasta "$FASTA" \
	--species "Acanthamoeba castellanii" \
	--strain "$STRAIN" \
	-o "$OUT_DIR" \
	--cpus 12 \
	--sbt "docs/template_${STRAIN}.sbt" \
	--iprscan "${OUT_DIR}/iprscan.xml" \
	--phobius "${OUT_DIR}/phobius.tsv"
