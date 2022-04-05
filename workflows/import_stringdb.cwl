#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: Rscript

inputs:
  import_stringdb_src:
    type: File
    inputBinding:
      position: 1
  stringdb_input_file:
    type: File
    inputBinding:
      position: 2
  stringdb_edgelist:
    type: string
    inputBinding:
      position: 3
outputs: []
#  example_out: []
#    type: File
#    outputBinding:
#      glob: stringdb_edges_path
