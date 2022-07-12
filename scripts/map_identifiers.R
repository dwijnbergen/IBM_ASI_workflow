library(data.table)
library(tidyr)
library(BridgeDbR)
library(miRBaseConverter)
library(igraph)

get_mapping_BridgeDB <- function(organism, from, to, identifiers){
  
  # Get database
  dir.create("mapping/BridgeDB", showWarnings = FALSE)
  location <- file.path("mapping/BridgeDB")
  if (length(list.files(location)) == 0)
    db_location <- getDatabase(organism = organism, location = location)
  
  # Get mapping file
  bridgedb_mapper <- loadDatabase(file.path(location, list.files(location)[[1]]))
  input <- data.frame(source = rep(from, length(identifiers)), identifier = identifiers)
  mapping <- maps(bridgedb_mapper, input, to)
  mapping <- mapping[,c("identifier", "mapping")]

  return(mapping)
}

get_mapping_entrez2string <- function(organism){
  if (organism != "Homo sapiens")
    stop("get_mapping_STRINDB function is only implemented for Homo sapiens")
  
  download_url <- "https://string-db.org/mapping_files/entrez/human.entrez_2_string.2018.tsv.gz"
  location <- file.path("mapping/STRINGmapping")
  zipped_file <- file.path(location, "entrez2string.gz")
  unzipped_file <- file.path(location, "entrez2string")
  
  dir.create(location, showWarnings = FALSE)
  
  # Download mapping file
  if (!file.exists(zipped_file)){
    system(paste("wget", download_url, "-O", zipped_file))
  }
  
  # Unzip data
  if (!file.exists(unzipped_file)){
    system(paste("gunzip -k", zipped_file))
  }
  
  # Read mapping table
  mapping <- fread(unzipped_file, sep = "\t")
  colnames(mapping) <- c("NCBI taxid", "entrez", "STRING")
  mapping <- mapping[,3:2]
  
  # split rows with multiple mappings into multiple rows
  mapping <- separate_rows(mapping, 2, sep = "\\|")

  return(mapping)
}

get_mapping_miRBaseConverter <- function(from, to, identifiers) {
  if (from == "Name" & to == "Accession") {
    mapping <- miRNA_NameToAccession(identifiers, version="v22")
  } else if (from == "Accession" & to == "Name") {
    mapping <- miRNA_AccessionToName(identifiers)
  } else if (
    stop(paste("Converting from", from, "to", to, "is not implemented"))
  )
  return(mapping)
}

get_mapping <- function(service, organism = "Homo sapiens", from = NULL , to = NULL, identifiers = NULL){
  # Create directory for mapping and database files
  dir.create("mapping", showWarnings = FALSE)
  
  print(paste("Mappings are being obtained from", service))
  
  # Run the appropriate service to get mapping
  if (service == "BridgeDB"){
    mapping <- get_mapping_BridgeDB(organism, from, to, identifiers)
  } 
  else if (service == "entrez2string"){
    mapping <- get_mapping_entrez2string(organism)
  }
  else if (service == "miRBaseConverter"){
    mapping <- get_mapping_miRBaseConverter(from, to, identifiers)
  }
  else {
    stop(paste0("Mapping service \"", service, "\" not implemented"))
  }
  
  # Return mapping
  print(paste(nrow(mapping), "mappings were obtained"))
  return(mapping)
}

apply_mapping_vector <- function(mapping, input_vector) {
  # Prevent identifier mapping to multiple identifiers
  # Necessary because it is applied to vector
  colnames(mapping) <- c("From", "To")
  mapping <- unique(mapping, by = "From")
  
  # Merge mapping with vector
  input_vector <- data.table(input_vector)
  colnames(input_vector) <- "Identifier"
  result <- merge(input_vector, mapping, by.x = "Identifier", by.y = "From", all.x = TRUE)
  result <- result[!duplicated(result$Identifier), ]
  
  # Return to original order
  rownames(result) <- result$Identifier
  result <- result[input_vector, ]
  
  return(result$To)
}

apply_mapping_edge_list <- function(mapping, edges, column=1){
  # Prepare tables for merging
  nrows <- nrow(edges)
  ncols <- ncol(edges)
  if (ncols == 2) {colnames(edges) <- c("Identifier A", "Identifier B")}
  else if (ncols == 3) {colnames(edges) <- c("Identifier A", "Identifier B", "Weight")}
  else {stop("Number of columns is incorrect")}
  colnames(mapping) <- c("From", "To")
  
  # Merge a column of the edge list with the mapping table and update column names
  edge_column <- c("Identifier A", "Identifier B")[column]
  edges <- merge(x = edges, y = mapping, by.x = edge_column, by.y = "From")
  colnames(edges)[colnames(edges) == edge_column] <- "Old Identifier"
  colnames(edges)[colnames(edges) == "To"] <- edge_column

  # Remove edges with missing identifiers
  edges <- na.omit(edges)

  # Select columns with new identifiers
  if (ncols == 2) {edges <- edges[,c("Identifier A", "Identifier B")]}
  else if (ncols == 3) {edges <- edges[,c("Identifier A", "Identifier B", "Weight")]}

  print(paste(nrows, "edges were mapped to", nrow(edges), "edges"))
  return(edges)
}

remove_duplicate_edges <- function(edges, directed = FALSE){
  # Sort edges by descending weight
  # As a result, the duplicate with the heighest weight is used
  edges <- edges[rev(order(edges[,3]))]
  
  # Order the 2 nodes alphabetically for each edge if the network is undirected
  # This way mirrored duplicates like A-B and B-A are also removed
  ordered_edges <- edges
  
  if (!directed) {
    order_edge <- function(edge){
      if(order(edge[1:2])[1] == 2) {
        tmp <- edge[1]
        edge[1] <- edge[2]
        edge[2] <- tmp
      }
      return(edge)
    }
    
    ordered_edges <- t(apply(ordered_edges, 1, order_edge))
  }
    
  # Remove duplicates
  n_edges <- nrow(edges)
  edges <- edges[!duplicated(ordered_edges[,c(1,2)])]
  print(paste("Removed", n_edges - nrow(edges), "duplicate edges"))
  
  return(edges)
}