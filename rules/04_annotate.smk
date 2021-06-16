# Last step of the annotation pipeline combining informations from all sources.

rule annotate:
  input: 
    remote_flag = join(TMP, '{strain}_remote.done'),
    interproscan = join(TMP, '{strain}_interproscan.xml'),
    eggnog_db_flag = join(TMP, 'emapper_db', 'eggnog.done')
  output: directory(join(OUT, '{strain}'))
  params:
    predict_dir = lambda w: join(TMP, 'predict', f'{w.strain}', 'predict_results', 'predict_results'),
    id = lambda w: f"Acanthamoeba_castellanii_{w.strain}",
    sbt = lambda w: config['ncbi_submit_template'][f'{w.strain}']
  threads: CPUS
  shell:
    """
    export EGGNOG_DATA_DIR=$PWD/$(dirname {input.eggnog_db_flag})
    funannotate annotate \
      -i {params.predict_dir} \
      --iprscan {input.interproscan} \
      --cpus {threads} \
      -s 'Acanthamoeba castellanii' \
      --busco_db eukaryota \
      --sbt {params.sbt}

    cp -r {params.predict_dir}/../annotate_results {output}
    """
