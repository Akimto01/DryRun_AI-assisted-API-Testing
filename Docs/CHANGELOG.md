# Changelog

All notable changes to this project are documented here.
Format loosely follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added
- Initial scaffold: Robot Framework + Browser Library (UI) and
  RequestsLibrary (API) test framework for Todoist, targeting
  `https://api.todoist.com/api/v1` and `https://app.todoist.com`.
- Smoke/regression/known_defect tagging scheme, `config/known_defects.yaml`
  registry, `run-tests.ps1` entry point, and `pr_gate.yml` / `nightly.yml`
  GitHub Actions workflows.
