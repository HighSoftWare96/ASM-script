.section .data
	done:
		.ascii "Done!\n"

	done_size:
		.long .-done

	out_counter2:
		.long 0

    	out_pointer:
		.long 0

	char_temp:
		.byte 0
	
	out_buffer2:
		.long 0

.section .bss

	.lcomm descriptor_out, 8


.section .text
	.global write_output

.type write_output, @function

write_output:           #funzione che scrive su file

    movl %ecx, out_buffer2

    #sezione di APERTURA DEL FILE OUTPUT

    movl $5, %eax
     				                    # Nome del file già in ebx
    movl $2, %ecx 						# wr mode
    int $0x80

    movl %eax, descriptor_out 			# Salvo il descrittore del file aperto
    movl $0, out_counter2

    movl out_buffer2, %ecx				# Salvo l'indirizzo...
    movl %ecx, out_pointer				# ... nel puntatore

    movl out_counter2, %edx 				# Recupero il carattere attuale per il controllo
    movb (%ecx, %edx), %al
    movb %al, char_temp			# Punta all'inizio della stringa


writing_attend:		 #loop di lettura

    #sezione di SCRITTURA DELLA STRINGA LETTA - su file -
    movl $4, %eax						# System call 4.
    movl descriptor_out, %ebx			# Descrittore
    movl out_pointer, %ecx				# Scrivo il puntatore
    movl $1, %edx						# Stampo un solo carattere
    int $0x80


    addl $1, out_counter2				# Incremento il contatore
    movl out_buffer2, %ecx				# Risalvo il prossimo carattere
    movl out_counter2, %edx
    movb (%ecx, %edx), %al
    movb %al, char_temp					# Salvo il carattere

    addl %ecx, %edx 					# Incremento il puntatore
    movl %edx, out_pointer

    cmpb $0, (char_temp) 					# Carattere NULL, fine buffer

    jne writing_attend


    # Stampa a video un messaggio di stampa avvenuta
    movl $4, %eax
    movl $1, %ebx
    leal done, %ecx
    movl done_size, %edx
    int $0x80

ret
