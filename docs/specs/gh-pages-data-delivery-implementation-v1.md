# MicrobiomeProfiler External Data Delivery Implementation Spec v1

## 1. Purpose

This document narrows the broader external data delivery design into a first implementation slice that can be built and validated in the current repository without over-expanding scope.

The implementation target is to make one remote-delivered enrichment dataset work end-to-end through:

- build script
- manifest generation
- `gh-pages` publishing
- local cache download
- runtime load in package code

The first release should optimize for stability and simplicity rather than maximum feature coverage.

## 2. v1 Scope

### 2.1 In scope

- Introduce a manifest-based external data registry.
- Introduce a local cache layer in the R package.
- Introduce dataset download, checksum validation, and load helpers.
- Publish at least one enrichment dataset to `gh-pages`.
- Wire one public enrichment path to the new external delivery flow.
- Keep current bundled data as transitional fallback where needed.
- Add CI workflow for publishing external data to `gh-pages`.
- Add CI validation for generated artifact metadata and basic readability.

### 2.2 Out of scope

- Full migration of all existing datasets out of `R/sysdata.rda`.
- New Shiny UI for dataset management.
- Full offline management API.
- Multi-source switching across every enrichment function.
- Full support for GO, eggNOG, and universe datasets in the same first patch.
- Rebuilding the whole package data model.

## 3. v1 Dataset Choice

### 3.1 Primary pilot dataset

Use **BugSigDB** as the v1 pilot dataset.

Reason:

- it has strong user-facing value;
- it is a better test of remote delivery than a tiny built-in dataset;
- it aligns with the current `Microbe-Disease` enrichment line;
- it gives the project an immediately visible expansion over the current Disbiome-only path.

### 3.2 Transitional compatibility dataset

Keep **Disbiome** in the current code path during v1.

Recommended policy:

- do not remove `disbiome_data2` support in v1;
- do not require the v1 pilot to solve all Disbiome update automation gaps;
- optionally allow the new resolver to support a remote Disbiome artifact later using the same architecture.

## 4. v1 User Story

Target user story:

1. user calls a disease/signature enrichment function;
2. package checks whether the required BugSigDB artifact is already cached locally;
3. if not cached, package downloads the artifact from `gh-pages`;
4. package validates checksum and loads the object;
5. enrichment runs without the user manually downloading any annotation file;
6. future runs reuse the cache;
7. if remote download is unavailable but the cache exists, analysis still works.

## 5. v1 Functional Requirements

### 5.1 Registry

The package must be able to resolve a logical dataset key into a downloadable artifact definition.

Minimum supported keys in v1:

- `bugsigdb`

Recommended registry shape:

```r
list(
  bugsigdb = list(
    dataset = "bugsigdb",
    version = "2026-05-22",
    manifest_url = "https://<org>.github.io/MicrobiomeProfiler/datasets/bugsigdb/current/manifest.json"
  )
)
```

The registry may be stored in one of two ways:

- bundled lightweight JSON file in `inst/extdata/`
- remote `latest.json` with a bundled fallback copy

Recommended v1 choice:

- ship a lightweight bundled fallback registry file;
- allow remote refresh later.

This avoids first-run bootstrap problems.

### 5.2 Cache

The package must cache downloaded artifacts under:

```r
tools::R_user_dir("MicrobiomeProfiler", which = "cache")
```

Minimum cache operations:

- ensure cache directory exists;
- detect whether a dataset version is already cached;
- store downloaded manifest alongside artifact files;
- remove partially downloaded files when validation fails.

### 5.3 Download

The package must:

- download manifest JSON;
- parse artifact metadata;
- download artifact file(s);
- compute checksum;
- compare checksum with manifest;
- stop with a clear error if validation fails.

v1 does not need:

- parallel download
- mirror support
- advanced retry strategy

### 5.4 Load

The package must load an artifact into an R object through a single internal entry point.

Recommended v1 artifact format:

