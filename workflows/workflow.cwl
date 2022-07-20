#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

inputs:
    stringdb_input_file:
        type: File
    mirtarbase_input_file:
        type: File
    entrez2string:
        type: File
    bridgedb:
        type: Directory
    mRNA-mRNA_bicor:
        type: File
    miRNA-mRNA_bicor:
        type: File
    de_mRNA:
        type: File
    de_miRNA:
        type: File
    variant_burden:
        type: File

    stringdb_number_of_edges:
        type: int
    stringdb_min_weight:
        type: int
    mirtarbase_number_of_edges:
        type: int
    max_cor_edges:
        type: int
    mogamun_generations:
        type: int
    mogamun_runs:
        type: int
    mogamun_cores:
        type: int
    mogamun_merge_threshold:
        type: int

outputs:
    full_graph:
        type: File
        outputSource: integrate_graph/full_graph
    subnetworks:
        type: File
        outputSource: run_mogamun/subnetworks

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
            mogamun_merge_threshold: mogamun_merge_threshold
        out:
            [subnetworks]
