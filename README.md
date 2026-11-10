# Statistical Analysis Code

## Overview

This package contains the SAS programs used to reproduce the principal efficacy, safety, and imaging analyses reported in the manuscript and its supplementary material. It includes the mixed model for repeated measures (MMRM) analyses for VaDAS-cog, ADCS-ADL, CIBIC-Plus, NPI, CDR-SB, and MMSE; the adverse-event analyses; and the analysis of covariance (ANCOVA) analyses for white matter hyperintensity (WMH) volume and brain parenchymal fraction (BPF).

This is a code-only supplement. No participant-level data are included. The programs require the corresponding de-identified, analysis-ready datasets, which are managed and shared separately under the study's approved data-sharing arrangements.

## Software

- SAS version: SAS 9.4 TS1M6, 64-bit
- Operating environment used for the original analyses: Microsoft Windows
- Recommended text encoding: UTF-8

## Directory Structure

```text
Statistical_Analysis_Code_BMJ_2026-11-10/
|-- README.md
`-- sas/
    |-- formats.sas
    |-- utility_macros.sas
    |-- vadas_cog_mmrm.sas
    |-- adcs_adl_mmrm.sas
    |-- cibic_plus_repeated_measures.sas
    |-- npi_mmrm.sas
    |-- cdr_sb_mmrm.sas
    |-- mmse_mmrm.sas
    |-- vadas_cog_supporting_analyses.sas
    |-- cibic_plus_distribution_responder_analyses.sas
    |-- adverse_event_safety_analyses.sas
    `-- wmh_bpf_ancova.sas
```

## File Descriptions

| File | Purpose |
|---|---|
| `formats.sas` | Defines formats used by the efficacy and safety programs. |
| `utility_macros.sas` | Defines shared utility macros for analysis-population selection, sorting, merging, and reporting. |
| `vadas_cog_mmrm.sas` | MMRM analysis of change from baseline in VaDAS-cog for the FAS and PPS populations. |
| `adcs_adl_mmrm.sas` | MMRM analysis of change from baseline in ADCS-ADL for the FAS and PPS populations. |
| `cibic_plus_repeated_measures.sas` | Repeated-measures analysis of CIBIC-Plus outcomes for the FAS and PPS populations. |
| `npi_mmrm.sas` | MMRM analysis of NPI outcomes for the FAS and PPS populations. |
| `cdr_sb_mmrm.sas` | MMRM analysis of CDR and CDR-SB outcomes for the FAS and PPS populations. |
| `mmse_mmrm.sas` | MMRM analysis of change from baseline in MMSE for the FAS and PPS populations. |
| `vadas_cog_supporting_analyses.sas` | Supporting descriptive and inferential analyses for VaDAS-cog. |
| `cibic_plus_distribution_responder_analyses.sas` | Supporting distributional and responder analyses for CIBIC-Plus. |
| `adverse_event_safety_analyses.sas` | Analyses of adverse events, serious adverse events, treatment-related adverse events, and prespecified safety events, including hepatic events. |
| `wmh_bpf_ancova.sas` | Visit-specific ANCOVA analyses of changes in total WMH volume and BPF at Weeks 26 and 52. |

## Required Inputs

The participant-level inputs are not included in this code supplement. Before execution, place the approved de-identified analysis-ready data in the appropriate local location and ensure that the dataset names and variable names agree with those referenced in the programs.

The Table 2 and Table 3 programs use analysis datasets already loaded into the SAS session, including the endpoint-specific FAS/PPS datasets named in each program. Some shared macros also refer to the SAS library `FXK`; assign this library to the approved local directory containing the de-identified SAS analysis datasets before running those macros.

The Table S7 program imports the following analysis-ready CSV file by default:

```text
data/processed_analysis_data.csv
```

The file is resolved relative to `PROJECT_DIR` in `wmh_bpf_ancova.sas`. Set `PROJECT_DIR` to the extracted package directory, or edit `INPUT_CSV` and `OUTPUT_CSV` to use approved local locations. The program writes:

```text
output/table_s7_sas_results.csv
```

## Recommended Execution Order

1. Start SAS 9.4 and set the working directory to the extracted package directory.
2. Assign the `FXK` library, if required, to the directory containing the approved de-identified SAS analysis datasets.
3. Run `formats.sas`.
4. Run `utility_macros.sas`.
5. Load or create the endpoint-specific analysis-ready datasets referenced by the selected analysis program.
6. Run the required Table 2 program(s), followed by the relevant supporting program(s) when those additional results are needed.
7. Run `adverse_event_safety_analyses.sas` for the safety analyses.
8. For the WMH and BPF analyses, create local `data` and `output` directories, place the approved imaging analysis CSV in `data`, and run `wmh_bpf_ancova.sas`.

Each analysis program may also be run separately after its required input datasets and shared definitions are available.

## Output

The Table 2 and Table 3 programs create SAS output datasets and report tables in the active SAS session. The exact output objects are identified within each program. The Table S7 program creates a CSV file containing the adjusted least-squares means, treatment differences, 95% confidence intervals, and two-sided P values for WMH and BPF at Weeks 26 and 52.

## Language and Data-Coding Note

All filenames and author-facing documentation in this package are in English. A limited number of quoted Chinese character strings remain in the legacy SAS programs because they are exact coded values in the original analysis datasets or report-generation parameters. They are retained to preserve executable matching and numerical reproducibility. They should not be translated unless the corresponding dataset values are recoded and the complete analysis output is revalidated.

## Reproducibility and Privacy

- No raw data, direct identifiers, or participant-level datasets are included in this archive.
- Replace local paths only with approved data locations.
- Do not upload identifiable or non-de-identified source data with this code package.
- Any modification to source-value coding, analysis populations, model specifications, or derived variables should be validated against the approved statistical analysis plan and the reported results.

## Package Date

10 November 2026
