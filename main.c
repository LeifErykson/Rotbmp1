#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern void rotbmp1(void *img, int width, void *new_img);

int main(int argc, const char *argv[]) {
    if (argc != 2) {
        printf("Please provide a filename e.g. image/10x10.bmp");
        return 0;
    }
    FILE *fp;
    fp = fopen(argv[1], "rb");
    if (fp == NULL) {
        printf("File not found.\n");
        return 0;
    }
    unsigned short headerField, bpp;
    fread(&headerField, 2, 1, fp);
    if (headerField != 0x4D42) {
        printf("File is not a supported image (header start is not \"BM\")\n");
        return 0;
    }
    fseek(fp, 28, SEEK_SET);
    fread(&bpp, 2, 1, fp);
    if (bpp != 1) {
        printf("Only 1 bpp is supported, %d were given.\n", bpp);
        return 0;
    }
    unsigned int width, height;
    fseek(fp, 18, SEEK_SET);
    fread(&width, 4, 1, fp);
    fread(&height, 4, 1, fp);
    int bytes_per_row=((height+31)/32)*4;;
    if (width != height) {
        printf("Only square images are supported, %dx%d were given.\n", width, height);
        return 0;
    }

    unsigned int bmpSize, offset;

    fseek(fp, 2, SEEK_SET);
    fread(&bmpSize, 4, 1, fp);

    fseek(fp, 10, SEEK_SET);
    fread(&offset, 4, 1, fp);

    void *entireImg = malloc(bmpSize);
    void *img = entireImg + offset;
    int pixel_array_size = bmpSize - offset;
    void *new_img = malloc(pixel_array_size);
    fseek(fp, 0, SEEK_SET);
    fread(entireImg, 1, bmpSize, fp);
    fclose(fp);

    rotbmp1(img, (int)width, new_img);

    fp = fopen(argv[1], "wb");
    if (fp == NULL) {
        printf("An error occurred while opening the file to write.\n");
        return 0;
    }
    fwrite(entireImg, 1, offset, fp);
    fwrite(new_img, 1, pixel_array_size, fp);
    fclose(fp);
    free(entireImg);
    free(new_img);
    return 0;
}