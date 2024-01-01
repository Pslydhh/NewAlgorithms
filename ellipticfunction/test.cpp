// test.cpp: This file contains the "main" function. Program execution will start and end here.
//

#include "pch.h"
#include <iostream>

#include<string.h>
#include<math.h>
#include<time.h>
#define MAX 100

typedef struct point {
	int point_x;
	int point_y;
}Point;
typedef struct ecc {
	struct point p[MAX];
	int len;
}ECCPoint;
typedef struct generator {
	Point p;
	int p_class;
}GENE_SET;
 
char alphabet[ ] = "abcdefghijklmnopqrstuvwxyz";
int a = -1, b = 0, p = 89;//The elliptic curve is E89(-1,0): y2=x3-x (mod 89)
ECCPoint eccPoint;
GENE_SET geneSet[MAX];
int geneLen;
char plain[] = "yes";
int m[MAX];
int cipher[MAX];
int nB;//private key
Point P1, P2, Pt, G, PB;
Point Pm;
int C[MAX];
 
//Modulo function
int mod_p(int s)
{
	int i;	//Save multiples of s/p
	int result;	//The result of modular arithmetic
	i = s / p;
	result = s - i * p;
	if (result >= 0)
	{
		return result;
	}
	else
	{
		return result + p;
	}
}

//Determine whether the square root is an integer
int int_sqrt(int s)
{
	int temp;
	temp = (int)sqrt(s);//Convert to integer
	if (temp*temp == s)
	{
		return temp;
	}
	else {
		return -1;
	}
}
//Print point set
void print()
{
	int i;
	int len = eccPoint.len;
	printf("\nThere are %d points on this elliptic curve (including infinity points)\n", len + 1);
	for (i = 0; i < len; i++)
	{
		if (i % 8 == 0)
		{
			printf("\n");
		}
		printf("(%2d,%2d)\t", eccPoint.p[i].point_x, eccPoint.p[i].point_y);
	}
	printf("\n");
}
 

void get_all_points()
{
	int i = 0;
	int j = 0;
	int s, y = 0;
	int n = 0, q = 0;
	int modsqrt = 0;
	int flag = 0;
	if (4 * a * a * a + 27 * b * b != 0)
	{
		for (i = 0; i <= p - 1; i++)
		{
			flag = 0;
			n = 1;
			y = 0;
			s = i * i * i + a * i + b;
			while (s < 0)
			{
				s += p;
			}
			s = mod_p(s);
			modsqrt = int_sqrt(s);
			if (modsqrt != -1)
			{
				flag = 1;
				y = modsqrt;
			}
			else 
			{
				while (n <= p - 1)
				{
					q = s + n * p;
					modsqrt = int_sqrt(q);
					if (modsqrt != -1)
					{
						y = modsqrt;
						flag = 1;
						break;
					}
					flag = 0;
					n++;
				}
			}
			if (flag == 1)
			{
				eccPoint.p[j].point_x = i;
				eccPoint.p[j].point_y = y;
				j++;
				if (y != 0)
				{
					eccPoint.p[j].point_x = i;
					eccPoint.p[j].point_y = (p - y) % p;  //Note: The negative element of P(x,y) is (x,p-y)
					j++;
				}
			}
		}
		eccPoint.len = j;//Number of point sets
		print(); //Print point set
	}
}
 


int main()
{
	get_all_points();
}
 