# MicrobiomeProfiler External Data Delivery Tasks v1

## 1. Objective

Deliver the first production slice of external data delivery using `gh-pages` as the dataset host and BugSigDB as the pilot dataset.

## 2. Milestones

### M1. Runtime skeleton

- Add a bundled lightweight registry file in `inst/extdata/`.
- Add internal helpers for registry lookup, cache path resolution, download, checksum validation, and `readRDS()` loading.
- Add internal object validation for downloaded dataset bundles.

Definition of done:

- a local fixture dataset can be resolved and loaded through one internal entry point.

### M2. Builder and publish pipeline

- Add `data-raw/build_bugsigdb.R`.
- Add `data-raw/publish_external_data.R`.
- Generate `manifest.json` and `bugsigdb_signatures.rds`.
- Publish generated files to `gh-pages`.

Definition of done:

- `gh-pages` contains a readable BugSigDB artifact and manifest under `datasets/bugsigdb/current/`.

### M3. Public enrichment pilot

- Add `R/enrichBugSigDB.R`.
- Reuse downloaded `term2gene` and `term2name` structures for enrichment.
- Add documentation and one simple example.

Definition of done:

- a toy input vector runs end-to-end against cached or freshly downloaded BugSigDB data.

### M4. Validation and regression safety

- Add unit tests and fixture data.
- Add workflow validation checks.
- Ensure package still passes local checks for existing code paths.

Definition of done:

- tests pass and no existing enrichment function regresses.

## 3. File-Level Task Breakdown

### 3.1 Runtime layer

**`R/data_registry.R`**

- Implement bundled registry loader.
- Implement dataset key resolution.
- Add clear errors for unknown dataset keys.

**`R/data_cache.R`**

- Implement cache root helper using `tools::R_user_dir()`.
- Implement cache path helper for dataset/version.
- Implement cache existence checks.

**`R/data_download.R`**

- Implement manifest download helper.
- Implement artifact download helper.
- Implement SHA256 validation helper.
- Handle partial file cleanup on failure.

**`R/data_loader.R`**

- Implement `readRDS()` loader.
- Validate required top-level fields.
- Return a normalized in-memory object.

**`R/enrichBugSigDB.R`**

- Accept a taxa vector input.
- Resolve and load BugSigDB dataset through the new runtime layer.
- Run enrichment using `clusterProfiler::enricher()` or the package's existing style.
- Return a result object consistent with nearby enrichment helpers where practical.

### 3.2 Build layer

**`data-raw/build_bugsigdb.R`**

- Fetch upstream BugSigDB export through the selected method.
- Normalize to package-ready `term2gene`, `term2name`, and metadata tables.
- Serialize artifact as `rds`.
- Generate manifest with checksum and record count.

**`data-raw/publish_external_data.R`**

- Stage output files in a temporary publish directory.
- Write/update `index.json` and `latest.json`.
- Prepare content for sync to `gh-pages`.

### 3.3 Metadata layer

**`inst/extdata/external_data_registry.json`**

- Add bundled registry entry for BugSigDB.
- Include current manifest URL and dataset identifier.

### 3.4 CI layer

**`.github/workflows/update_external_data.yml`**

- Schedule and manual trigger.
- Install dependencies.
- Build BugSigDB artifact.
- Validate manifest and artifact.
- Publish to `gh-pages` if changed.

**`.github/workflows/validate_external_data.yml`**

- Validate JSON parse.
- Validate checksum.
- Validate `readRDS()`.
- Validate required object fields.

### 3.5 Test layer

**`tests/testthat/test_external_data_registry.R`**

- Test bundled registry loading.
- Test unknown dataset failure.

**`tests/testthat/test_external_data_cache.R`**

- Test cache directory and dataset path generation.
- Test fixture-based artifact validation.

**`tests/testthat/test_enrichBugSigDB.R`**

- Test end-to-end load from fixture manifest plus artifact.
- Test enrichment smoke path with toy taxa.

## 4. Recommended Order

1. Build runtime skeleton without any network dependency.
2. Add fixture-based tests for registry, cache, and loader.
3. Implement BugSigDB builder script and local artifact generation.
4. Implement publish script for `gh-pages`.
5. Add workflow for build/publish and validation.
6. Add `enrichBugSigDB()` public entry point.
7. Add documentation and a minimal vignette or README mention.

## 5. Engineering Decisions for v1

### Decision 1

- Prefer **new function `enrichBugSigDB()`** over widening `enrichMDA()` immediately.

Reason:

- smaller blast radius;
- easier tests;
- clearer pilot boundary.

### Decision 2

- Prefer **bundled registry fallback** over remote-only registry bootstrap.

Reason:

- first run stays predictable;
- package is not blocked if `latest.json` is temporarily unavailable.

### Decision 3

- Prefer **`rds` artifact format** for v1.

Reason:

- easiest integration with current R code;
- lowest loader complexity.

### Decision 4

- Prefer **`current/` publish path** as mandatory and version snapshots as optional.

Reason:

- simplest first implementation;
- versioned history can be added later.

## 6. Risks to Watch During Implementation

- BugSigDB export shape may change and require a normalization layer that is stricter than expected.
- `gh-pages` publish logic can become messy if the workflow updates unrelated branch content.
- Remote runtime code can accidentally leak into tests if fixtures are not isolated.
- Enrichment result shape may diverge from existing package conventions if the pilot function is rushed.

## 7. Exit Checklist

- Runtime helpers exist and are covered by tests.
- BugSigDB artifact can be built locally.
- BugSigDB artifact can be published to `gh-pages`.
- Package can download and cache the artifact.
- `enrichBugSigDB()` runs on cached data.
- No large BugSigDB asset is committed into the main package payload.
- Existing enrichment paths still work.

## 8. Next Queue After v1

- Move Disbiome to the same remote data mechanism.
- Decide whether to unify `enrichBugSigDB()` and `enrichMDA()` behind a shared disease/signature abstraction.
- Add GO/QuickGO + GOA/UniProt as v2.
- Add cache inspection or refresh helpers if users need more control.

