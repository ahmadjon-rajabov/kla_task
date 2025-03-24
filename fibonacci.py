import sys
import time

# Function for calculating the n-th Fibonacci number
def fibonacci(n):
    if n <= 0:
        return 0  # if n <= 0, return 0
    elif n == 1:
        return 1  # if n = 1, return 1
    else:
        a, b = 0, 1  # initialise initial values
        for _ in range(2, n + 1):  # calculating Fibonacci numbers iteratively
            a, b = b, a + b
        return b  # n-th number

# Check number of command line arguments
if len(sys.argv) == 1:
    # if there are no arguments, outputs all Fibonacci numbers with a delay 0.5
    n = 0
    while True:
        print(fibonacci(n))  
        n += 1
        time.sleep(0.5)  # delay 0.5
elif len(sys.argv) == 2:
    # If one argument is passed, calculate and output the n-th number
    try:
        n = int(sys.argv[1])  # convert arg to integer
        print(fibonacci(n))   
    except ValueError:
        print("Please specify an integer.") 
else:
    # If there is more than one argument, output the instruction
    print("Usage: python fibonacci.py [n]")