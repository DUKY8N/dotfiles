---
description: Recommend a commit message based on my current Git changes
agent: plan
---

Based on my current Git changes, recommend a commit message in the Conventional Commits style.


## Commit Message Structure

```
<type>[optional scope][!]: <description>

[optional body]

[optional footer(s)]
```


## Core Types

* **feat**
  Introduces a new feature
  → Maps to **MINOR** version in SemVer

* **fix**
  Fixes a bug
  → Maps to **PATCH** version in SemVer

* **BREAKING CHANGE**
  Introduces an incompatible API change
  → Maps to **MAJOR** version in SemVer

  * Can be expressed by:

    * `!` after type or scope
    * `BREAKING CHANGE:` footer


## Additional Types

Other types are allowed (no SemVer effect unless breaking):

* `build`
* `chore`
* `ci`
* `docs`
* `style`
* `refactor`
* `perf`
* `test`
* etc.

Commonly used conventions are derived from the **Angular commit guidelines**.


## Scope

* Optional
* Describes the affected part of the codebase
* Written in parentheses after the type

Example:

```
feat(parser): add array parsing support
```


## Description

* Required
* Short summary of the change
* Must immediately follow `type(scope): `


## Body

* Optional
* Provides additional context
* Starts after one blank line
* Free-form, may contain multiple paragraphs


## Footers

* Optional
* Appear after one blank line following the body
* Format inspired by Git trailers

Examples:

```
Reviewed-by: Alice
Refs: #123
```

Rules:

* Footer tokens use hyphens instead of spaces (`Acked-by`)
* `BREAKING CHANGE` is an exception and must be uppercase
* `BREAKING-CHANGE` is treated as equivalent


## Breaking Changes Rules

Breaking changes **must** be indicated by:

* `!` before the colon
  or
* `BREAKING CHANGE:` footer

If `!` is used:

* Footer is optional
* Description should explain the breaking change


## Case Sensitivity

* Commit elements are case-insensitive
* Exception: `BREAKING CHANGE` **must** be uppercase


## Reverts

* No strict rules defined
* Recommended approach:

```
revert: revert problematic change

Refs: <commit-sha>
```

---

