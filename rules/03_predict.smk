# Predict genes using RNAseq data with AUGUSTUS and BRAKER via funannotate.

rule predict:
  input:
    bam = join(TMP, 'STAR', '{strain}_rna.bam'),
    ref = join(TMP, 'clean', '03_{strain}_masked.fa')
  output: directory(join(TMP, 'predict', '{strain}'))
  threads: CPUS
  singularity: "docker://cmdoret/funannotate:latest"
  shell:
    """
    funannotate predict -i {input.ref} \
                        --species "Acanthamoeba castellanii" \
                        --strain {wildcards.strain} \
                        --rna_bam {input.bam} \
                        -o {output} \
                        --cpus {threads} \
                        --busco_db eukaryota \
                        --min_training_model 100 \
                        --ploidy 2 \
                        --optimize_augustus
    """

rule remote:
  input: join(TMP, 'predict', '{strain}')
  output: join(TMP, 'annotate_{strain}.done')
  shell:
    """
    funannotate remote -m interproscan phobius -e cmatthey@pasteur.fr -i {input}
    """
