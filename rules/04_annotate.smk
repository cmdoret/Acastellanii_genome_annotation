# Last step of the annotation pipeline combining informations from all sources.

rule annotate:
  input: 
    remote_flag = join(TMP, 'remote_{strain}.done'),
    interproscan = join(TMP, 'interproscan', '{strain}'),
    #eggnog_mapper = join(TMP, 'eggnog_mapper', '{strain}')
  output: directory(join(OUT, '{strain}'))
  params:
    predict_dir = lambda w: join(TMP, 'predict', f'{w.strain}', 'predict_results', 'predict_results'),
    id = lambda w: f"Acanthamoeba_castellanii_{w.strain}",
    eggnog_fname = lambda w: f'{w.strain}.emapper.annotations',
    ipr_fname = lambda w: f'Acanthamoeba_castellanii_{w.strain}.proteins.fa.xml',
    phobius_out = lambda w: join(TMP, 'predict', f'{w.strain}', 'predict_results', 'annotate_misc', 'phobius.results.txt'),
    sbt = lambda w: config['ncbi_submit_template'][f'{w.strain}']
  threads: CPUS
  shell:
    """
    funannotate annotate \
      --gff {params.predict_dir}/{params.id}.gff3 \
      --fasta {params.predict_dir}/{params.id}.scaffolds.fa \
      --cpus {threads} \
      -s 'Acanthamoeba castellanii' \
      --busco_db eukaryota \
      --out {output} \
      --phobius {params.phobius_out} \
      --iprscan {input.interproscan}/{params.ipr_fname} \
      --sbt {params.sbt}
    """
