#!/bin/sh
# test/wrappers/full_demo_wrapper.sh - Wrapper for full demo test
# Changes to project root then runs the demo

cd "$(dirname "$0")/../.."
./terminal-menus-demo.sh