- `rds`

Recommended loader behavior:

- inspect the resolved local artifact path;
- load using `readRDS()`;
- validate minimal object structure before returning.

### 5.5 Enrichment integration

v1 should add one public path that proves the new architecture works.

Recommended v1 public API shape:

- either add `source = c("disbiome", "bugsigdb")` to a disease/signature enrichment function;
- or add a small new entry point specifically for BugSigDB.

Recommended choice for v1:

- prefer a **small dedicated public entry point** if that is simpler than widening `enrichMDA()` immediately.

Reason:

- lower regression risk;
- easier test surface;
- avoids forcing Disbiome and BugSigDB into the same exact schema in the first patch.

Possible naming options:

- `enrichBugSigDB()`
- `enrichMDSig()`

Recommended v1 name:

- `enrichBugSigDB()`

This makes the pilot explicit and keeps the diff surgical.

## 6. v1 Data Model

### 6.1 Manifest schema

Minimum manifest fields:

- `dataset`
- `version`
- `released_at`
- `source`
- `source_url`
- `schema_version`
- `artifact_files`
- `record_count`

Minimum artifact entry fields:

- `name`
- `url`
- `sha256`
- `size_bytes`
- `object_type`

Example:

```json
{
  "dataset": "bugsigdb",
  "version": "2026-05-22",
  "released_at": "2026-05-22T00:00:00Z",
  "source": "BugSigDB",
  "source_url": "https://bugsigdb.org/",
  "schema_version": "1.0.0",
  "record_count": 13083,
  "artifact_files": [
    {
      "name": "bugsigdb_signatures.rds",
      "url": "https://<org>.github.io/MicrobiomeProfiler/datasets/bugsigdb/current/bugsigdb_signatures.rds",
      "sha256": "<sha256>",
      "size_bytes": 1234567,
      "object_type": "term2gene_bundle"
    }
  ]
}
```

### 6.2 Runtime object shape

For v1, the downloaded `rds` object should be an R list with explicit fields rather than a loose data frame.

Recommended shape:

```r
list(
  dataset = "bugsigdb",
  version = "2026-05-22",
  term2gene = data.frame(term = character(), gene = character()),
  term2name = data.frame(term = character(), name = character()),
  metadata = data.frame(term = character(), body_site = character(), condition = character())
)
```

Reason:

- simple to validate;
- future-friendly;
- compatible with `clusterProfiler::enricher()` style inputs.

### 6.3 Taxonomic normalization

v1 should keep taxonomic normalization conservative.

Rules:

- normalize obvious whitespace and case issues;
- preserve original taxon labels from the source;
- do not attempt aggressive ontology harmonization in v1;
- document expected supported input level, such as genus/species names, in the man page.

## 7. Repository Changes

### 7.1 New R files

Recommended new files:

- `R/data_registry.R`
- `R/data_cache.R`
- `R/data_download.R`
- `R/data_loader.R`
- `R/enrichBugSigDB.R`

The actual file split can be adjusted, but the responsibilities should remain separated.

### 7.2 New build scripts

Recommended new scripts:

- `data-raw/build_bugsigdb.R`
- `data-raw/publish_external_data.R`

Responsibilities:

- `build_bugsigdb.R`
  - fetch and normalize upstream BugSigDB data
  - produce `bugsigdb_signatures.rds`
  - produce `manifest.json`
- `publish_external_data.R`
  - stage generated files for `gh-pages`
  - update `index.json` and `latest.json`

### 7.3 New metadata files

Recommended additions:

- `inst/extdata/external_data_registry.json`
- `inst/extdata/external_data_registry_schema.json` if desired later

### 7.4 Workflow files

Recommended workflow additions:

- `.github/workflows/update_external_data.yml`
- `.github/workflows/validate_external_data.yml`

### 7.5 Tests

Recommended additions:

- `tests/testthat/test_external_data_registry.R`
- `tests/testthat/test_external_data_cache.R`
- `tests/testthat/test_enrichBugSigDB.R`

