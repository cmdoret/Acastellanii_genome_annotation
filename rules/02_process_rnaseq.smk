# Align RNAseq data to the assembly to use for annotation later on.

rule index_STAR:
  input: join(TMP, 'clean', '03_{strain}_masked.fa')
  output: directory(join(TMP, 'STAR', '{strain}_genomedir'))
  singularity: config['containers']['star']
  conda: '../envs/rnaseq.yaml'
  threads: CPUS
  shell:
    """
    mkdir -p {output}
    STAR --runThreadN {threads} \
         --runMode genomeGenerate \
         --genomeFastaFiles {input} \
         --genomeDir {output}
    """

rule align_STAR:
  input:
    genomedir = join(TMP, 'STAR', '{strain}_genomedir'),
    reads = lambda w: units.loc[units.strain == w.strain, 'fq1'].tolist()[0]
  output: join(TMP, 'STAR', '{strain}_rnaAligned.out.sam')
  singularity: config['containers']['star']
  conda: '../envs/rnaseq.yaml'
  threads: CPUS
  params:
    prefix = join(TMP, 'STAR', '{strain}_rna'),
  shell:
    """
    STAR --runThreadN {threads} \
         --genomeDir {input.genomedir} \
         --readFilesIn <(gzip -dc {input.reads}) \
         --outFileNamePrefix {params.prefix}
    """

rule sort_bam:
  input: join(TMP, 'STAR', '{strain}_rnaAligned.out.sam')
  output: join(TMP, 'STAR', '{strain}_rna.bam')
  singularity: config['containers']['samtools']
  conda: '../envs/align.yaml'
  threads: CPUS
  shell:
    """
    samtools sort -@ {threads} -O BAM -o {output} {input}
    """

rule index_bam:
  input: join(TMP, 'STAR', '{strain}_rna.bam') 
  output: join(TMP, 'STAR', '{strain}_rna.bai')
  singularity: config['containers']['samtools']
  conda: '../envs/align.yaml'
  threads: CPUS
  shell:
    """
    samtools index -@ {threads} {input}
    """

rule transcriptome_assembly:
  input: join(TMP, 'STAR', '{strain}_rna.bam')
  output: directory(join(TMP, 'trinity', '{strain}'))
  singularity: config['containers']['trinity']
  conda: '../envs/rnaseq.yaml'
  threads: CPUS
  shell:
    """
    Trinity --genome_guided_bam {input} \
            --genome_guided_max_intron 10000 \
            --max_memory 10G --CPU {threads} \
            --output {output}
    """
