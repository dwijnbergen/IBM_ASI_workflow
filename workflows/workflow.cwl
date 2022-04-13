#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: Workflow

inputs:
    stringdb_input_file:
        type: File

outputs: []

steps:
    import_stringdb:
        run: import_stringdb.cwl
        in: 
            stringdb_input_file: stringdb_input_file
        out: 
            [output]

    map_stringdb:
        run: map_stringdb.cwl
        in:
            import_stringdb/output
        out:
            [output]

    # import_mirtarbase:
    #     run: import_mirtarbase.cwl
    #     in:
    #         mirtarbase_input_file: mirtarbase_input_file
    #     out:
    #         output: [mirtarbase_edges]
    