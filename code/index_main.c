#include "math.h"

inline double
Factorial(unsigned int X)
{
 double Result = (double)X;
 while(X > 1)
 {
  Result *= --X;
 }
 
 return Result;
}

inline double
TaylorSineCoefficient(unsigned int Power)
{
 double Sign = (((Power - 1)/2) % 2) ? -1.0 : 1.0;
 double Result = (Sign / Factorial(Power));

 return Result;
}

inline double
TaylorSineHorner(unsigned int MaxPower, double X)
{
 double Result = 0;

 double X2 = X*X;
 for(unsigned int InvPower = 1; InvPower <= MaxPower; InvPower += 2)
 {
  unsigned int Power = MaxPower - (InvPower - 1);
  Result = Result*X2 + TaylorSineCoefficient(Power);
 }
 Result *= X;
 
 return Result;
}

__attribute__((export_name("sine"))) inline double
Sine(double X)
{
	return TaylorSineHorner(21, X);
}
