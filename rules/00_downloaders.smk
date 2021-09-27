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
    prefetch -p -o "{params.acc}.sra" "{params.acc}"
    
    # Convert to fastq locally and compress
    fasterq-dump -e {threads} "./{params.acc}.sra" -o $trim
    rm "{params.acc}.sra"
    gzip ${{trim}}*fastq
    """