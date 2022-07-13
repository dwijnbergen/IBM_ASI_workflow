#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: jdwijnbergen/multi-omics_asi

requirements:
  InitialWorkDirRequirement:
    listing:
    - entryname: igraph_to_mogamun.R
      entry:
        $include: ../scripts/igraph_to_mogamun.R


baseCommand: ["Rscript", "igraph_to_mogamun.R"]

inputs:
  full_graph:
    type: File
    inputBinding:
      position: 1

outputs:
 mogamun_input:
   type: File
   outputBinding:
     glob: mogamun_input
