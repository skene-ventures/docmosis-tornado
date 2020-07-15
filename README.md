![Docmosis](https://raw.githubusercontent.com/mikehhodgson/tornado/master/images/docmosis.png)

# Docmosis Tornado 2.8.2 (Build:9203)

Based on the original Docmosis Tornado (BETA) container build from [Mike Hodgson](https://github.com/mikehhodgson/tornado)
with some small changes.

## Changes

* Moved from Centos:7 to Alpine:latest (approx. 50% space saving)
* Added default JAVA_TOOL_OPTIONS for a semi-sane container build
* Moved some variables to build arguments for easier CI/CD operations
* Added env variable LOG4J_LOGLEVEL for runtime choice (default is INFO)
* Sources HOMEDIR/env.inc prior to running Docmosis

## Instructions

Simply browse to the folder containing the Dockerfile and run

```powershell
docker build -t skeneventures/docmosis-tornado .
docker run --rm -dP skeneventures/docmosis-tornado
```

## Detailed Instructions

This is a clone from https://github.com/mikehhodgson/tornado in most respects so
please consult the _very_ detailed information already avaiable in
[Mike Hodgson's Repository](https://github.com/mikehhodgson/tornado/blob/master/README.md)
