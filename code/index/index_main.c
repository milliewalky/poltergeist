#define function static
#define global static
#define read_only __attribute__((section(".rodata")))

#define WASM_Export(name) __attribute__((export_name(#name))) name

function double
Factorial(unsigned int v)
{
 double result = (double)v;
 while(v > 1)
 {
  v -= 1;
  result *= v;
 }
 return result;
}

function double
TaylorSineCoefficient(unsigned int power)
{
 double sign = (((power-1)/2) % 2) ? -1.0 : 1.0;
 double result = (sign/Factorial(power));
 return result;
}

#include "wasm_simd128.h"

function double
TaylorSineHorner(unsigned int power_max, double v)
{
 double result = 0;

 // taylor polynomial + horner rule applied; vectorised
 v128_t accumulator_f64x2 = wasm_f64x2_splat(0.0);
 {
  double squared = v*v;
  for (unsigned int power_inv = 1; power_inv <= power_max; power_inv += 2)
  {
   unsigned int power = power_max-(power_inv-1);

   v128_t squared_f64x2 = wasm_f64x2_splat(squared);
   v128_t coefficient_f64x2 = wasm_f64x2_splat(TaylorSineCoefficient(power));

   accumulator_f64x2 = wasm_f64x2_relaxed_madd(accumulator_f64x2, squared_f64x2, coefficient_f64x2);
  }
 }

 // extract data from lane
 {
  result = wasm_f64x2_extract_lane(accumulator_f64x2, 0);
  result *= v;
 }

 return result;
}

global read_only unsigned int degree = 21;

double
WASM_Export(Sine)(double v)
{
 return TaylorSineHorner(degree, v);
}
