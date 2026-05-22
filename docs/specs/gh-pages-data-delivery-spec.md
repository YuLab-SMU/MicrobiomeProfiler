# MicrobiomeProfiler External Data Delivery Spec

## 1. Background

`MicrobiomeProfiler` is evolving from a small built-in annotation package into a microbiome enrichment toolkit that may depend on larger and more frequently updated external data sources. The current package still bundles internal data in `R/sysdata.rda`, and the existing workflow updates that file directly through GitHub Actions.

This approach is acceptable for small, stable datasets, but it does not scale well once new sources such as BugSigDB, GO/QuickGO + GOA/UniProt, eggNOG, gutMDisorder, MGnify-derived background sets, or other large annotation resources are introduced.

The package should therefore move toward a DOSE-like pattern:

- keep the R package lightweight;
- host distributable data artifacts outside the package tarball;
- download data on demand at runtime;
- cache data locally for reuse;
- update remote data artifacts automatically via CI.

This document defines the target architecture and a phased migration plan.

## 2. Goals

### 2.1 Primary goals

- Prevent the package from becoming large due to bundled annotation assets.
- Support timely updates of remote data without requiring a package release for every data refresh.
- Provide a stable runtime API so enrichment functions can transparently access required datasets.
- Keep data delivery reproducible through versioned manifests and checksums.
- Reuse the same architecture for all future expansion lines:
  - A: disease/signature databases
  - B: ontology/function databases
  - C: ortholog/group databases
  - D: universe/background databases

### 2.2 Non-goals

- This spec does not define the full schema for each external database.
- This spec does not require immediate removal of all current built-in data.
- This spec does not require a Shiny UX redesign in the first phase.

## 3. Design Principles

- **Package code is small; data lives outside the package.**
- **Runtime access is lazy; download only when needed.**
- **Downloaded files are cached locally and reused.**
- **Remote data is immutable per version whenever possible.**
- **Every downloadable artifact is described by a machine-readable manifest.**
- **CI updates data artifacts independently of package release cadence.**
- **Current enrichment APIs should change as little as possible.**

## 4. Current State

The current repository contains:

- bundled example data in `data/`;
- bundled internal annotation data in `R/sysdata.rda`;
- update logic in `data-raw/update_sysdata.R`;
- scheduled updates in `.github/workflows/update_data.yml`.

At least one important source, `Disbiome`, is currently not fully automated and still depends on manual export availability. This makes the current direct-to-`sysdata.rda` workflow less suitable as the long-term architecture.

## 5. Proposed Architecture

### 5.1 Overview

Use the repository's `gh-pages` branch as the public distribution channel for generated annotation artifacts.

The architecture has four layers:

1. **Source builders**
   - Scripts in the main branch fetch and normalize upstream data.
   - Output is written as serialized artifact files plus metadata.

2. **Distribution branch**
   - Built artifacts are published to `gh-pages`.
   - `gh-pages` acts as a static data registry rather than a documentation-only branch.

3. **Manifest-driven package runtime**
   - Package code reads a manifest describing available datasets, versions, URLs, hashes, and local file names.
   - When an enrichment function needs a dataset, the package resolves it through the manifest.

4. **Local cache**
   - Remote files are downloaded to a user cache directory on first use.
   - Future runs reuse the local copy unless refresh is requested.

### 5.2 Data flow

```text
upstream data source
  -> build script in main branch
  -> normalized artifact(s)
  -> manifest.json / manifest.tsv
  -> publish to gh-pages
  -> package runtime resolves dataset key
  -> download to local cache
  -> load into enrichment function
```

## 6. Distribution Layout on `gh-pages`

The `gh-pages` branch should be used as a static file store with a predictable layout.

Suggested structure:

```text
/
  index.json
  latest.json
  datasets/
    disbiome/
      current/
        manifest.json
        disbiome_gson.rds
      2026-05/
        manifest.json
        disbiome_gson.rds
    bugsigdb/
      current/
        manifest.json
        bugsigdb_signatures.rds
    go/
      current/
        manifest.json
        go_term2gene.rds
    eggnog/
      current/
        manifest.json
        eggnog_og_map.rds
    universe/
      human_gut/
        current/
          manifest.json
          universe_human_gut.rds
```

### 6.1 Required files

- `index.json`
  - registry of all datasets and current versions
- `latest.json`
  - optional compact registry for fast runtime lookup
- dataset-level `manifest.json`
  - describes a single published artifact set
- artifact files
  - `rds`, `qs`, `json`, `tsv.gz`, or other formats chosen per use case

### 6.2 Manifest fields

