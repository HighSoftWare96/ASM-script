.section .data

	counter:
		.long 0

	out_counter:
		.long 0

	buff_size:
		.long 900						# 100 * N(caratteri)


	# Variabili di progetto
	INIT:
		.long 0

	RESET:
		.long 0
	RPM1:
		.long 0
	RPM2:
		.long 0
	RPM3:
		.long 0
	RPM4:
		.long 0
	RPM_S:
		.long 0
	MOD:
		.long 0
	NUMB:
		.long 0
	ALM:
		.long 0

	temp_counter:
		.long 0

	MOD_PREC_M:
		.long 0

	# Variabili di posizione

  		comma:								# Suddivide i valori letti letti: INIT , RESET , RPM
  			.byte ','
  		newline:								# Quando trova questo valore ricomincia la lettura: INIT , RESET , RPM
  			.byte '\n'


# Variabili file di lettura
.section .bss

	.lcomm buffer, 900
	.lcomm out_buffer, 900

	.lcomm descriptor_in, 8
	.lcomm file_out, 8


.section .text
	.global _start

_start:
	popl %eax
	popl %eax
	popl %ebx				# Salvo in ebx il nome del file di input
	popl file_out			# Salvo il nome del file di output

	# APRO IL FILE IN SOLA LETTURA
	movl $5, %eax
												# Ho in ebx il nome del file
	movl $0, %ecx								# Modalità in sola lettura
	int $0x80

	movl %eax, descriptor_in					# Prelevo il descrittore e lo salvo

#--------------------------------------------
	# LETTURA DEL FILE							read (unsigned int fd, char * buf, size_t count)
	movl $3, %eax								# System call 3
	movl descriptor_in, %ebx					# ebx = descrittore file
	leal buffer, %ecx							# Grandezza dei byte
	movl buff_size, %edx
	int $0x80
