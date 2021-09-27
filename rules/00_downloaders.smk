# Rules for downloading data from the web
def lib_to_sra(wildcards):
  """
  Get SRA accession from fq path.
  """
  try:
    mask = units.fq1.str.contains(wildcards.libname).fillna(False)
    sra = units.sra[mask].values[0]
  except IndexError:
    mask = units.fq2.str.contains(wildcards.libname).fillna(False)
    sra = units.sra[mask].values[0]
  return sra


rule sra_dl_fq:
  message: "Getting {params.acc} into {output}"
  output: join('fq', '{strain}','{libtype}', '{libname}')
  params:
    acc = lib_to_sra
  conda: '../envs/sra.yaml'
  singularity: 'quay.io/biocontainers/sra-tools:2.11.0--pl5262h314213e_0'
  threads: 12
  shell:
    """
    # Get library base name
    fq={output}
    trim=${{fq%.gz}}
    echo "SRA download to ${{trim}}"

    # Download SRA file
    prefetch --max-size 100G -p -o "./fq/{params.acc}.sra" "{params.acc}"
    
    # Convert to fastq locally and compress
    fasterq-dump -f -t ./fq -e {threads} "./fq/{params.acc}.sra" -o $trim
    rm -f "./fq/{params.acc}.sra"
    gzip ${{trim}}
    """

# Download databases required for eggnog_mapper
rule download_eggnog_mapper_db:
  output: touch(join(TMP, 'emapper_db', 'eggnog.done'))
  singularity: "docker://golob/eggnog-mapper:2xx__bcw.0.3.1A"
  conda: "../envs/eggnog_mapper.yaml"
  message: "Downloading eggnog database to {output}"
  shell:
    """
    eggdir=$(dirname {output})
    mkdir -p $eggdir
    download_eggnog_data.py -y --data_dir $eggdir
    """