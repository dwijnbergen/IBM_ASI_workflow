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
    type: Directory
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

outputs:
 mogamun_results:
   type: Directory
   outputBinding:
     glob: MOGAMUN_results