#--------------------------------------------

	read:


		# Ottengo il primo parametro: INIT		# sys_write(unsigned int fd, const char * buf, size_t count)

		xorl %eax, %eax

		# Converto valore - ATOI -
		movl counter, %edx
		movl $buffer, %ecx
		movb (%edx, %ecx), %al

		call atoi				# Converto il carattere contenuto in al in un intero

		movl %eax, INIT							# Salvo il carattere convertito
		addl $2, %edx #counter

		#-------------------------------------------
		# Ottengo il secondo parametro: RESET

		# Converto valore - ATOI -
		movl $buffer, %ecx
		movb (%edx, %ecx), %al

		call atoi

		movl %eax, RESET
		addl $2, %edx

		#-------------------------------------------
		# Ottengo il terzo parametro: RPM1

		# Converto valore - ATOI -
		movl $buffer, %ecx
		movb (%edx, %ecx), %al

		call atoi

		movl %eax, RPM1
		addl $1, %edx

		#-------------------------------------------
		# Ottengo il terzo parametro: RPM2

		# Converto valore - ATOI -
		movl $buffer, %ecx
		movb (%edx, %ecx), %al

		call atoi

		movl %eax, RPM2
		addl $1, %edx

		#-------------------------------------------
		# Ottengo il terzo parametro: RPM3

		# Converto valore - ATOI -
		movl $buffer, %ecx
		movb (%edx, %ecx), %al

		call atoi

		movl %eax, RPM3
		addl $1, %edx

		#-------------------------------------------
		# Ottengo il terzo parametro: RPM4

		# Converto valore - ATOI -
		movl $buffer, %ecx
		movb (%edx, %ecx), %al

		call atoi

		movl %eax, RPM4
		addl $1, %edx

		#-------------------------------------------

		#faccio uno PSEUDO-ATOI per salvarmi RPM (al momento diviso in 4 interi)
		movl RPM1, %eax
		movl $1000, %ebx
		mull %ebx					# RPM1 * 1000
								# Il risultato del prodotto viene salvato in eax
		addl %eax, RPM_S

		movl RPM2, %eax
		movl $100, %ebx
		mull %ebx					# RPM2 * 100

		addl %eax, RPM_S

		movl RPM3, %eax
		movl $10, %ebx
		mull %ebx					# RPM3 * 10

		addl %eax, RPM_S

		movl RPM4, %eax
		movl $1, %ebx
		mull %ebx					# RPM4 * 1

		addl %eax, RPM_S 		# In RPM_S ho il mio valore reale


	#-------------------------------------VALUTAZIONE----------------------------------------#
	# Effettuo chiamata alla scelta del valore di output corrispondente agli input:
	# Preparo i file per la funzione SCELTA

		 movl INIT, %eax						# eax = INIT
		 movl RESET, %ebx						# ebx = RESET
		 movl RPM_S, %ecx						# ecx = RPM
		 movl MOD_PREC_M, %edx

		 call scelta


		 movl %eax, MOD
		 movl %eax, MOD_PREC_M
		 movl %ebx, NUMB
		 movl %ecx, ALM

	#-----------------------------------------------------------------------------------------#

	#-------------------------------------SCRITTURA SU OUTBUFFER------------------------------#
		movl out_counter, %edx			#

		#SALVATAGGIO ALM -----------------------

		movl $out_buffer, %ecx
		movl ALM, %eax
		addb $48, %al
		movb %al, (%edx, %ecx)		# Salva ALM in out_buffer al posto indicato dal counter
		addl $1, %edx				# Incrementa il counter

		#SALVATAGGIO VIRGOLA -------------------

		movl $out_buffer, %ecx
		movb $44, %al #virgola
		movb %al, (%edx, %ecx)
		addl $1, %edx

		#SALVATAGGIO MOD ------------------------
		cmp $1, MOD
		jle add_zero

			not_with_zero:
					# Ci salviamo EDX attuale
					movl %edx, temp_counter

					movl MOD, %eax
					movl $10, %ebx
					xorl %edx, %edx
					divl %ebx			# Divido per 10 prendo la prima

					movl $out_buffer, %ecx
					addb $48, %al

					movl temp_counter, %edx
					movb %al, (%edx, %ecx)
					addl $1, %edx
					movl %edx, temp_counter 	# Risalvo edx


					movl MOD, %eax
					movl $10, %ebx
					xorl %edx, %edx
					divl %ebx			# Divido per 10 prendo la seconda

					movl $out_buffer, %ecx
					addb $48, %dl
					movb %dl, %al

					movl temp_counter, %edx
					movb %al, (%edx, %ecx)
					addl $1, %edx
					jmp virgola

			add_zero:
			#SALVO LO ZERO
					movl $out_buffer, %ecx
					movb $48, %al #0
					movb %al, (%edx, %ecx)
					addl $1, %edx
			#SALVO MOD
					movl $out_buffer, %ecx
					movl MOD, %eax
					addb $48, %al
					movb %al, (%edx, %ecx)
					addl $1, %edx


		#SALVATAGGIO VIRGOLA -------------------
	virgola:

		movl $out_buffer, %ecx
		movb $44, %al #virgola
		movb %al, (%edx, %ecx)
		addl $1, %edx

		#SALVATAGGIO NUMB -----------------------
		cmp $9, NUMB
		jle add_zero_numb

			not_with_zero_numb:
					#ci salviamo EDX attuale
					movl %edx, temp_counter

					movl NUMB, %eax
					movl $10, %ebx
					xorl %edx, %edx
					divl %ebx			# Divido per 10 prendo la prima

					movl $out_buffer, %ecx
					addb $48, %al

					movl temp_counter, %edx
					movb %al, (%edx, %ecx)
					addl $1, %edx
					movl %edx, temp_counter 		# Risalvo edx


					movl NUMB, %eax
					movl $10, %ebx
					xorl %edx, %edx
					divl %ebx			# Divido per 10 prendo la seconda

					movl $out_buffer, %ecx
					addb $48, %dl
					movb %dl, %al

					movl temp_counter, %edx
					movb %al, (%edx, %ecx)
					addl $1, %edx
					jmp a_capo

			add_zero_numb:
			#SALVO LO ZERO
					movl $out_buffer, %ecx
					movb $48, %al #0
					movb %al, (%edx, %ecx)
					addl $1, %edx
			#SALVO MOD
					movl $out_buffer, %ecx
					movl NUMB, %eax
					addb $48, %al
					movb %al, (%edx, %ecx)
					addl $1, %edx



		#SALVATAGGIO CAPORIGA -------------------
	a_capo:
		movl $out_buffer, %ecx
		movb $10, %al #caporiga
		movb %al, (%edx, %ecx)
		addl $1, %edx

	#-----------------------------------------------------------------------------------------#

			#azzero rpm_s per non sommare valori precedenti
			movl $0, RPM_S

			#svuoto eax
			xorl %eax, %eax
			#sposto counter alla fine della riga
			addl $9, counter

			#sposto out_counter per la prossima riga
			addl $8, out_counter

			#controllo il prossimo carattere
			movl counter, %edx
			movl $buffer, %ecx
			movb (%edx, %ecx), %al

		cmpb $0, %al
	jne read 					# Continua la lettura se e' uguale

	# Quando il carattere in al corrisponde a NULL (0) la stringa e' finita e
	# si passa alla sua scrittura su file



#-----------------------------------------------------------------------------------------#

	xorl %edx, %edx

	#STAMPA SU FILE: libero i registri, sposto file_out e out_buffer su registro e
	#chiamo la funzione

	movl file_out, %ebx
	movl $out_buffer, %ecx

	call write_output

#------------------------------------------
	return_0:										# sys_exit(int status)
		movl $1, %eax							# System call EXIT
		movl $0, %ebx
		int $0x80
