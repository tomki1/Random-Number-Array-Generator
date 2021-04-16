TITLE Random Number Array Generator    (KimberlyTomProgram5.asm)

; Author: Kimberly Tom
; Last Modified: 11/19/18
; OSU email address: tomki@oregonstate.edu
; Course number/section: 271/400
; Project Number: 5                Due Date: 11/18/18
; Description: This program generates random integers, displays them in an array, sorts them, provides the median, then displays the array in ascending order.

INCLUDE Irvine32.inc

MIN = 10			;minimum integer amount
MAX = 200			;maximum integer amount
LO = 100			;lowest possible number in random range
HI = 999			;highest possible number in random range

.data

title_1		BYTE	"Random Number Array Generator		by Kimberly Tom", 0
intro_1		BYTE	"Provide the amount of numbers to be generated and the program will", 0dh, 0ah 
			BYTE	 "randomly generate the numbers in the range of [100...999].", 0dh,0ah
			BYTE	"Then the program will display the unsorted list, sort the list,", 0dh, 0ah 
			BYTE	"calculate the median value, then display the list in descending order.", 0
prompt_1	BYTE	"Enter the amount of numbers to be generated.  Amount must be in the range of [10...200] ", 0
request		DWORD	?																									;user's number input 
invalidTerm	BYTE	"The input you entered is not in the range [10...200]. Try again.", 0
array		DWORD	200 DUP(?)																							;array of 200 DWORD
titleUnsort	BYTE	"Unsorted Array of random numbers: ", 0
titleSort	BYTE	"Sorted Array of random numbers: ", 0 
printMedian	BYTE	"Median: ", 0
.code

main PROC

	call	randomize

	push	OFFSET title_1
	push	OFFSET intro_1
	call	introduction

	push	OFFSET invalidTerm
	push	OFFSET prompt_1
	push	OFFSET request
	call	getData

	push	request
	push	OFFSET array
	call	fillArray

	push	OFFSET array
	push	request
	push	OFFSET titleUnsort	
	call	displayList

	push	OFFSET array
	push	request
	call	sortList

	push	OFFSET printMedian
	push	OFFSET array
	push	request
	call	displayMedian

	push	OFFSET array
	push	request
	push	OFFSET titleSort
	call	displayList

	exit	; exit to operating system
main ENDP

;*******************************************************
;Procedure to show the title of the program and the instructions
;receives:  title_1 (passed by reference), intro_1(passed by reference)
;returns: title and intro strings
;preconditions: none
;registers changed: ebp, edx
;*******************************************************
introduction PROC

	push	ebp
	mov		ebp, esp

	mov		edx, [ebp + 12]				;move title_1 to edx
	call	WriteString
	call	Crlf
	call	Crlf

	;instructions
	mov		edx, [ebp + 8]				;move intro_1 to edx 
	call	WriteString
	call	CrLf
	call	CrLf

	pop		ebp
	ret		8
introduction ENDP

;*******************************************************
;Procedure to obtain the user's desired array count
;receives:  request (passed by reference), prompt_1 (passed by reference), invalidTerm (passed by reference)
;returns: user input in global request
;preconditions: user's input must be in the range [10...200]
;registers changed: eax, ebx, edx, ebp
;*******************************************************
getData PROC
;with help from CS271 demo5.asm
	push	ebp
	mov		ebp, esp
	mov		ebx, [ebp + 8]			;request address is now in ebx

obtainNumber:

	mov		edx, [ebp + 12]			;prompt_1 address moved to edx
	call	WriteString
	call	ReadInt
	cmp		eax, MAX
	jg		errorMessage
	cmp		eax, MIN
	jl		errorMessage
	jmp		numberOK
	
;show error message and jump back to obtainNumber if user's number is out of range
errorMessage:
	mov		edx, [ebp + 16]			;address of invalidTerm moved to edx
	call	WriteString
	call	Crlf
	jmp		obtainNumber

numberOK:	
	mov		[ebx], eax				;the number the user wanted is now the contents of ebx which is request
	pop		ebp
	ret		12	
getData ENDP

;*******************************************************
;Procedure to fill the array with psuedo-random numbers
;receives:  array (passed by reference), request (passed by value)
;returns: none
;preconditions: none
;registers changed: eax, ecx, edi, ebp
;*******************************************************
fillArray PROC
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp + 8]			;move starting address of array to ESI
	mov		ecx, [ebp + 12]			;move request contents to ecx for the count

