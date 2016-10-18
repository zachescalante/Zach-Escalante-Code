#Modeloff 2014 - Round 1 (Snakes and Ladders)
#The function 'digits' is declared beneath the questions and answers

#Question 1
#If you played the game by yourself, what is the average number of rolls required to finish?
Rolls <- function(n){           #Our input to the rolls function is the square that we want to start on
  count_1 = 0                   #This will come in handy in the future
  while (n < 34) {
    n = sample(1:6, 1) + n       #Random integer generator
    n = digits(n)                #Call the digits function
    count_1 = count_1 + 1        #Increment our counter (number of rolls)
  }
  return(count_1)                #Return the number of rolls necessary to break the while loop ('win')
}

#Number of simulations
n = 5000 
sum = 0
for(i in 1:n){
  sum = sum + Rolls(0)          
}
print(sum/n)

#Question 2
#In a two person game, what is the average number of combined rolls 
#by both players required for the game to finish?

combinedRolls <- function(n, m){  #This function takes the starting key for both Player 1 and 2 as inputs
  count_1 = 0
  count_2 = 0
  while (n < 34 && m < 34) {
    n = sample(1:6, 1) + n
    m = sample(1:6, 1) + m
    n = digits(n)                #Set n & m equal to the digits function with n and m as their respective inputs
    m = digits(m)
    count_2 = count_2 + 1
    count_1 = count_1 + 1
  }
  return(count_1 + count_2)     #Return the count_1 and count_2 iterators
}

#Number of simulations
n = 5000
sum = 0
for(i in 1:n){
  sum = sum + combinedRolls(0, 0)
}
print(sum/n)


#Question 3
#In a two person game, what is the probability that Player 1 wins? 
winner <- function(n, m){
  count_1 = 0
  count_2 = 0
  while (n < 34 && m < 34) {
    n = sample(1:6, 1) + n
    if (n>=34){return(1)}     #This time, if n is >= 34 first, return 1
    m = sample(1:6, 1) + m
    if (m>=34){return(0)}     #if m wins (>=34 first), return 0
    n = digits(n)
    m = digits(m)
  }
}

winner(0, 0)

#Number of simulations
n = 10000
sum = 0
for(i in 1:n){
  sum = sum + winner(0, 0)
}
print(sum/n)

#Question 4
#You decide you want the game to have approximately fair odds, 
#and you do this by changing the square that Player 2 starts on. 
#From the options below, which square for Player 2’s start position 
#gives the closest to equal odds for both players?

n = 10000
sum = 0
for(i in 1:n){
  sum = sum + winner(0, 6)   #This is where using the starting square is very useful
}                            #All we have to do is adjust the m-input to the given values
print(sum/n)                 #and run our simulation to find which one gives a 50% P(success)


#Question 5
#In a different attempt to change the odds of the game, instead of 
#starting Player 2 on a different square, you decide to give Player 2 
#immunity to the first snake that they land on. What is the approximate 
#probability that Player 1 wins now?

#Answer
#Before I adjust the main function, I write the 'digitsTwo' function. 
#See the functions section for details on what digitsTwo does

winnerTwo <- function(n, m){
  count = 0                               #I first declare a counter variable
  ladders = c(7, 10, 21, 24, 33)          #I also declare a vector of snakes         
  while (n < 34 && m < 34) {             
    n = sample(1:6, 1) + n
    if (n>=34){return(1)}
    m = sample(1:6, 1) + m
    if(m %in% ladders){count = count + 1} #Every time that player B lands on a snake, increment count by 1
    if (m>=34){return(0)}
    n = digits(n)
    if (count == 1){m = digitsTwo(m)}     #when count == 1 (this will only happen once. Why?), call digitsTwo
    else{m = digits(m)} 
  }
}

#Number of simulations
n = 10000
sum = 0
for(i in 1:n){
  sum = sum + winnerTwo(0, 0)
}
print(sum/n)

####################################Functions######################################
#The digits function take an integer and returns the appropriate value for Snakes and Ladders.
digits <- function(n)
{
  if(n == 1){
    return(12)
  }
  else if(n==5){
    return(16)
  }
  else if(n==11){
    return(22)
  }
  else if(n==15){
    return(23)
  }
  else if(n==20){
    return (31)
  }
  else if(n==7){
    return(4)
  }
  else if(n==10){
    return(2)
  }
  else if(n==21){
    return(13)
  }
  else if(n==24){
    return (6)
  }
  else if(n==33){
    return (19)
  }
  else{
    return(n)
  }
}

#The digitsTwo function consists of only ladders. This will come in useful for Question 5
digitsTwo <- function(n)
{
  if(n == 1){
    return(12)
  }
  else if(n==5){
    return(16)
  }
  else if(n==11){
    return(22)
  }
  else if(n==15){
    return(23)
  }
  else if(n==20){
    return (31)
  }
  else{
    return(n)
  }
}


