#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: Rscript

inputs:
  import_mirtarbase_src:
    type: File
    inputBinding:
      position: 1
  mirtarbase_input_file:
    type: File
    inputBinding:
      position: 2
  mirtarbase_edgelist:
    type: string
    inputBinding:
      position: 3
outputs: []
#  example_out: []
#    type: File
#    outputBinding:
#      glob: stringdb_edges_path
