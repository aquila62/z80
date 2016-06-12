/* z80rnd.c - randu RNG test Version 1.0.0                           */
/* Copyright (C) 2016 aquila62 at github.com                         */

/* This program is free software; you can redistribute it and/or     */
/* modify it under the terms of the GNU General Public License as    */
/* published by the Free Software Foundation; either version 2 of    */
/* the License, or (at your option) any later version.               */

/* This program is distributed in the hope that it will be useful,   */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of    */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the      */
/* GNU General Public License for more details.                      */

/* You should have received a copy of the GNU General Public License */
/* along with this program; if not, write to:                        */

   /* Free Software Foundation, Inc.                                 */
   /* 59 Temple Place - Suite 330                                    */
   /* Boston, MA 02111-1307, USA.                                    */

/********************************************************/
/* z80rnd:                                              */
/* print the seed after "kount" generations             */
/* randu is a "uniform random number generator"         */
/* originally used by IBM during the 1960's             */
/* randu produces an unsigned 32-bit integer,           */
/* called the seed                                      */
/* There are two ways to calculate randu                */
/* * by multiplying the seed by the constant 65539      */
/*   and truncating the product to 32-bits              */
/* * by shifting and adding to produce the same         */
/*   32-bit unsigned product                            */
/* The lower 8 bits of the seed are not random.         */
/* The upper 8 bits of the seed are still not random.   */
/* randu fails many tests for randomness.               */
/* Therefore randu is an example of a bad random        */
/* number generator.                                    */
/* This program is used to verify the randu generator   */
/* in Z80 assembler.  That program is called randu.asm  */
/* and runs in CP/M 2.2 using the yaze emulator.        */
/* Usage for this program is:                           */
/*     z80rnd n                                         */
/* Where n is 1 to 65535.                               */
/* Usage for the Z80 program in yaze is:                */
/*     randu n                                          */
/* Where n is 1 to 65535.                               */
/* The seed is initialized to 01 00 00 00               */
/* in little endian hexadecimal format.                 */
/* After 10000 generations, the seed is 41 03 C5 60     */
/* in little endian hexadecimal format.                 */
/* In big endian format, the seed is 60C50341 hex.      */
/********************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <sys/times.h>

/* print the command line syntax */
void putstx(char *pgm)
   {
   fprintf(stderr,"Usage: %s count\n", pgm);
   fprintf(stderr,"Where count is number of generations\n");
   fprintf(stderr,"for the random number generator, randu\n");
   fprintf(stderr,"Example: %s 500\n", pgm);
   exit(1);
   } /* putstx */

/* display the seed in two formats */
/* the first number is big endian hex */
/* the second number is little endian hex */
/* the two numbers match as the result of equivalent algorithms */
void shwsd(unsigned int cseed, unsigned char *sd)
   {
   unsigned char *p;
   p =  (unsigned char *) sd;
   printf("%08x %02x %02x %02x %02x  "
      "little endian\n",
      cseed, *p, *(p+1), *(p+2), *(p+3));
   } /* shwsd */

/* algorithm using shifts and adds */
/* the result is a new generation of the seed */
void rnd(unsigned char *sd, unsigned char *sd2)
   {
   int carry;
   unsigned char *p,*q,*r;
   /************************************************/
   /* part 1                                       */
   /************************************************/
   carry = 0;
   p = (unsigned char *) sd;
   q = (unsigned char *) sd + 4;
   r = (unsigned char *) sd2;
   while (p < q)
      {
      int tmp;
      tmp = (int) *p;
      tmp = (tmp << 1) + carry;
      if (tmp > 255) carry = 1;
      else carry = 0;
      *r = (unsigned char) (tmp & 255);
      p++;
      r++;
      } /* for each byte in sd */
   /************************************************/
   /* part 2                                       */
   /************************************************/
   carry = 0;
   p = (unsigned char *) sd;
   q = (unsigned char *) sd + 2;
   r = (unsigned char *) sd + 2;
   while (p < q)
      {
      int tmp;
      tmp = (int) *p + *r + carry;
      if (tmp > 255) carry = 1;
      else carry = 0;
      *r = (unsigned char) (tmp & 255);
      p++;
      r++;
      } /* for each byte in sd */
   /************************************************/
   /* part 3                                       */
   /************************************************/
   carry = 0;
   p = (unsigned char *) sd2;
   q = (unsigned char *) sd2 + 4;
   r = (unsigned char *) sd;
   while (p < q)
      {
      int tmp;
      tmp = (int) *p + *r + carry;
      if (tmp > 255) carry = 1;
      else carry = 0;
      *r = (unsigned char) (tmp & 255);
      p++;
      r++;
      } /* for each byte in sd */
   } /* rnd */

int main(int argc, char **argv)
   {
   int i;                       /* loop counter */
   int kount;                   /* number of generations */
   unsigned int cseed;          /* seed by multiplication */
   unsigned int emm;            /* multiplier 65539 */
   unsigned char *sd;           /* shift and add seed */
   unsigned char *sd2;          /* temporary work area */
   unsigned char *p,*q;         /* pointers to the seeds */
   /***************************************************/
   /* Get input parameter, count                      */
   /***************************************************/
   if (argc != 2) putstx(*argv);
   kount = atoi(*(argv+1));
   if (kount < 1)
      {
      fprintf(stderr,"main: kount %s is "
         "less than one\n", *(argv+1));
      putstx(*argv);
      } /* kount is less than one */
   if (kount > 65535)
      {
      fprintf(stderr,"main: kount %s is "
         "greater than 10 thousand\n", *(argv+1));
      putstx(*argv);
      } /* kount > 10000 */
   /***************************************************/
   /* allocate memory for sd                          */
   /***************************************************/
   sd = (unsigned char *) malloc(64);
   if (sd == NULL)
      {
      fprintf(stderr,"main: out of memory "
      "allocating sd\n");
      exit(1);
      } /* out of memory */
   /***************************************************/
   /* allocate memory for sd2                         */
   /***************************************************/
   sd2 = (unsigned char *) malloc(64);
   if (sd == NULL)
      {
      fprintf(stderr,"main: out of memory "
      "allocating sd2\n");
      exit(1);
      } /* out of memory */
   /***************************************************/
   /* Initialize the two seeds                        */
   /***************************************************/
   p = (unsigned char *) sd;
   q = (unsigned char *) sd + 64;
   while (p < q) *p++ = '\0';
   p = (unsigned char *) sd2;
   q = (unsigned char *) sd2 + 64;
   while (p < q) *p++ = '\0';
   /***************************************************/
   /* Initialize the seed to one                      */
   /***************************************************/
   p = (unsigned char *) sd;
   *p = 1;
   emm = 65539;          /* set multiplier */
   cseed = 1;            /* initial seed is 1 */
   shwsd(cseed, sd);     /* display the two seeds */
   /***************************************************/
   /* generate kount times                            */
   /***************************************************/
   i = kount;
   while (i--)
      {
      cseed *= emm;
      rnd(sd, sd2);
      } /* for each generation */
   shwsd(cseed, sd);        /* print the seeds */
   return(0);               /* normal end of job */
   } /* main */
