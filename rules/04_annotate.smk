# Last step of the annotation pipeline combining informations from all sources.

rule annotate:
  input: join(TMP, 'annotate_{strain}.done')
  output: directory(join(OUT, '{strain}'))
  params:
    predict_dir = lambda w: join(TMP, 'predict', f'{w.strain}'),
    id = lambda w: f"Acanthamoeba_castellanii_{w.strain}"
  threads: CPUS
  singularity: config['containers']['funannotate']
  message:
    """
    NOTE: For this last step to work, you need to run eggNOG mapper separately and place
    the output file in {params.predict_dir}/emapper_{wildcards.strain}.annotations
    """
  shell:
    """
    funannotate annotate \
      --gff {params.predict_dir}/{params.id}.gff3 \
      --fasta {params.predict_dir}/{params.id}.scaffolds.fa \
      --cpus {threads} \
      -s 'Acanthamoeba castellanii' \
      --eggnog {params.predict_dir}/emapper{wildcards.strain}.annotations \
      --busco_db eukaryota \
      --out {output} \
      --phobius {params.predict_dir}/annotate_misc/phobius.results.txt \
      --iprscan {params.predict_dir}/annotate_misc/iprscan.xml
    """
