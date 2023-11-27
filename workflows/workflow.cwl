#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

# TODO: add more format with https://www.ebi.ac.uk/ols/ontologies/edam/terms?iri=http%3A%2F%2Fedamontology.org%2Fformat_3752&lang=en&viewMode=All&siblings=false
inputs:
    stringdb_input_file:
        type: File
        label: STRING data
        doc: Table with Protein - protein interaction data as downloaded from STRING
        format: edam:data_0906 # Protein interaction data
        format: ino:INO_0000311 # Protein-protein interaction
    mirtarbase_input_file:
        type: File
        label: miRTarBase data 
        doc: Table with miRNA - mRNA target data as downloaded from
        format: ino:INO_0000235 #one-way interaction
    entrez2string:
        type: File
        label: STRING identifier mapping
        doc: Table with entrez mappings from STRING protein idenfitiers as downloaded from STRING
        format: edam:topic_3345 # Data identity and mapping
    bridgedb:
        type: Directory
        label: BridgeDB cache
        doc: directory with cached BridgeDB data
        format: edam:topic_3345 # Data identity and mapping
    mRNA-mRNA_bicor:
        type: File
        label: mRNA expression correlation
        doc: Tab separated edge list with Ensembl gene ID's in the first two columns, and their bi-weight midcorrelation as defined by Langelder et al. in the third column
        format: ino:INO_0000231 # co-expression
        format: edam:format_3475 # TSV
    miRNA-mRNA_bicor:
        type: File
        label: miRNA mRNA correlation
        doc: Tab separated edge list with Ensembl gene ID's in the first column, miRBase ID's in the second column. and their bi-weight midcorrelation as defined by Langelder et al. in the third column
        format: ino:INO_0000231 # co-expression
        format: edam:format_3475 # TSV
    de_mRNA:
        type: File
        label: Differential gene expression
        doc: Output of differential mRNA expression testing from DESeq2, with Ensembl gene ID's concatened with gene symbols with ";" inbetween in the first column
        format: edam:operation_3223 # Differential gene expression profiling
    de_miRNA:
        type: File
        label: Differential miRNA expression
        doc: Output of differential miRNA expression testing from DESeq2, with miRBase ID's in the first column
        format: edam:operation_3223 # Differential gene expression profiling
    variant_burden:
        type: File
        label: Variant Burden
        doc: Output of variant burden testing using SKAT in the rvtests package, with HGNC symbols in the first column

    stringdb_number_of_edges:
        type: int
        label: The number of STRING edges to use, USE FOR TESTING ONLY
    stringdb_min_weight:
        type: int
        label: The minimum score for a STRING edge to be included in the analysis
    mirtarbase_number_of_edges:
        type: int
        label: The number of miRTarBase edges to use, USE FOR TESTING ONLY
    max_cor_edges:
        type: int
        label: The number of correlation edges to use, USE FOR TESTING ONLY
    mogamun_generations:
        type: int
        label: The number of generation to let the genetic algorithm in MOGAMUN evolve
    mogamun_runs:
        type: int
        label: The number of parallel runs to let MOGAMUN do, these parallel runs are combined in postprocessing
    mogamun_cores:
        type: int
        label: The number of cores to let MOGAMUN use
    mogamun_min_size:
        type: int
        label: The minimum size of subnetworks during postprocessing
    mogamun_max_size:
        type: int
        label: The maximum size of subnetworks during postprocessing
    mogamun_merge_threshold:
        type: int
        label: the minimum Jaccard Index overlap between two subnetworks to allow them to be merged

outputs:
    full_graph:
        type: File
        outputSource: integrate_graph/full_graph
    subnetworks:
        type: Directory
        outputSource: postprocess_mogamun/subnetworks

steps:
    import_stringdb:
        run: import_stringdb.cwl
        in: 
            stringdb_input_file: stringdb_input_file
            stringdb_number_of_edges: stringdb_number_of_edges
            stringdb_min_weight: stringdb_min_weight
        out: 
            [stringdb_edge_list]

    import_mirtarbase:
        run: import_mirtarbase.cwl
        in:
            mirtarbase_input_file: mirtarbase_input_file
            mirtarbase_number_of_edges: mirtarbase_number_of_edges
        out:
            [mirtarbase_edge_list]

    map_stringdb:
        run: map_stringdb.cwl
        in:
            stringdb_edge_list: import_stringdb/stringdb_edge_list
            entrez2string: entrez2string
            bridgedb: bridgedb
        out:
            [stringdb_mapped_edge_list]

    map_mirtarbase:
        run: map_mirtarbase.cwl
        in:
            bridgedb: bridgedb
            mirtarbase_edge_list: import_mirtarbase/mirtarbase_edge_list
        out:
            [mirtarbase_mapped_edge_list]

    integrate_graph:
        run: integrate_graph.cwl
        in:
            stringdb_mapped_edge_list: map_stringdb/stringdb_mapped_edge_list
            mirtarbase_mapped_edge_list: map_mirtarbase/mirtarbase_mapped_edge_list
            mRNA-mRNA_bicor: mRNA-mRNA_bicor
            miRNA-mRNA_bicor: miRNA-mRNA_bicor
            de_mRNA: de_mRNA
            de_miRNA: de_miRNA
            variant_burden: variant_burden
            bridgedb: bridgedb
            max_cor_edges: max_cor_edges
        out:
            [full_graph, full_graph_rds]

    igraph_to_mogamun:
        run: igraph_to_mogamun.cwl
        in:
            full_graph_rds: integrate_graph/full_graph_rds
        out:
            [mogamun_input]

    run_mogamun:
        run: run_mogamun.cwl
        in:
            mogamun_input: igraph_to_mogamun/mogamun_input
            mogamun_generations: mogamun_generations
            mogamun_runs: mogamun_runs
            mogamun_cores: mogamun_cores
        out:
            [mogamun_results]
    
    postprocess_mogamun:
        run: postprocess_mogamun.cwl
        in:
            mogamun_input: igraph_to_mogamun/mogamun_input
            mogamun_results: run_mogamun/mogamun_results
            mogamun_min_size: mogamun_min_size
            mogamun_max_size: mogamun_max_size
            mogamun_merge_threshold: mogamun_merge_threshold
        out:
            [subnetworks]

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0002-7449-6657
    s:email: mailto:j.d.wijnbergen@lumc.nl
    s:name: Daphne Wijnbergen

#TODO Add citation
s:codeRepository: https://github.com/jdwijnbergen/IBM_ASI_workflow
#TOOD Add license

$namespaces:
 s: https://schema.org/
 edam: http://edamontology.org/
 ino: http://purl.obolibrary.org/obo/

$schemas:
 - https://schema.org/version/latest/schemaorg-current-http.rdf
 - http://edamontology.org/EDAM_1.18.owl
 - http://purl.obolibrary.org/obo/ino.owl