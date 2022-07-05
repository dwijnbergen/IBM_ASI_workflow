#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: jdwijnbergen/multi-omics_asi

# requirements:
#   InitialWorkDirRequirement:
#     listing:
#     - entryname: map_stringdb.R
#       entry:
#         $include: ../scripts/import_stringdb.R

# baseCommand: ["Rscript", "import_stringdb.R"]
# baseCommand: Rscript

inputs:
  stringdb_edge_list:
    type: File
    inputBinding:
      position: 1

outputs:
 stringdb_mapped_edge_list:
   type: File
   outputBinding:
     glob: stringdb_mapped
