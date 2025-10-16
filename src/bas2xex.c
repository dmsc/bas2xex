/*
 * Loads a BASIC file from memory - used to convert BAS to XEX.
 * -----------------------------------------------------------
 *
 * (c) 2025 DMSC
 * Code under MIT license, see LICENSE file.
 */

#include <stdio.h>
#include <string.h>
#include <errno.h>

#include "loader.h"

#define MAX_SIZE (0x7C00)
unsigned char buf[MAX_SIZE];

static void w16(int x, FILE *f)
{
    putc(x & 0xFF, f);
    putc(x >> 8, f);
}

int convert(const char *in, const char *out)
{
    FILE *fin = fopen(in, "rb");
    if(!fin)
    {
        fprintf(stderr, "%s: error, can't open input file: %s\n", in, strerror(errno));
        return 1;
    }
    size_t len = fread( buf, 1, MAX_SIZE, fin);
    if( len >= MAX_SIZE )
    {
        fprintf(stderr, "%s: error, file is too big, max size is %d bytes.\n",
                in, MAX_SIZE);
        fclose(fin);
        return 1;
    }
    if( !feof(fin) )
    {
        fprintf(stderr, "%s: error reading file: %s\n",in, strerror(errno));
        return 1;
    }
    fclose(fin);
    if( len < 19 )
    {
        fprintf(stderr, "%s: error, file too short.\n",in);
        return 1;
    }
    if( buf[0] != 0 || buf[1] != 0 )
    {
        fprintf(stderr, "%s: error, not an Atari BASIC file.\n",in);
        return 1;
    }
    // Ok, now we need to adjust the BASIC loader
    if(loader_len < 64)
        return 1; // Internal error!
    int ini = loader[loader_len - 8] + (loader[loader_len - 7] << 8);
    ini = ini - len;
    loader[loader_len - 8] = ini & 0xFF;
    loader[loader_len - 7] = ini >> 8;
    // Write all:
    FILE *fout = fopen(out, "wb");
    if(!fout)
    {
        fprintf(stderr, "%s: error, can't open output file: %s\n", in, strerror(errno));
        return 1;
    }
    if( loader_len != fwrite( loader, 1, loader_len, fout) )
    {
        fprintf(stderr, "%s: error writing file: %s\n",in, strerror(errno));
        fclose(fout);
        return 1;
    }
    // Write section header
    w16(0x2000, fout);
    w16(0x2000 + len - 1, fout);
    // Write BASIC data
    if( len != fwrite( buf, 1, len, fout) )
    {
        fprintf(stderr, "%s: error writing file: %s\n",in, strerror(errno));
        fclose(fout);
        return 1;
    }
    // Ok
    if( fclose(fout) )
    {
        fprintf(stderr, "%s: error writing file: %s\n",in, strerror(errno));
        return 1;
    }
    return 0;
}

int main(int argc, char **argv)
{
    if(argc != 3)
    {
        printf("BAS2XEX 1.0 - (c) 2025 dmsc\n\n"
               "Usage: %s [input.bas] [output.xex]\n"
               "\n"
               "Converts Atari BASIC file (.bas) to a DOS loadable file (.xex).\n"
               "The converted program enables BASIC if possible and runs the\n"
               "program automatically.\n",
               argv[0]);
        return 1;
    }

    return convert(argv[1], argv[2]);
}
