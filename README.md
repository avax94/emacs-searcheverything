# emacs-searcheverything

This package is emacs client for Windows [SearchEverything](https://www.voidtools.com/) program.
SearchEverything is program that let's you search files/folders on your machine amaizingly fast, and now from within emacs.

# [Installation][#Installation]

## Installation
First you need to download two things:
 - SearchEverything
 - SearchEverything command line tool

 Both can be found [here](https://www.voidtools.com/downloads/)

For setup within emacs:
    - Download searcheverything.el from this repo
    - Open searcheverything.el file and run `M-x RET package-install-from-buffer RET`
    - Add to your init file
    `(require 'searcheverything)`
     `(setq searcheverything-cli-path (concat everything-cli-install-dir "es.exe")`
    - Bind key for fast command access e.g.
    `(global-set-key (kbd "C-h e") #'searcheverything-execute-query)`
