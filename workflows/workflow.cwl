#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

inputs:
    stringdb_input_file:
        type: File
    mirtarbase_input_file:
        type: File

outputs:
    stringdb_edges:
        type: File
        outputSource: import_stringdb/stringdb_edge_list
    mirtarbase_edges:
        type: File
        outputSource: import_mirtarbase/mirtarbase_edge_list
    # stringdb_mapped_edges:
    #     type: File
    #     outputSource: map_stringdb/stringdb_mapped_edge_list

steps:
    import_stringdb:
        run: import_stringdb.cwl
        in: 
            stringdb_input_file: stringdb_input_file
        out: 
            [stringdb_edge_list]

    import_mirtarbase:
        run: import_mirtarbase.cwl
        in:
            mirtarbase_input_file: mirtarbase_input_file
        out:
            [mirtarbase_edge_list]

    # map_stringdb:
    #     run: map_stringdb.cwl
    #     in:
    #         stringdb_edge_list: import_stringdb/stringdb_edge_list
    #     out:
    #         [stringdb_mapped_edge_list]
    