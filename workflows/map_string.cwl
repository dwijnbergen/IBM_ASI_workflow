#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: jdwijnbergen/multi-omics_asi

requirements:
  InitialWorkDirRequirement:
    listing:
    - entryname: map_stringdb.R
      entry:
        $include: ../scripts/map_stringdb.R
    - entryname: map_identifiers.R
      entry:
        $include: ../scripts/map_identifiers.R

baseCommand: ["Rscript", "map_stringdb.R"]

inputs:
  stringdb_edge_list:
    type: File
    inputBinding:
      position: 1

outputs:
 stringdb_mapped_edge_list:
   type: File
   outputBinding:
     glob: stringdb_edges_mapped
