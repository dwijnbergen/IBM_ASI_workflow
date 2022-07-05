#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: jdwijnbergen/multi-omics_asi

requirements:
  InitialWorkDirRequirement:
    listing:
    - entryname: import_mirtarbase.R
      entry:
        $include: ../scripts/import_mirtarbase.R

baseCommand: ["Rscript", "import_mirtarbase.R"]

inputs:
  mirtarbase_input_file:
    type: File
    inputBinding:
      position: 1

outputs:
 example_out:
   type: File
   outputBinding:
     glob: mirtarbase_edges
