# Using funannotate to annotate Acanthamoeba castellanii genome.
# cmdoret, 20190905

from os.path import join
from snakemake.utils import validate
import pandas as pd
import numpy as np

## CONFIGURATION FILES ##

configfile: "config.yaml"
validate(config, schema="schemas/config.schema.yaml")

samples = pd.read_csv(config["samples"], sep='\t').set_index("strain", drop=False)
validate(samples, schema="schemas/samples.schema.yaml")

units = pd.read_csv(config["units"], sep='\t', dtype=str).set_index(["strain", "unit"], drop=False)
# Enforces str in index
units.index = units.index.set_levels([i.astype(str) for i in units.index.levels])

CPUS = config['n_cpus']
TMP = config['tmp_dir']
OUT = config['out_dir']



## WILDCARD CONSTRAINTS
wildcard_constraints:
  strain="|".join(samples.index),
  libtype="|".join(np.unique(units.libtype))

## PIPELINE
include: "rules/01_clean_assembly.smk"
include: "rules/02_process_rnaseq.smk"
include: "rules/03_predict.smk"
include: "rules/04_annotate.smk"

rule all:
  input: expand(join(OUT, '{strain}'), strain=samples.strain)
