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

# Only works for single end data
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
    prefetch -t ./fq --max-size 100G -p -o "./fq/{params.acc}.sra" "{params.acc}"
    
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

# Download data assets from zenodo record
rule get_zenodo_assets:
  output:
    expand(join(SHARED, 'genomes', '{strain}_assembly.fa'), strain=['Neff', 'C3']),
    url_tbl = join(TMP, 'zenodo_urls.tsv')
  conda: '../envs/zenodo_get.yaml'
  priority: 100
  params:
    in_dir = IN
  shell:
    """
    zenodo_get -d https://doi.org/10.5281/zenodo.5507417 -w {output.url_tbl}
    wget $(grep "shared_assets" {output.url_tbl}) -O - \
     | tar xzvf - --directory={params.in_dir} >/dev/null
    """