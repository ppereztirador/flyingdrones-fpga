#include <stdio.h>
#include <math.h>
#include <stdint.h>

#define SIZE_CACHE 7*256*127+7*255+10-4 + 1

void generate_cache_hops(uint16_t *cache)
{
    int min_error, next_error, quantum, hop_increment;
    uint8_t hop;
    double rpos, rneg;

    const double maxr = 4.0; // LHE_c= 4.0  LHE_Pi = 2.7
    const double minr = 1.0; // LHE_c= 1.0  LHE_Pi = 1.0
    const double range = 0.8; // LHE_c= 0.8  LHE_Pi = 0.70


    const uint8_t hopn4 = 0;
    const uint8_t hopn3 = 1;
    const uint8_t hopn2 = 2;
    const uint8_t hopn1 = 3;
    const uint8_t hop0 = 4;
    const uint8_t hopp1 = 5;
    const uint8_t hopp2 = 6;
    const uint8_t hopp3 = 7;
    const uint8_t hopp4 = 8;

    const int minimum_value = 1;
    const int maximum_value = 255 - minimum_value;

    for (int orig = 0; orig < 128; orig++) // Orig va hasta 128 por que la cache es simetrica.
    {
        for (int pred = 0; pred < 256; pred++)
        {
            for (int h1 = 4; h1 <= 10; h1++)
            {
                //Por defecto el hop es hop0
                hop = hop0;
                quantum = pred;
                min_error = fabs(orig - pred);

                rpos = pow(range * ((maximum_value - pred) / h1), 1.0 / 3.0);
                rpos = rpos > maxr ? maxr : rpos < minr ? minr : rpos;
                rneg = pow(range * ((pred - minimum_value) / h1), 1.0 / 3.0);
                rneg = rneg > maxr ? maxr : rneg < minr ? minr : rneg;

                if (min_error > h1 / 2)
                {
                    if (orig >= pred) // Hops positivos
                    {
                        if (pred + h1 <= 255)
                        {
                            hop_increment = h1;
                            next_error = fabs(orig - (pred + hop_increment));
                            if (next_error < min_error)
                            {
                                hop = hopp1;
                                quantum = pred + hop_increment;
                                min_error = next_error;
                                hop_increment = (int)round(h1 * rpos);
                                next_error = fabs(orig - (pred + hop_increment));

                                if (next_error < min_error)
                                {
                                    hop = hopp2;
                                    quantum = pred + hop_increment;
                                    min_error = next_error;
                                    hop_increment = (int)round(h1 * rpos * rpos);
                                    next_error = fabs(orig - (pred + hop_increment));

                                    if (next_error < min_error)
                                    {
                                        hop = hopp3;
                                        quantum = pred + hop_increment;
                                        min_error = next_error;
                                        hop_increment = (int)round(h1 * rpos * rpos * rpos);
                                        next_error = fabs(orig - (pred + hop_increment));

                                        if (next_error < min_error)
                                        {
                                            hop = hopp4;
                                            quantum = pred + hop_increment;
                                            min_error = next_error;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else if (orig < pred) // Hops negativos
                    {
                        if (pred - h1 >= 0)
                        {
                            hop_increment = h1;
                            next_error = fabs(orig - (pred - hop_increment));
                            if (next_error < min_error)
                            {
                                hop = hopn1;
                                quantum = pred - hop_increment;
                                min_error = next_error;
                                hop_increment = (int)round(h1 * rneg);
                                next_error = fabs(orig - (pred - hop_increment));

                                if (next_error < min_error)
                                {
                                    hop = hopn2;
                                    quantum = pred - hop_increment;
                                    min_error = next_error;
                                    hop_increment = (int)round(h1 * rneg * rneg);
                                    next_error = fabs(orig - (pred - hop_increment));

                                    if (next_error < min_error)
                                    {
                                        hop = hopn3;
                                        quantum = pred - hop_increment;
                                        min_error = next_error;
                                        hop_increment = (int)round(h1 * rneg * rneg * rneg);
                                        next_error = fabs(orig - (pred - hop_increment));

                                        if (next_error < min_error)
                                        {
                                            hop = hopn4;
                                            quantum = pred - hop_increment;
                                            min_error = next_error;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                quantum = quantum > maximum_value ? maximum_value : quantum < minimum_value ? minimum_value : quantum;
                cache[7 * 256 * orig + 7 * pred + (h1 - 4)] = quantum + (hop << 8);
            }
        }
    }
}

int main() {
    uint16_t cache[SIZE_CACHE];
    int i;
    FILE *fh;
    
    generate_cache_hops(cache);
    
    fh = fopen("cache_gen_c.coe", "w");
    if (fh!=NULL) {
        fprintf(fh, "memory_initialization_radix = 16;\n");
        fprintf(fh, "memory_initialization_vector =\n");
        for (i=0; i<SIZE_CACHE-1; i++) {
            fprintf(fh, "%x,\n", cache[i]);
        }
        fprintf(fh, "%x;", cache[SIZE_CACHE]);
        
        fclose(fh);
    }
    else {
        printf("ERROR OPENING FILE\n");
    }
    
    return 0;
}
