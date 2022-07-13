#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: jdwijnbergen/multi-omics_asi

requirements:
  InitialWorkDirRequirement:
    listing:
    - entryname: integrate_graph.R
      entry:
        $include: ../scripts/integrate_graph.R

baseCommand: ["Rscript", "integrate_graph.R"]

inputs:
  stringdb_mapped_edge_list:
    type: File
    inputBinding:
      position: 1
  mirtarbase_mapped_edge_list:
    type: File
    inputBinding:
      position: 2
  mRNA-mRNA_bicor:
    type: File
    inputBinding:
      position: 3
  miRNA-mRNA_bicor:
    type: File
    inputBinding:
      position: 4
  de_mRNA:
    type: File
    inputBinding:
      position: 5
  de_miRNA:
    type: File
    inputBinding:
      position: 6
  variant_burden:
    type: File
    inputBinding:
      position: 7

outputs:
 full_graph:
   type: File
   outputBinding:
     glob: full_graph.igraph
