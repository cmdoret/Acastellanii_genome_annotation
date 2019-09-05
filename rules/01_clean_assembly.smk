# Sort, rename, filter input scaffolds using funannotate and mask repeats.

rule clean_assembly:
  input: samples.genome[samples.strain=='{strain}']
  output: join(TMP, 'clean', '01_{strain}_clean.fa')
  singularity: "docker://cmdoret/funannotate:latest"
  shell:
    """
    funannotate clean -i {input} -o {output}
    """

rule sort_assembly:
  input: join(TMP, 'clean', '01_{strain}_clean.fa')
  output: join(TMP, 'clean', '02_{strain}_sorted.fa')
  singularity: "docker://cmdoret/funannotate:latest"
  shell:
    """
    funannotate sort -i {input} \
                     -o {output} \
    """

rule mask_assembly:
  input: join(TMP, 'clean', '02_{strain}_sorted.fa')
  output: join(TMP, 'clean', '03_{strain}_masked.fa')
  singularity: "docker://cmdoret/funannotate:latest"
  threads: CPUS
  shell:
    """
    funannotate mask -i {input} \
                     -o {output} \
                     -s 'acanthamoeba castellanii' \
                     --cpus {threads}
    """
