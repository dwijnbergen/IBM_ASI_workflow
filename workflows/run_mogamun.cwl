#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: jdwijnbergen/multi-omics_asi

requirements:
  InitialWorkDirRequirement:
    listing:
    - entryname: run_mogamun.R
      entry:
        $include: ../scripts/run_mogamun.R

baseCommand: ["Rscript", "run_mogamun.R"]

inputs:
  mogamun_input:
    type: File
    inputBinding:
      position: 1
  mogamun_generations:
    type: int
    inputBinding:
      position: 2
  mogamun_runs:
    type: int
    inputBinding:
      position: 3
  mogamun_cores:
    type: int
    inputBinding:
      position: 4
  mogamun_merge_threshold:
    type: int
    inputBinding:
      position: 5

outputs:
 subnetworks:
   type: File
   outputBinding:
     glob: subnetworks