Each dataset manifest should include at minimum:

- `dataset`
- `version`
- `released_at`
- `source`
- `source_url`
- `artifact_files`
- `sha256`
- `record_count`
- `taxonomy_level` if relevant
- `schema_version`
- `package_min_version` if relevant

Example:

```json
{
  "dataset": "bugsigdb",
  "version": "2026-05-22",
  "released_at": "2026-05-22T00:00:00Z",
  "source": "BugSigDB",
  "source_url": "https://bugsigdb.org/",
  "artifact_files": [
    {
      "name": "bugsigdb_signatures.rds",
      "url": "https://<org>.github.io/MicrobiomeProfiler/datasets/bugsigdb/current/bugsigdb_signatures.rds",
      "sha256": "<hash>",
      "size_bytes": 1234567
    }
  ],
  "record_count": 13083,
  "schema_version": "1.0.0"
}
```

## 7. Runtime Package Design

### 7.1 New internal responsibilities

The package should introduce a small internal data access layer, for example:

- `mp_data_registry()`
  - read remote or bundled registry metadata
- `mp_resolve_dataset()`
  - map logical dataset keys to a manifest entry
- `mp_cache_dir()`
  - return the local cache path
- `mp_download_dataset()`
  - download and validate artifact files
- `mp_load_dataset()`
  - load cached artifact into R objects
- `mp_refresh_dataset()`
  - force refresh of cached files

These helpers should be internal first, then selectively exposed only if needed.

### 7.2 Cache location

Use a user cache directory rather than the package library.

Recommended approach:

- `tools::R_user_dir("MicrobiomeProfiler", which = "cache")`

Cache layout:

```text
<cache_root>/
  registry/
    latest.json
  datasets/
    bugsigdb/
      2026-05-22/
        manifest.json
        bugsigdb_signatures.rds
    disbiome/
      2026-05-22/
        manifest.json
        disbiome_gson.rds
```

### 7.3 Download behavior

Default behavior:

- if the requested dataset is already cached and passes checksum validation, reuse it;
- otherwise, download it from `gh-pages`;
- if download fails but a valid cached copy exists, fall back to the cached copy;
- if neither remote nor cache is available, throw a clear error with remediation instructions.

Optional later features:

- `options(MicrobiomeProfiler.cache_dir = "...")`
- `options(MicrobiomeProfiler.offline = TRUE)`
- proxy support
- timeout and retry controls

### 7.4 Backward compatibility

The first migration phase should keep current public enrichment APIs stable.

Examples:

- `enrichMDA()` should still work without requiring users to manually prepare a gson object.
- Existing small bundled datasets may remain in `sysdata.rda` temporarily.
- A dataset resolver may prefer external artifacts first, then fall back to bundled data during transition.

Suggested temporary policy:

- **small/stable/core** resources may remain bundled for now;
- **large/frequently updated/expanding** resources must move to remote delivery.

## 8. CI / GitHub Actions Design

### 8.1 Split responsibilities

The current `update_data.yml` updates `R/sysdata.rda` in the main branch. Under the new design, CI responsibilities should be split:

1. **build-external-data**
   - fetch upstream data
   - normalize into package-specific artifacts
   - generate manifests
   - publish artifacts to `gh-pages`

2. **validate-external-data**
   - check artifact readability
   - check manifest schema
   - check hashes and record counts

3. **optionally update lightweight in-package metadata**
   - update registry stubs or fallback metadata in the main branch if needed

### 8.2 Publish strategy

Recommended CI behavior:

- run on schedule and `workflow_dispatch`;
- build data into a temporary directory;
- compare against the current published manifest;
- only publish to `gh-pages` when content actually changes;
- keep `current/` plus versioned snapshots;
- write checksums before publish;
- publish through a dedicated action or a controlled git push to `gh-pages`.

### 8.3 Suggested workflow split

- `.github/workflows/update_external_data.yml`
  - scheduled artifact build and publish
- `.github/workflows/validate_external_data.yml`
  - PR/manual validation

The current `.github/workflows/update_data.yml` can be retained during migration, then simplified or retired once the package stops relying on large `sysdata.rda` updates.

## 9. Artifact Format Strategy

### 9.1 Recommended formats

- `rds`
  - best default for package-native R objects
- `tsv.gz`
  - useful for transparent inspection and cross-language interoperability
- `json`
  - ideal for manifests and lightweight indexes

### 9.2 Initial recommendation

For first implementation:

- store manifests as `json`;
- store package-consumed objects as `rds`;
- optionally store a parallel tabular export for inspection if debugging value is high.

This keeps the runtime loader simple while preserving inspectability at the metadata level.

