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
        $include: ../scripts/util/map_identifiers.R

baseCommand: ["Rscript", "map_stringdb.R"]

inputs:
  stringdb_edge_list:
    type: File
    inputBinding:
      position: 1
  entrez2string:
    type: File
    inputBinding:
      position: 2
  bridgedb:
    type: Directory
    inputBinding:
      position: 3

outputs:
 stringdb_mapped_edge_list:
   type: File
   outputBinding:
     glob: stringdb_edges_mapped
