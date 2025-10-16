# BAS2XEX: Convert Atari BAS files to DOS loadable programs

This is a little utility that adds an assembly loader to an Atari BASIC file to
convert to a DOS loadable format (XEX file).

The loader also automatically enables BASIC ROM in the XL/XE computers before
loading and running the program.

## Usage

To convert a `BAS` file to a `XEX` file, use the command:

```
    bas2xex PROGRAM.BAS PROGRAM.XEX
```

## About the loader

The loader works in the following way:

* The loader code is stored at page 6.
* The original BASIC data is stored at $2000 and upwards.
* The loader first enables BASIC and reloads the editor.
* Then a minimal CIO handler for the `E:` device is installed, that redirects
  BASIC input to execute the `RUN "E:"` statement.
* BASIC then opens the redirected CIO handler and reads all the original
  binary data.
* When BASIC closes the handler, the handler is removed.

As the original BAS is loaded initially at address $2000, BAS files up to $7C00
bytes are supported.

