#!/usr/bin/env cwl-runner

cwlVersion: v1.2
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
outputs:
 stringdb_edge_list:
   type: File
   outputBinding:
     glob: stringdb_edges
