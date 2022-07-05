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
outputs:
 example_out:
   type: File
   outputBinding:
     glob: mirtarbase_edges
