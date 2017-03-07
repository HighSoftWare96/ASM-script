 ####################################################################
####################### atoi.s #####################################
####################################################################

.section .data
	
car:
  .long 0  # La variabile car e' dichiarata di tipo long

.section .text
.global atoi

.type atoi, @function # Dichiarazione della funzione atoi
                      # La funzione converte una stringa di caratteri
		              # proveniente da tastiera e delimitata da '\n'
		              # in un numero che viene restituito nel registro eax
atoi: 
	pushl %ebx          		# Salvo il valore corrente di ebx sullo stack
	pushl %ecx          		# Salvo il valore corrente di ecx sullo stack
	pushl %edx          		# Salvo il valore corrente di edx sullo stack

  	  
inizio:  

 	  
    movl %eax, car

  	leal  car, %ecx     		# Carica in ecx l'indirizzo di car in cui verra' salvato
                      			# il carattere letto

	
  	subl  $48, car      		# Converte il codice ASCII della cifra nel numero corrisp. 
    xorl %eax, %eax #per sicurezza
  	movl  car, %eax 


fine:

  	popl %edx
  	popl %ecx 
    popl %ebx  
    
  	ret             # Fine della funzione atoi
    	            # L'esecuzione riprende dall'istruzione sucessiva
        	        # alla call che ha invocato atoi