v1 tests should prefer small mock fixtures over real network access.

## 8. Workflow Design

### 8.1 Update workflow

`update_external_data.yml` should:

1. check out the main branch;
2. install package dependencies;
3. run BugSigDB build script;
4. validate manifest and artifact output;
5. publish generated files to `gh-pages`;
6. skip publish if no content changed.

### 8.2 Publish target

Recommended `gh-pages` dataset path in v1:

```text
datasets/
  bugsigdb/
    current/
      manifest.json
      bugsigdb_signatures.rds
```

v1 does not need version snapshots if they complicate the pipeline.

Recommended compromise:

- keep `current/` only in v1 if simplicity matters most;
- reserve versioned paths for v2.

If version snapshots are cheap to add, they are still preferred.

### 8.3 Validation workflow

`validate_external_data.yml` should verify:

- manifest JSON parses;
- required fields exist;
- artifact file exists;
- artifact checksum matches manifest;
- artifact `readRDS()` succeeds;
- object has required fields.

## 9. Runtime Control Surface

### 9.1 Internal functions

Recommended internal function set:

- `mp_external_registry()`
- `mp_cache_dir()`
- `mp_dataset_cache_path()`
- `mp_fetch_manifest()`
- `mp_download_artifact()`
- `mp_validate_artifact()`
- `mp_get_dataset()`

### 9.2 Optional user-facing helpers

v1 may add these, but they are not mandatory:

- `mp_cache_info()`
- `mp_clear_cache()`
- `downloadMicrobiomeProfilerData()`

Recommended v1 stance:

- keep these internal unless package ergonomics clearly need them during implementation.

## 10. Failure Modes

### 10.1 No network, no cache

Behavior:

- stop with an actionable error;
- tell the user which dataset could not be retrieved;
- tell the user how to retry later.

### 10.2 No network, cache exists

Behavior:

- use cached copy;
- emit a message, not an error.

### 10.3 Manifest download succeeds, artifact checksum fails

Behavior:

- remove invalid local file;
- stop with a validation error.

### 10.4 Artifact structure invalid

Behavior:

- stop with a schema error;
- keep the manifest for debugging if useful;
- do not silently continue.

## 11. v1 Testing Strategy

### 11.1 Unit tests

Test:

- registry lookup
- cache path generation
- manifest parsing
- checksum validation
- object validation

### 11.2 Integration tests

Test:

- local fixture manifest plus local fixture artifact simulate remote download;
- `mp_get_dataset("bugsigdb")` returns a valid object;
- `enrichBugSigDB()` completes on a toy input vector.

### 11.3 Non-goal for tests

Do not depend on live BugSigDB network access in `testthat`.

CI and package tests should remain deterministic.

## 12. Migration Impact

### 12.1 Existing code left unchanged in v1

- existing KEGG, COG, HMDB, SMPDB flows
- current `sysdata.rda` usage for bundled paths
- most current Shiny modules

### 12.2 Existing code that may need small touchpoints

- package globals or helper loading paths
- roxygen docs for new function(s)
- vignette examples if the new dataset is exposed publicly

## 13. Acceptance Criteria

v1 is done when all of the following are true:

- `gh-pages` hosts a valid BugSigDB artifact and manifest;
- package can resolve, download, validate, cache, and load the dataset;
- one enrichment function uses the remote dataset end-to-end;
- tests cover manifest parsing, caching, validation, and enrichment smoke behavior;
- package still works for existing built-in flows;
- no large BugSigDB artifact is bundled into the package tarball.

## 14. Recommended Follow-up After v1

After v1 is stable:

1. move Disbiome into the same external delivery mechanism;
2. add versioned snapshots on `gh-pages` if not already implemented;
3. add GO/QuickGO + GOA/UniProt as the next remote dataset family;
4. add a lightweight user-facing cache management helper if user support requires it.

