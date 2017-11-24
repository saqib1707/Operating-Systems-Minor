import numpy as np
from math import pi,exp,sqrt,fabs
from scipy.integrate import quad
import matplotlib.pyplot as plt

n_levels =  6
max_iter = 2000
# gaussian parameters
variance = 4
mean = 0

# m[] is an array containing decision boundaries
m = np.zeros(n_levels+1)

# initialization of extreme boundaries i.e the max and min value that my signal can take
m[0] = -10
m[n_levels] = 10

# v[] is an array which will hold the reconstruction levels/values
v = np.zeros(n_levels)

def integrand_centroid(x, flag):
	if(flag == 0):
		# numerator of centroid function
		return x*calc_gaussian(x)
	else:
		# denominator of centroid function
		return calc_gaussian(x)

def integrand_error(x, a):
	# computes the mean square deviation error
	return pow((x-a),2)*calc_gaussian(x)

def calc_gaussian(x):
	# calculates y = g(x) where g(.) is gaussian pdf with above defined parameters
	return (1/sqrt(2*pi*variance))*exp(-1*pow((x-mean),2)/(2*variance))

def init_m():
	# initialize the decision boundaries initially uniformly
	for i in range(1, n_levels):
		m[i] = m[0] + i*(m[n_levels]-m[0])/n_levels

def calc_m():
	# calcultes the decision boundaries based on the reconstruction values
	for i in range(1, n_levels):
		m[i] = (v[i-1] + v[i])/2

def calc_v():
	# computes reconstruction values based on the centroid formula derived in class
	for i in range(n_levels):
		ans1, err1 = quad(integrand_centroid, m[i], m[i+1], args=(0))
		ans2, err2 = quad(integrand_centroid, m[i], m[i+1], args=(1))
		v[i] = ans1/ans2

def calc_error():
	# computes the mean deviation error for all the intervals/ for all levels
	error=0
	for i in range(0, n_levels):
		ans1, err1 = quad(integrand_error, m[i], m[i+1], args=(v[i]))
		error+=ans1
	return error

if __name__ == "__main__":
	thresh = 1e-8
	iteration = 0
	err_list = []                # for plotting the deviation error
	init_m()

	error=1e4
	prev_error = 0

	while((fabs(error-prev_error) > thresh) and (iteration < max_iter)):
		prev_error = error
		calc_v()
		calc_m()
		error = calc_error()                 # calculate the total deviation error
		err_list.append(error)
		iteration+=1
	#print("No of iteration:", iteration)
	print "Deviation Error:", error
	print "Decision Boundaries:", m
	print "Reconstruction Values:", v
	plt.plot(err_list)
	plt.xlabel('Iteration')
	plt.ylabel('Deviation Error')
	plt.show()