;generate n tsuedo-random integers in range of [100...999] and fill array
; code help from CS271 lecture 20
L1:	mov		eax, HI
	sub		eax, LO	
	inc		eax
	call	randomRange
	add		eax, LO
	mov		[edi], eax
	add		edi, 4
	loop	L1

	pop		ebp
	ret		8
fillArray ENDP

;*******************************************************
;Procedure sorts the array
;receives:  array (passed by reference), request (passed by value)
;returns: none
;preconditions: none
;registers changed: eax, ecx, ebp, esi
;*******************************************************
sortList PROC
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp + 8]			;move request into ecx for count
	dec		ecx

;bubble sort with help from Assembly language for x86 Processors by Kip R. Irvine, 9.5.1
loop1:
	push	ecx						;save the count for outer loop
	mov		esi, [ebp + 12]			;move starting address of array to esi
loop2:
	mov		eax, [esi]
	cmp		[esi + 4], eax			;compare the current term with the next term
	jl		loop3					;if next term is less, keep going without exchanging values
	xchg	eax, [esi + 4]			;exchange pair if the next term is greater than current term
	mov		[esi], eax
loop3:
	add		esi, 4
	loop	loop2
	pop		ecx						;get outer loop count back into ecx
	loop	loop1

	pop ebp
	ret	8
sortList ENDP

;*******************************************************
;Procedure calculates and displays the median of the array
;receives:  array (passed by reference), request (passed by value), printMedian (passed by reference)
;returns: median
;preconditions: none
;registers changed: eax, ebx, ecx, edx, esi, ebp
;*******************************************************
displayMedian PROC
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp + 8]			;move array count to ecx
	mov		esi, [ebp + 12]			;move starting address of array to esi
	mov		edx, 0

	mov		eax, [ebp + 8]			;move array count to eax
	mov		ebx, 2
	div		ebx
	cmp		edx, 0				
	jg		arrayOdd				;if remainder greater than zero, array has odd number of elements
	je		arrayEven				;if remainder is zero, array has even number of elements

arrayOdd:
	mov		ebx, 4
	mul		ebx						;multiply eax by 4 to get median offset
	mov		ebx, [esi + eax]		;store median in ebx
	mov		eax, ebx
	call	CrLf
	call	CrLf
	mov		edx, [ebp + 16]			;address of printMedian is in edx
	call	WriteString
	call	WriteDec
	jmp		endMedian

arrayEven:
	mov		ebx, 4
	mul		ebx						;eax now has higher median offset
	mov		ebx, [esi + eax]		;store value of higher median in ebx
	sub		eax, 4	
	mov		eax, [esi + eax]		;eax now has lower median offset
	add		eax, ebx
	mov		edx, 0					
	mov		ebx, 2
	div		ebx						;eax now has the median
	cmp		edx, 0					
	jg		roundUp					;if there is a remainder (which is .5), round up
	call	CrLf
	call	CrLf
	mov		edx, [ebp + 16]			;address of printMedian is in edx
	call	WriteString
	call	WriteDec
	jmp		endMedian

roundUp:
	add		eax, 1					;eax is now the rounded up value
	call	CrLf
	call	CrLf
	mov		edx, [ebp + 16]			;address of printMedian is in edx
	call	WriteString
	call	WriteDec
	jmp		endMedian
	
endMedian:
	call	CrLf
	call	CrLf
	pop		ebp
	ret		12
displayMedian ENDP

;*******************************************************
;Procedure displays the array
;receives:  array (passed by reference), request (passed by value), title(passed by reference)
;returns: array list
;preconditions: none
;registers changed: eax, ebx, ecx, edx, edi, esi, ebp, al
;*******************************************************
displayList PROC
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp + 16]			;esi gets starting address of array
	mov		ecx,[ebp + 12]			;move request to edx
	mov		edx, [ebp + 8]			;title of array
	mov		ebx, 0
	call	CrLf
	call	WriteString
	call	CrLf

print:
	mov		eax, [esi]
	call	WriteDec
	mov		al, 9
	call	WriteChar
	add		esi, 4
	inc		ebx
	cmp		ebx, 10
	jge		newRow
continue:
	loop	print
	jmp		done

newRow:
	call	CrLf
	mov		ebx, 0
	jmp		continue

done:
	pop		ebp
	ret		12
displayList ENDP


END main
