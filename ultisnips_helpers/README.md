# Summary

Some example and helper utilities to use ultisnips with tmux efficiently.

| File | Usage |
|------|-------|
| lookup.yaml | Yaml file containing operational data for lookup |
| mousetrap_helpers.py | python file to drop into ~/.confing/nvim/pythonx |
| target.snippets | example snippet using mousetrap_helpers.py |
| ultisnips_prep.sh | bash script to convert scripts to use mousetrap_helpers.py |

# Utilities

## lookup yaml

Use this file to record operational data for quick reference.  

## Python file

Use for python interpolation in ultisnips.  Currently only uses to functions:

### target

Get the name of the currently focused tmux window.

### lookup

Given a path to the lookup yaml, does a quick lookup.

## target.snippets

An example snippets file that calls the python file.

## ultisnips_prep.sh

This file preps snippets files to use mousetrap_helpers.py.

FRIENDLYNAME variables become calls to `target()`.


