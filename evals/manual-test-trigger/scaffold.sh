#!/usr/bin/env bash
# Seeds the workspace from the shared shop fixture.
exec bash "$(dirname "${BASH_SOURCE[0]}")/../fixture/setup.sh" change
