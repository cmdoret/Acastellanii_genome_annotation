# Predict genes using RNAseq data with AUGUSTUS and BRAKER via funannotate.

# Use transcriptome assembly and PASA to generate gene structures which will
# be given as evidence to funannotate predict.
rule train:
  input:
    fq = lambda w: units.loc[units.strain == w.strain, 'fq1'].tolist()[0],
    fa = join(TMP, 'clean', '03_{strain}_masked.fa')
  output: directory(join(TMP, 'train', '{strain}'))
  threads: CPUS
  shell:
    """
    funannotate train \
          -i {input.fa} \
		      -s {input.fq} \
          -o {output} \
		      --cpus {threads} \
		      --strain {wildcards.strain} \
		      --species "Acanthamoeba castellanii" \
		      --memory 24G \
		      --stranded R
    """

rule predict:
  input:
    bam = join(TMP, 'STAR', '{strain}_rna.bam'),
    ref = join(TMP, 'clean', '03_{strain}_masked.fa')
  output: directory(join(TMP, 'predict', '{strain}', 'predict_results'))
  threads: CPUS
  params:
    predict_dir = join(TMP, 'predict', '{strain}', 'predict_results')
  shell:
    """
    funannotate predict -i {input.ref} \
                        --species "Acanthamoeba castellanii" \
			--organism other \
                        --strain {wildcards.strain} \
                        --rna_bam {input.bam} \
                        -o {params.predict_dir} \
                        --cpus {threads} \
                        --busco_db eukaryota \
                        --min_training_model 100 \
                        --ploidy 2 \
                        --optimize_augustus
    """

# Run functional annotation using phobius
rule remote:
  input: join(TMP, 'predict', '{strain}', 'predict_results')
  output: touch(join(TMP, '{strain}_remote.done'))
  shell:
    """
    funannotate remote -m phobius -e cmatthey@pasteur.fr -i {input}
    """

# Run functional annotation using interproscan
rule interproscan:
  input: join(TMP, 'predict', '{strain}', 'predict_results')
  output: join(TMP, '{strain}_interproscan.xml')
  shell:
    """
    funannotate iprscan -m docker --cpus 12 -i {input} -o {output}
    """



