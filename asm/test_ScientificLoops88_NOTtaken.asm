#registers 1 and 2 are the branch conditional registers
#if at any point $4 is not 0, then some branching has failed
#register $3 makes sure some instructions are only run once (it should never be above 1)
#register $5 marks when the program is finished, when $5 is set to 128, we are done executing

    #initializing values
    addi $3, $0, 0
    addi $4, $0, 0
    addi $5, $0, 0 
    addi $1, $0, 0
    addi $2, $0, 20
    bne $1, $2, loop1 #(+1 taken)(+1 switch) #i5
    j error
  
loop1:  addi $1, $1, 1 #increment $1
        beq $1, $2, sec2 #(+19 not_taken) (+1 taken) (+2 switch)
        j loop1
sec2:   addi $3, $3, 1 #should only run once #i10
        
        addi $1, $0, 0
        beq $1, $2 error #(+1 not_taken)
        addi $2, $0, 20
loop2:  addi $1, $1, 1 #increment $1 #i15
        beq $1, $2, final #(+ 19 not_taken)(+1 taken)(+1 switch)
        j loop2
        
final:  addi $1, $0, 5
        bne $1, $2, end #(+1 taken)
        j error
        
error: addi $4, $0, 1  #only jump here if there was a branching error
    
end: addi $5, $0, 128
#4 taken
#39 not_taken
#4 switches  
        
    
       