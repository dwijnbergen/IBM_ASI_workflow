#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: jdwijnbergen/multi-omics_asi

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
  stringdb_number_of_edges:
    type: int
    inputBinding:
      position: 2
  stringdb_min_weight:
    type: int
    inputBinding:
      position: 3

outputs:
 stringdb_edge_list:
   type: File
   outputBinding:
     glob: stringdb_edges
