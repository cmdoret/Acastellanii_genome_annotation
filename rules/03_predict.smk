# Predict genes using RNAseq data with AUGUSTUS and BRAKER via funannotate.

rule export_augustus_config:
  output: directory(join('tmp', 'augustus', '{strain}', 'config'))
  shell:
    """
    mkdir -p {output}
    cp -r /home/linuxbrew/augustus/config/* {output}
    """


rule predict:
  input:
    bam = join(TMP, 'STAR', '{strain}_rna.bam'),
    ref = join(TMP, 'clean', '03_{strain}_masked.fa'),
    aug = join('tmp', 'augustus', '{strain}', 'config')
  output: directory(join(TMP, 'predict', '{strain}', 'predict_results'))
  threads: CPUS
  params:
    predict_dir = join(TMP, 'predict', '{strain}', 'predict_results')
  shell:
    """
    funannotate predict -i {input.ref} \
                        --AUGUSTUS_CONFIG_PATH={input.aug} \
                        --species "Acanthamoeba castellanii" \
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
  output: touch(join(TMP, 'remote_{strain}.done'))
  shell:
    """
    funannotate remote -m phobius -e cmatthey@pasteur.fr -i {input}
    """


# Run functional annotation using interproscan
rule interproscan:
  input: join(TMP, 'predict', '{strain}', 'predict_results')
  output: directory(join(TMP, 'interproscan', '{strain}'))
  singularity: "docker://blaxterlab/interproscan:5.22-61.0"
  params:
    in_fname = lambda w: join('predict_results', f'Acanthamoeba_castellanii_{w.strain}.proteins.fa')
  shell:
    """
    mkdir -p {output}
    interproscan.sh -i {input}/{params.in_fname} -d {output}
    """


# Download databases required for eggnog_mapper
rule download_eggnog_mapper_db:
  output: join(TMP, 'emapper_db', 'eggnog.db')
  singularity: "docker://golob/eggnog-mapper:2xx__bcw.0.3.1A"
  shell:
    """
    eggdir=$(dirname {output})
    mkdir -p $eggdir
    download_eggnog_data.py -y --data_dir $eggdir
    """


