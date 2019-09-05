# Align RNAseq data to the assembly to use for annotation later on.

rule index_STAR:
  input: join(TMP, 'clean', '03_{strain}_masked.fa')
  output: directory(join(TMP, 'STAR', '{strain}_genomedir'))
  singularity: 'docker://cmdoret/star:2.5.4a--0'
  threads: CPUS
  shell:
    """
    STAR --runThreadN {threads} \
         --runMode genomeGenerate \
         --genomeFastaFiles {input} \
         --genomeDir {output}
    """

rule align_STAR:
  input:
    genomedir = join(TMP, 'STAR', '{strain}_genomedir'),
    reads = units.fq1
  output: join(TMP, 'STAR', '{strain}_rna.out.sam')
  singularity: 'docker://cmdoret/star:2.5.4a--0'
  threads: CPUS
  params:
    prefix = join(TMP, 'STAR', '{strain}_rna')
  shell:
    """
    STAR --runThreadN {threads} \
         --genomeDir {input.genomedir} \
         --readFilesIn {input.reads} \
         --outFileNamePrefix {params.prefix}
    """

rule sort_bam:
  input: join(TMP, 'STAR', '{strain}_rna.out.sam')
  output: join(TMP, 'STAR', '{strain}_rna.bam')
  singularity: 'docker://biocontainers/samtools:v1.7.0_cv4'
  threads: CPUS
  shell:
    """
    samtools sort -@ {threads} -O BAM -o {output} {input}
    """

rule index_bam:
  input: join(TMP, 'STAR', '{strain}_rna.bam') 
  output: join(TMP, 'STAR', '{strain}_rna.bai')
  singularity: 'docker://biocontainers/samtools:v1.7.0_cv4'
  threads: CPUS
  shell:
    """
    samtools index -@ {threads} {input}
    """

rule transcriptome_assembly:
  input: join(TMP, 'STAR', '{strain}_rna.bam')
  output: directory(join(TMP, 'trinity', '{strain}'))
  singularity: "docker://biocontainers/trinityrnaseq:v2.2.0dfsg-2b1-deb_cv1"
  threads: CPUS
  shell:
    """
    Trinity --genome_guided_bam {input} \
            --genome_guided_max_intron 10000 \
            --max_memory 10G --CPU {threads} \
            --output {output}
    """
