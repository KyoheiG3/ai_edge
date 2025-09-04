#!/bin/bash

set -e

{
	git ls-files -z -- '*.dart'
	git ls-files -z -o --exclude-standard -- '*.dart'
} | xargs -0 dart format $@
