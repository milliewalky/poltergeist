#include "math.h"

__attribute__((export_name("sine"))) double
sine(double theta)
{
 return sin(theta);
}
