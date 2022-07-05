#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  InitialWorkDirRequirement:
    listing:
    - entryname: import_stringdb.R
      entry:
        $include: ../scripts/import_stringdb.R

baseCommand: ["Rscript", "import_stringdb.R"]

inputs:
  stringdb_input_file:
    type: File
    inputBinding:
      position: 1

outputs:
 stringdb_edge_list:
   type: File
   outputBinding:
     glob: stringdb_edges
