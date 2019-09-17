# Last step of the annotation pipeline combining informations from all sources.

rule annotate:
  input: 
    remote_flag = join(TMP, 'remote_{strain}.done'),
    interproscan = join(TMP, 'interproscan', '{strain}'),
    eggnog_mapper = join(TMP, 'eggnog_mapper', '{strain}')
  output: directory(join(OUT, '{strain}'))
  params:
    predict_dir = lambda w: join(TMP, 'predict', f'{w.strain}', 'predict_results'),
    id = lambda w: f"Acanthamoeba_castellanii_{w.strain}",
    eggnog_fname = lambda w: f'{w.strain}.emapper.annotations',
    ipr_fname = lambda w: f'Acanthamoeba_castellanii_{w.strain}',
    phobius_out = lambda w: join(TMP, 'predict', f'{w.strain}', 'annotate_misc', 'phobius.results.txt')
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
      --eggnog {input.eggnog_mapper}/{params.eggnog_fname} \
      --busco_db eukaryota \
      --out {output} \
      --phobius {params.phobius_out} \
      --iprscan {input.interproscan}/{params.ipr_fname}
    """
