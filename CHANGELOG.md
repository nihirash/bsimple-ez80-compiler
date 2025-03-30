# Change Log

All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/).

## [0.0.4] - Unreleased

### Added

- Including `.bs` files during compilation(using `include` keyword)
- Alternative startup import - for building MOSlets.
- `bs.bin` moslet for building binaries in with a single command
- "Notes of a Madman" - history of creating compiler
- Flag for automatical run of assembler, when building project using crossbuild system

### Updated

- Building configuration for crossbuild moved to Makefile.cross-config 
- `for` loop checks condition before execution of loop's body now

### Fixed

- `strstr` function now works correctly when substring is located at last characters
- Arguments buffer now works correctly and handles errors

## [0.0.3] - 22 Feb 2025

### Added
 
- New loop syntaxes
- Arm64 Linux build
- "Arcade" game library

### Updated

- Standard library
- General stabilization
- `Learn you...` documentation now building automatically  

## [0.0.2] Initial public release

Initial public version