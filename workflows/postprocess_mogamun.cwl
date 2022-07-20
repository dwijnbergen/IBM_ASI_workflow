#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: jdwijnbergen/multi-omics_asi

requirements:
  InitialWorkDirRequirement:
    listing:
    - entryname: postprocess_mogamun.R
      entry:
        $include: ../scripts/postprocess_mogamun.R

baseCommand: ["Rscript", "postprocess_mogamun.R"]

inputs:
    mogamun_input:
        type: Directory
        inputBinding:
            position: 1
    mogamun_results:
        type: Directory
        inputBinding:
            position: 2
    mogamun_min_size:
        type: int
        inputBinding:
            position: 3
    mogamun_max_size:
        type: int
        inputBinding:
            position: 4
    mogamun_merge_threshold:
        type: int
        inputBinding:
            position: 5

outputs:
 subnetworks:
   type: Directory
   outputBinding:
     glob: MOGAMUN_subnetworks
