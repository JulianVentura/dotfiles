#!/bin/sh

git config --local filter.clean_smudge.clean ".gitfilters/clean.py %f"
git config --local filter.clean_smudge.smudge ".gitfilters/smudge.sh %f"
