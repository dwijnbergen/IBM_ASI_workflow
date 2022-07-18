#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: jdwijnbergen/multi-omics_asi

requirements:
  InitialWorkDirRequirement:
    listing:
    - entryname: map_mirtarbase.R
      entry:
        $include: ../scripts/map_mirtarbase.R
    - entryname: map_identifiers.R
      entry:
        $include: ../scripts/map_identifiers.R

baseCommand: ["Rscript", "map_mirtarbase.R"]

inputs:
  mirtarbase_edge_list:
    type: File
    inputBinding:
      position: 1
  bridgedb:
    type: Directory
    inputBinding:
      position: 2

outputs:
 mirtarbase_mapped_edge_list:
   type: File
   outputBinding:
     glob: mirtarbase_edges_mapped
