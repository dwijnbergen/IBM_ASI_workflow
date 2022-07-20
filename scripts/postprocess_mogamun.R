#!/usr/bin/env Rscript
library(MOGAMUN)

run_mogamun <- function(mogamun_dir, result_dir, generations = 500, cores = 1, runs = 30,
                        layers = NULL, JI_threshold_postprocess = NULL,
                        MinSize = 15, MaxSize = 50){

  parameters <- mogamun_init(Generations = generations, PopSize = 100,
        Measure = "PValue", MinSize = MinSize, MaxSize = MaxSize)

  dePath <- file.path(mogamun_dir, "pvals.csv")
  scoresPath <- file.path(mogamun_dir, "NodeScores.csv")
  layersPath <- file.path(mogamun_dir, "networks/")

  output_dir <- "MOGAMUN_subnetworks"
  system(paste("cp -r", result_dir, output_dir))

  loadedData <-
    mogamun_load_data(
      EvolutionParameters = parameters,
      DifferentialExpressionPath = dePath,
      NodesScoresPath = scoresPath,
      NetworkLayersDir = layersPath,
      Layers = layers
    )

  mogamun_postprocess(
    LoadedData = loadedData, 
    ExperimentDir = output_dir, 
    VisualizeInCytoscape = FALSE,
    JaccardSimilarityThreshold = JI_threshold_postprocess
  )
}

args <- commandArgs(trailingOnly=TRUE)
run_mogamun(args[1], args[2], MinSize = args[3], MaxSize = args[4], JI_threshold_postprocess = args[5], layers="12")
