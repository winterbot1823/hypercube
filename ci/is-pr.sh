#!/bin/bash -e
#
# The standard BUILDKITE_PULL_REQUEST environment variable is always "false" due
# to how hypercube-ci-gate is used to trigger PR builds rather than using the
# standard Buildkite PR trigger.
#

[[ $BUILDKITE_BRANCH =~ pull/* ]]