## 10. Phased Rollout

### 10.1 Phase A: disease/signature line

Scope:

- keep `Disbiome` support;
- add `BugSigDB` as the first new remote-delivered dataset;
- optionally reserve extension points for `gutMDisorder`.

Reason:

- highest immediate user value;
- most visible gain over current `Microbe-Disease` enrichment;
- good pilot for manifest, cache, and `gh-pages` publishing.

Deliverables:

- remote `disbiome` artifact
- remote `bugsigdb` artifact
- runtime resolver for disease/signature datasets
- one enrichment entry point that can switch between sources

### 10.2 Phase B: ontology/function line

Scope:

- add GO/QuickGO + GOA/UniProt derived function annotations.

Reason:

- complements current `KEGG` and `COG`;
- introduces ontology-aware enrichment without overloading the package tarball.

Deliverables:

- remote GO annotation artifacts
- loader and validator
- function enrichment interface or internal annotation bridge

### 10.3 Phase C: ortholog/group line

Scope:

- add `eggNOG`-derived ortholog/group resources.

Reason:

- extends beyond current `COG`;
- supports future OG-based enrichment or mapping workflows.

Deliverables:

- remote `eggNOG` artifacts
- schema for OG-to-KO/GO mapping if needed

### 10.4 Phase D: universe/background line

Scope:

- add environment/body site/host-specific background sets from sources such as `MGnify`, `curatedMetagenomicData`, or `GMrepo`.

Reason:

- improves enrichment calibration by replacing generic universes with context-aware ones.

Deliverables:

- remote universe datasets
- manifest fields for context tags such as `host`, `body_site`, `environment`, `disease_scope`
- helper to select a matching universe

## 11. Migration Strategy

### 11.1 Stage 1

- Introduce registry, downloader, cache, and loader infrastructure.
- Keep current bundled data path as fallback.
- Publish at least one pilot dataset to `gh-pages`.

### 11.2 Stage 2

- Move large and update-heavy datasets fully off `sysdata.rda`.
- Update enrichment functions to use remote resolution by default.

### 11.3 Stage 3

- Reduce `sysdata.rda` to only lightweight fallback data, tiny examples, or package boot metadata.
- Retire old direct bundling logic for datasets that are now remote-first.

## 12. Risks and Mitigations

### 12.1 Network availability

Risk:

- users may work offline or behind strict networks.

Mitigation:

- always use cache first when available;
- document manual prefetch options;
- support refresh and offline modes later.

### 12.2 Broken upstream source

Risk:

- upstream exports may disappear or become unstable.

Mitigation:

- publish normalized snapshots to `gh-pages`;
- decouple runtime from upstream availability;
- fail CI without breaking already published datasets.

### 12.3 Data/schema drift

Risk:

- upstream columns or semantics may change silently.

Mitigation:

- version manifest schema;
- validate structure in CI;
- store record counts and hashes;
- add regression tests against representative artifacts.

### 12.4 GitHub Pages limitations

Risk:

- very large artifacts may be awkward to serve from `gh-pages`.

Mitigation:

- keep files compressed and split by dataset;
- publish only normalized package-ready subsets;
- if size eventually exceeds reasonable Pages usage, retain the same runtime abstraction and swap storage backend later.

## 13. Open Decisions

- Should `gh-pages` hold only current artifacts, or both `current/` and version snapshots by default?
- Which datasets should remain bundled permanently as lightweight fallbacks?
- Should remote data loading be entirely implicit, or should some functions expose a `download = TRUE/FALSE` or `source =` argument?
- Should the package ship a tiny built-in registry stub so first-run discovery does not depend on network?
- For Shiny mode, should the app preflight-check required datasets before users launch a long analysis?

## 14. Recommended First Implementation Slice

The first implementation should be intentionally narrow:

1. add cache and manifest infrastructure;
2. publish one pilot dataset to `gh-pages`;
3. integrate one enrichment path end-to-end;
4. validate the UX and CI model before expanding to B/C/D.

Recommended pilot:

- use **BugSigDB** as the first remote-delivered dataset;
- optionally move **Disbiome** into the same remote architecture at the same time if the normalized export is stable enough.

This gives the project a production-like test of the whole path without forcing a full migration in one step.

## 15. Success Criteria

The design is considered successful when:

- package size no longer grows with large annotation datasets;
- at least one enrichment workflow runs using a remote dataset cached locally;
- CI can update published data artifacts without requiring a package release;
- dataset integrity is validated through manifest metadata and checksums;
- the same mechanism can be reused for A/B/C/D expansion lines.

