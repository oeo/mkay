#!/bin/bash
add .
git commit -am "fix"
npm version minor
git push && npm publish
