;  #################################################################################################
;  ##  ����������� ��������� "�������" ��� ���������� "�����-86��/60-Nova"                        ##
;  #################################################################################################
;
;  Author:  Vitaliy Poedinok aka Vital72
;  License: MIT
;  www:     http://www.86rk.ru/
;  e-mail:  vital72@86rk.ru
;  Version: 1.0
;  =================================================================================================

VERSION			EQU	"1.0"

CPU_CLOCK		EQU	3000	;  �������� ������� CPU � ����������

MONITOR_BASE		EQU	0F800h	;  ��������� ����� ��������
MONITOR_EXTENSION	EQU	0F000h	;  ��������� ����� ���������� ��������
MONITOR_DATA		EQU	0E600h	;  ������ ������� ������� ����� ��������
MONITOR_DATA_SIZE	EQU	000D0h	;  ������ ������� ������� ����� ��������
MONITOR_WARM_START	EQU	0F86Ch	;  ������� �����/�������

;  ������� ������ ��������� ���������
ADDR_TIMER		EQU	0F100h
ADDR_RTC		EQU	0F200h
ADDR_KBD		EQU	0F400h
ADDR_PORT		EQU	0F500h
ADDR_CRT		EQU	0F600h
ADDR_DMA		EQU	0F700h
ADDR_FONT_RAM		EQU	0F800h

ADDR_KBD_PA		EQU	ADDR_KBD + 0
ADDR_KBD_PB		EQU	ADDR_KBD + 1
ADDR_KBD_PC		EQU	ADDR_KBD + 2
ADDR_KBD_CTRL		EQU	ADDR_KBD + 3

ADDR_PORT_PA		EQU	ADDR_PORT + 0
ADDR_PORT_PB		EQU	ADDR_PORT + 1
ADDR_PORT_PC		EQU	ADDR_PORT + 2
ADDR_PORT_CTRL		EQU	ADDR_PORT + 3

ADDR_CRT_PARAM		EQU	ADDR_CRT
ADDR_CRT_CTRL		EQU	ADDR_CRT + 1

ADDR_TIMER_CTRL		EQU	ADDR_TIMER + 3

;  ����� ����������� ������ ����������
KBD_RUS_FLAG		EQU	80h
KBD_CTRL_FLAG		EQU	40h
KBD_SHIFT_FLAG		EQU	20h

;  ��������� �������� ��� ��������� ������� ������
KBD_ANTIBOUNCE		EQU	8	;  �����������
KBD_DELAY_SECOND	EQU	90	;  �������� ����������� ��� ������� �������
KBD_DELAY_REGULAR	EQU	24	;  �������� ����������� ��� ��������� ��������

;  ������ ������� ����� ������ � ��������
SCR_VIDEO_SIZE_X	EQU	64	;  �� X
SCR_VIDEO_SIZE_Y	EQU	25	;  �� Y
;  ������ ������ ������, ���������� ������������ ����, � ��������
SCR_SIZE_X		EQU	78	;  �� X
SCR_SIZE_Y		EQU	30	;  �� Y
SCR_ARRAY		EQU	SCR_SIZE_X * SCR_SIZE_Y
; ������ ������ �������� ���� ������� ����� ������, � ��������
SCR_PAD_X		EQU	8	;  �� �����������
SCR_PAD_Y		EQU	3	;  �� ���������
;  ������ �������� ������� � ������� ��� �����
SCREEN			EQU	MONITOR_DATA + MONITOR_DATA_SIZE
SCREEN_VIDEO		EQU	SCREEN + SCR_SIZE_X * SCR_PAD_Y + SCR_PAD_X

;  ���� ��������� 8275 ��� ������ �������� �����������
ATTR_COLOR_BLACK	EQU	8Dh
ATTR_COLOR_RED		EQU	8Ch
ATTR_COLOR_GREEN	EQU	85h
ATTR_COLOR_YELLOW	EQU	84h
ATTR_COLOR_BLUE		EQU	89h
ATTR_COLOR_MAGENTA	EQU	88h
ATTR_COLOR_CYAN		EQU	81h
ATTR_COLOR_WHITE	EQU	80h

;  ���� ��������� 8275 ��� �������������, �������� � ����������� �����������
ATTR_UNDERLINE		EQU	0A0h
ATTR_BLINKING		EQU	82h
ATTR_REVERSE		EQU	90h
ATTR_RESET		EQU	80h

;  ���� ��������� 8275 ��� ������������ ���������������
ATTR_CHARSET_G1		EQU	0E5h
ATTR_CHARSET_G0		EQU	0E4h

;  ����������� ���� �������
CHAR_CODE_CR		EQU	0Dh
CHAR_CODE_LF		EQU	0Ah
CHAR_CODE_BEL		EQU	07h
CHAR_CODE_HT		EQU	09h
CHAR_CODE_FF		EQU	0Ch
CHAR_CODE_SO		EQU	0Eh	;  Invoke G1 character set
CHAR_CODE_SI		EQU	0Fh	;  Select G0 character set

CHAR_CODE_LEFT		EQU	08h
CHAR_CODE_RIGHT		EQU	18h
CHAR_CODE_UP		EQU	19h
CHAR_CODE_DOWN		EQU	1Ah
CHAR_CODE_CLS		EQU	1Fh
CHAR_CODE_BACKSPACE	EQU	7Fh
CHAR_CODE_ENTER		EQU	0Dh
CHAR_CODE_ESC		EQU	1Bh
CHAR_CODE_CTRL_C	EQU	03h

;  ��� ������� "���"
CHAR_CODE_ALF		EQU	0FEh

;  ��������� ��������� ����������� CRT
CRT_PIXEL_CLOCK		EQU	10000	;  kHz
CRT_CHAR_WIDTH		EQU	8	;  ������ �������, �������
CRT_HORIZ_TIME		EQU	64	;  ������������ ������, ���
CRT_SPACED_ROWS		EQU	0	;  spaced row [0, 1]
CRT_VERT_ROW_COUNT	EQU	1	;  vertical retrace row count [1, 2, 3, 4]
CRT_UNDERLINE		EQU	10	;  underline placement [1..16]
CRT_LINES_PER_ROW	EQU	10	;  number of lines per character row [1..16]
CRT_LINE_OFFSET		EQU	1	;  line counter mode [0, 1]
CRT_NON_TRANSP_ATTR	EQU	1	;  field attribute mode [0, 1]
CRT_HORIZONTAL_COUNT	EQU	8	;  horizontal retrace count [2, 4, 6, .. 32]
CRT_BURST_SPACE_CODE	EQU	1	;  [0..7]
CRT_BURST_COUNT_CODE	EQU	3	;  [0..3]
CRT_ZZZZ		EQU	((CRT_HORIZ_TIME * CRT_PIXEL_CLOCK / 1000 / CRT_CHAR_WIDTH - SCR_SIZE_X + 1) >> 1) - 1
CRT_ZZZZ6		EQU	((CRT_HORIZ_TIME * 8 / 6 - SCR_SIZE_X + 1) >> 1) - 1
CRT_ZZZZ8		EQU	((CRT_HORIZ_TIME * 10 / 8 - SCR_SIZE_X + 1) >> 1) - 1

;
INP_BUFFER_SIZE		EQU	32
CURSOR_VIEW_INITIAL	EQU	10h

;  ����������� �������� RTC MSM6242
;  ����������� ������� D
RTC_CD_30_S_ADJ		EQU	1 << 3		;  30-second adjustment
RTC_CD_IRQ_FLAG		EQU	1 << 2
RTC_CD_BUSY		EQU	1 << 1
RTC_CD_HOLD		EQU	1 << 0

;  ����������� ������� E
RTC_CE_T_MASK		EQU	3 << 2
RTC_CE_T_64HZ		EQU	0 << 2		;  period 1/64 second
RTC_CE_T_1HZ		EQU	1 << 2		;  period 1 second
RTC_CE_T_1MINUTE	EQU	2 << 2		;  period 1 minute
RTC_CE_T_1HOUR		EQU	3 << 2		;  period 1 hour

RTC_CE_ITRPT_STND	EQU	1 << 1
RTC_CE_MASK		EQU	1 << 0		;  STD.P staut control

;  ����������� ������� F
RTC_CF_TEST		EQU	1 << 3
RTC_CF_12H		EQU	0 << 2
RTC_CF_24H		EQU	1 << 2
RTC_CF_STOP		EQU	1 << 1
RTC_CF_RESET		EQU	1 << 0

;  ������� ����� ����� ������������ config_rk
CFG_RK_FONT_RAM		EQU	00000001b
CFG_RK_FONT_8BIT	EQU	00000100b

;  =================================================================================================

.macro dbdw
	db	%%1
	dw	%%2
.endm

;  �������������:
;  syn_note ������������, ������, ����
;      ������������, ms
;      ������ = -2..5
;      ����   = 1..12
.macro syn_note
	dbdw	%%1, 1000 * CRT_PIXEL_CLOCK / (CRT_CHAR_WIDTH * 440 * 2 ** (((%%2 - 1) * 12 - 10 + %%3) / 12)) + .5
.endm

;  =================================================================================================
;  ====================================================================================  �������  ==

	org	MONITOR_BASE

	jmp	cold_start		;  00  //  �������� �����
	jmp	in_char_vector		;  03  //  ���� ������� � ���������� (����)
	jmp	tape_rd_byte_vector	;  06  //  ������ ����� � �����
	jmp	out_char_c		;  09  //  ����� ������� �� ����� (���. C)
	jmp	tape_wr_byte_vector	;  0c  //  ������ ����� �� �����
	jmp	out_char_vector		;  0f  //  ����� ������� �� ����� (���. A)
	jmp	kbd_state_vector	;  12  //  ��������� ����������
	jmp	out_hex			;  15  //  ����� �� ����� ����� � hex-����
	jmp	out_str			;  18  //  ����� ������ �� �����
	jmp	in_key_vector		;  1b  //  ��� ������� ������� (�� ����)
	jmp	get_cursor		;  1e  //  ��������� ��������� �������
	jmp	get_scr			;  21  //  ������ ����� � ������ � ������� �������
	jmp	tape_rd_block_vector	;  24  //  ������ ����� � �����
	jmp	tape_wr_block_vector	;  27  //  ������ ����� �� �����
	jmp	check_sum		;  2a  //  ������� ����������� ����� �����
	jmp	init_video		;  2d  //  ������������� �����
	jmp	get_ram_top		;  30  //  ��������� ������� ������� ������
	jmp	set_ram_top		;  33  //  ��������� ������� ������� ������
	jmp	wait_sync		;  36  //  ������������� � �������� ���������������
	ret				;  39
	nop
	nop
	jmp	set_cursor		;  3c  //  ��������� ������� �� �����������
	jmp	synthesizer		;  3f  //  ���������� ����������
	jmp	set_charset		;  42  //  ����� ���������������
	lda	config_rk		;  45  //  ������ ������������
	ret

;  =================================================================================================

;  �������� ������ ������� ������� ��������� ������  _______________________________________________
;  �����: HL - ����� �������
get_ram_top:
	lhld	ram_top
	ret

;  ��������� ������ ������� ������� ��������� ������  ______________________________________________
;  ����:  HL - ����� �������
set_ram_top:
	shld	ram_top
	ret

;  =================================================================================================

cold_start:
	lxi	sp, stack
	;  ��� ��� ������ ������� � ����� 3
	lxi	h, ADDR_TIMER_CTRL
	mvi	m, 00110110b
	mvi	m, 01110110b
	mvi	m, 10110110b
	;  ������� ������� ����� ��������
	lxi	h, MONITOR_DATA
	lxi	d, MONITOR_DATA + MONITOR_DATA_SIZE - 17
	mvi	c, 0
	call	directive_f
	call	init_monitor
	;  pad
	ds	MONITOR_WARM_START - $, 0

warm_start:
	;  �.�. ������ ����� ��������.
	;  ��� ������������� � �����������, ������� �������� ���������
	;  �� ������ �����, ���� ����� ������ ���� ����� F86C
	.if $ - MONITOR_WARM_START
	.error MONITOR_WARM_START
	.endif

	lxi	sp, stack
	lxi	h, warm_start
	push	h
	mvi	a, 2
	call	set_charset		;  ������������ �� ����������� ��������������
	mvi	a, 4
	call	set_charset		;  ������������ �� 7-������ ���� � �����
	call	print			;  �����
	db	"\r\n>>\x1bK", 0
	call	get_str			;  ���� ���������
	rz
	inx	d
	call	get_param		;  �������� ������ ��������
	push	h
	cnc	get_param		;  �������� ������ ��������
	push	h
	lxi	h, 0
	cnc	get_param		;  �������� ������ ��������
	mov	c, l
	mov	b, h
	pop	d
	pop	h
	jnc	out_error_txt
	lda	inp_buffer
	call	branch
	dbdw	'B', directive_b
	dbdw	'W', directive_w
	dbdw	'C', directive_c
	dbdw	'D', directive_d
	dbdw	'L', directive_l
	dbdw	'M', directive_m
	dbdw	'F', directive_f
	dbdw	'R', directive_r
	dbdw	'S', directive_s
	dbdw	'T', directive_t
	dbdw	'G', directive_g
	dbdw	'-', directive_sd_card
	db	0
	;  ���� ��������� �������, ���� �� ������� �� ������ ������������
	jmp	extended_directive_handler

;  ���� ������ �������� �� ���������� �����  _______________________________________________________
;  ������ �������� 31 ������� � ���������� � ����������� �����
;  ����� �������������� �������:
;      [<-] � [��] - �������� ���������� �������
;              [.] - ����� �� �����
;             [��] - �������� ������� �� �/�
get_str:
	lxi	h, inp_buffer
get_str_loop:
	call	in_char_vector
	cpi	CHAR_CODE_LEFT
	jz	get_str_back
	cpi	CHAR_CODE_BACKSPACE
	jz	get_str_back
	cpi	CHAR_CODE_CR
	cz	out_char_vector
	jz	get_str_cr
	cpi	'.'
	cz	out_char_vector
	jz	warm_start
	cpi	' '
	jc	get_str_loop
	mov	c, a
	mvi	a, low (inp_buffer_end - 1)
	cmp	l
	jz	pop_and_out_error_txt
	mov	m, c
	inx	h
	call	out_char_c
	jmp	get_str_loop
get_str_back:
	mvi	a, low (inp_buffer)
	cmp	l
	jz	get_str_loop
	call	print
	db	CHAR_CODE_LEFT, " ", CHAR_CODE_LEFT, 0
	dcx	h
	jmp	get_str_loop
get_str_cr:
	mvi	m, 0
	lxi	d, inp_buffer
	mov	a, e
	cmp	l
	ret

;  ��������� ��������� �� ��������� ������  ________________________________________________________
;  ����:  DE - ����� ������, ��� 0 � ������ - ����� ������
;  �����: HL - �����
;         ���� CF = 1 - ��������� ����� ������
;         � ������ ������ ���������� ���������� ���������� ������������
get_param:
	call	inp_buffer_skip_space
	call	str2hex
	call	inp_buffer_skip_space
	ana	a			;  ����� ������?
	stc
	rz				;  �� CF = 1
	inx	d
	cpi	','
	rz				;  CF = 0
pop_and_out_error_txt:
	pop	psw
out_error_txt:
	call	print
	db	"?\r\n\a\a", ATTR_COLOR_RED, "\x0eo[IBKA!\x0f", ATTR_COLOR_WHITE, 0
dummy_func:
	ret

inp_buffer_skip_space:
	ldax	d
	cpi	' '
	rnz
	inx	d
	jmp	inp_buffer_skip_space
	
;  �������� �� ������� CTRL+C � ���������� ����� �����  ____________________________________________
;  ����:  HL - ������� ����� �����
;         DE - �������� ����� �����
;  ��������: 1. ������ CTRL+C   - ������� �� ����� �����
;            2. ������ ���      - ������������ ������
;            3. ��������� ����� - ����� �� ������������ ������������
cmp_and_check_ctrl_c:
	call	in_key_vector
	cpi	CHAR_CODE_CTRL_C	;  CTRL+C/F4?
	jz	warm_start
	cpi	CHAR_CODE_ALF		;  ���?
	jz	cmp_and_check_ctrl_c

;  ����� �� ������������ ������������, ���� ��������� ����� �����  _________________________________
;  ����:  HL - ������� ����� �����
;         DE - �������� ����� �����
cmp_and_exit:
	call	cmp_de_hl
	jnz	$+5
	pop	psw			;  ������� ���������� ����� ��������
	ret				;  ������� �� ������������ ������������
	inx	h			;  ��������� ����� � �����
	ret

;  ����� ����� �� �����  ___________________________________________________________________________
;  ����:  HL - 16-��������� �����
;  ��������: ����� ���������� � ����� ������ � �������� �� ���� � 4 �������
out_word:
	call	print
	db	"\r\n\x1bK    ", 0
	mov	a, h
	call	out_hex
	mov	a, l
	jmp	out_hex

;  ����� ������ �� �����  __________________________________________________________________________
;  ����:  HL - �����
;  ��������: ����� ���������� � ����� ������, ����� ��������� � �������:
;            "    xxxx: "
out_addr:
	call	out_word
	mvi	a, ':'
	call	out_char_vector
	jmp	out_space

;  ����� ����� �� ������ �� ����� � HEX  ___________________________________________________________
;  ����:  HL - ����� ������ ������
out_mem_hex:
	mov	a, m
	call	out_hex
out_space:
	mvi	a, ' '
	jmp	out_char_vector

;  =================================================================================================
;  =========================================================================  ��������� ��������  ==

;  ��������� B  ____________________________________________________________________________________
;  ������ ����� � �������� ������� ������
;  ����:  HL - ��������� �����
;         DE - �������� �����
;         C  - ������� ����
directive_b:
	mov	a, c
	cmp	m
	cz	out_addr
	call	cmp_and_check_ctrl_c
	jmp	directive_b

;  ��������� W  ____________________________________________________________________________________
;  ������ ����� � �������� ������� ������
;  ����:  HL - ��������� �����
;         DE - �������� �����
;         BC - ������� �����
directive_w:
	mov	a, m
	cmp	c
	jnz	directive_w_lbl1
	inx	h
	mov	a, m
	dcx	h
	cmp	b
	cz	out_addr
directive_w_lbl1:
	call	cmp_and_check_ctrl_c
	jmp	directive_w

;  ��������� C  ____________________________________________________________________________________
;  ��������� ���� �������� ������
;  ����:  HL - ��������� ����� ������ ������� ������
;         DE - �������� ����� ������ ������� ������
;         BC - ��������� ����� ������ ������� ������
directive_c:
	ldax	b
	cmp	m
	jz	directive_c_lbl1
	call	out_addr
	call	out_mem_hex
	ldax	b
	call	out_hex
directive_c_lbl1:
	inx	b
	call	cmp_and_check_ctrl_c
	jmp	directive_c

;  ��������� D  ____________________________________________________________________________________
;  ����� �� ����� ����������� ������� ������ � ���� ������������������ �����
;  ����:  HL - ��������� �����
;         DE - �������� �����
directive_d:
	call	out_addr
directive_d_loop:
	call	out_mem_hex
	call	cmp_and_check_ctrl_c
	mov	a, l
	ani	0Fh
	jz	directive_D
	jmp	directive_D_loop

;  ��������� L  ____________________________________________________________________________________
;  ����� �� ����� ����������� ������� ������ � ���� ���������-�������� ��������
;  ����:  HL - ��������� �����
;         DE - �������� �����
directive_l:
	call	out_addr
directive_l_loop:
	mov	a, m
	ora	a
	jm	$+8
	cpi	' '
	jnc	$+5
	mvi	a, '.'
	call	out_char_vector
	call	cmp_and_check_ctrl_c
	mov	a, l
	ani	0Fh
	jz	directive_l
	jmp	directive_l_loop

;  ��������� M  ____________________________________________________________________________________
;  �������� � ��������� ����������� ����� ��� ���������� ����� ������
;  ����:  HL - �����
directive_m:
	call	out_addr
	call	out_mem_hex
	push	h
	call	get_str
	pop	h
	jnc	directive_m_next
	push	h
	call	str2hex
	mov	a, l
	pop	h
	mov	m, a
directive_m_next:
	inx	h
	jmp	directive_m

;  ��������� F  ____________________________________________________________________________________
;  ���������� ������� ������ �����
;  ����:  HL - ����� ������ �������
;         DE - ����� ����� �������
;         C  - ���
directive_f:
	mov	m, c
	call	cmp_and_exit
	jmp	directive_f

;  ��������� -  ____________________________________________________________________________________
;  ������ ����� � SD �����
directive_sd_card:
	lxi	d, 007Fh
	mov	h, d
	mov	l, d
	mov	b, d
	mov	c, d
	push	b

;  ��������� R  ____________________________________________________________________________________
;  ������ ����� �� �������� ROM-�����
;  ����:  HL - ��������� ����� ���
;         DE - �������� ����� ���
;         BC - ����� ����������
directive_r:
	; ����� 0, ����� PA �� ����, ������ PB � PC �� �����
	mvi	a, 10010000b
	sta	ADDR_PORT_CTRL
directive_r_loop:
	shld	ADDR_PORT_PB
	lda	ADDR_PORT_PA
	stax	b
	inx	b
	call	cmp_and_exit
	jmp	directive_r_loop

;  ��������� S  ____________________________________________________________________________________
;  ������� ����������� ����� �����
;  ����:  HL - ����� ������ �����
;         DE - ����� ����� �����
directive_s:
	call	out_word
	xchg
	call	out_word
	xchg
	call	check_sum
	mov	l, c
	mov	h, b
	jmp	out_word

;  ��������� T  ____________________________________________________________________________________
;  ��������� ����� ������
;  ����:  HL - ����� ������ �����
;         DE - ����� ����� �����
;         BC - ����� ����������
directive_t:
	call	cmp_de_hl
	jc	out_error_txt		;  DE < HL
directive_t_loop:
	mov	a, m
	stax	b
	inx	b
	call	cmp_and_exit
	jmp	directive_t_loop

;  ��������� G  ____________________________________________________________________________________
;  ������ ���������
;  ����:  HL - ����� �������
directive_g:
	pchl

;  =================================================================================================
;  ========================================================================  ������������ ������  ==

;  ����� �������  __________________________________________________________________________________
;  ����:  A - ��� �������
out_char:
	push	b
	push	d
	push	h
	push	psw
	lxi	h, out_char_exit
	push	h
	lhld	cursor_pos
	xchg
	lhld	cursor_addr
	;  �������� �� ����� �������� ������� ������ � ������, ����� ����������
	;  ����� �� ���� ��������, �.�. ����� ������� �������� ������������
	;  ������� ����, ��� ����� ����������� ��������
	cpi	' '
	jnc	out_char_regular
	cpi	CHAR_CODE_CR		; (7)
	jz	out_char_code_cr	; (10)
	cpi	CHAR_CODE_LF
	jz	out_char_code_lf
	cpi	CHAR_CODE_SO
	jz	out_char_code_so
	cpi	CHAR_CODE_SI
	jz	out_char_code_si
	cpi	CHAR_CODE_ESC
	jz	out_char_code_esc
	cpi	CHAR_CODE_BEL
	jz	out_char_code_bel
	cpi	CHAR_CODE_HT
	jz	out_char_code_ht
	cpi	CHAR_CODE_LEFT
	jz	out_char_code_left
	cpi	CHAR_CODE_RIGHT
	jz	out_char_code_right
	cpi	CHAR_CODE_UP
	jz	out_char_code_up
	cpi	CHAR_CODE_DOWN
	jz	out_char_code_down
	cpi	CHAR_CODE_CLS
	jz	out_char_code_cls
	cpi	CHAR_CODE_FF
	jz	out_char_code_ff

out_char_regular:
	mov	b, a
	lda	out_char_8bit_mode
	ana	a
	mov	a, b
	jz	out_char_regular_out	;  ����� 7 ���: ��� ���� ���������� � ����� ��� ����
	;  ����� 8 ���

	lda	out_char_charset
	cpi	ATTR_CHARSET_G1		;  �������������� ��������������?
	mov	a, b
	jnz	out_char_regular_g0	;  ���

	;  �������������� ��������������
	ana	a
	jm	out_char_regular_out_7F
	;  ���������� ������������� �� �������� ��������������
	mvi	a, ATTR_CHARSET_G0
	jmp	out_char_regular_lbl1

out_char_regular_g0:
	;  �������� ��������������
	ana	a
	jp	out_char_regular_out	;  ������� �������� ������ �� �����
	;  ���������� ������������� �� �������������� ��������������
	mvi	a, ATTR_CHARSET_G1
out_char_regular_lbl1:
	push	b
	sta	out_char_charset
	call	out_char_regular_out
	pop	psw

out_char_regular_out_7F:
	ani	7Fh
out_char_regular_out:
	mov	m, a
	call	out_char_code_right	;  ������ ������
	rnz				;  �� ����� �� �����, ��������� �� �����
	;  ����� D = E = 0
	;  ������������� ������ �� ������ ������� ��������� ������
	mvi	d, SCR_VIDEO_SIZE_Y - 1
	lxi	h, SCREEN_VIDEO + SCR_SIZE_X * (SCR_VIDEO_SIZE_Y - 1)

;  ��������� ������
out_char_scroll:
	;  � ����� ��������� ������ ������������ ����, ����� �������
	;  ������������ ��� ����� �� ���, ��� ����������� ��������
	push	h
	lxi	h, 0
	dad	sp			;  �������� SP � HL
	shld	tmp_storage		;  � ��������� SP
	;  ����� ���������
	lxi	sp, SCREEN + SCR_SIZE_X * (SCR_PAD_Y + 1)
	;  ����� ��������
	lxi	h, SCREEN + SCR_SIZE_X * SCR_PAD_Y
	;  ������� �������� �����
	mvi	a, SCR_SIZE_X * SCR_VIDEO_SIZE_Y / 5 / 2
out_char_scroll_loop:
	.rept 5
	pop	b			; (10)
	mov	m, c			; (7)
	inx	h			; (5)
	mov	m, b			; (7)
	inx	h			; (5) / 34
	.endm
	dcr	a			; (5)
	jnz	out_char_scroll_loop	; (10)
	;  ����: (34 * 5 + 15) * 78 * 25 / 5 / 2 = 36075 ������
	lhld	tmp_storage		;  ��������������� ��������� �����
	sphl
	pop	h
	ret

;  ����������� ���: ������� �������
out_char_code_cr:
	mov	a, l
	sub	e
	mov	l, a
	mvi	e, 0
	rnc
	dcr	h
	ret

;  ����������� ���: ������� ������
out_char_code_lf:
	mov	a, d
	cpi	SCR_VIDEO_SIZE_Y - 1
	jnc	out_char_scroll		;  ���� ������ �� ��������� ������, �� ������
	inr	d			;  ������ �������� ����
	lxi	b, SCR_SIZE_X
	dad	b
	ret

;  ����������� ���: ������������ �� �������������� ��������������
out_char_code_so:
	mvi	a, ATTR_CHARSET_G1
	sta	out_char_charset
	jmp	out_char_regular

;  ����������� ���: ������� �� �������� ��������������
out_char_code_si:
	mvi	a, ATTR_CHARSET_G0
	sta	out_char_charset
	jmp	out_char_regular

;  ����������� ���: �������������� ���������
out_char_code_ht:
	mov	a, e
	cma
	ani	07h
	mov	c, a
	mvi	b, 0
	dad	b
	add	e
	mov	e, a

;  ����������� ���: ������ ������
out_char_code_right:
	inx	h
	inr	e
	mov	a, e
	sui	SCR_VIDEO_SIZE_X
	rnz				;  ret if E < SCR_VIDEO_SIZE_X, ZF = 0
	lxi	b, -SCR_VIDEO_SIZE_X
	dad	b			;  ������ ������� ����� ������ �� �����
	mov	e, a			;  ������ ������������ � ������ ������

;  ����������� ���: ������ ����
out_char_code_down:
	lxi	b, SCR_SIZE_X
	dad	b
	inr	d
	mov	a, d
	sui	SCR_VIDEO_SIZE_Y
	rnz				;  ret if D < SCR_VIDEO_SIZE_X, ZF = 0
	lxi	b, -(SCR_SIZE_X * SCR_VIDEO_SIZE_Y)
	dad	b
	mov	d, a			;  ������ ������������ �� ������ ������
	;  ����� ����� ZF = 1, CF = 0
	ret

;  ����������� ���: ������ �����
out_char_code_left:
	dcx	h
	dcr	e
	rp				;  ret if E >= 0
	mvi	e, SCR_VIDEO_SIZE_X - 1
	lxi	b, SCR_VIDEO_SIZE_X	;  ������ ������������ � ����� ������
	dad	b

;  ����������� ���: ������ �����
out_char_code_up:
	lxi	b, -SCR_SIZE_X
	dad	b
	dcr	d
	rp				;  ret if D >= 0
	mvi	d, SCR_VIDEO_SIZE_Y - 1	;  ������ ������������ �� ��������� ������
	lxi	b, SCR_SIZE_X * SCR_VIDEO_SIZE_Y
	dad	b
	ret
	
;  ����������� ���: ������� ������
out_char_esc_e:
out_char_code_cls:
	xra	a
	sta	out_char_charset
	mov	l, a
	mov	h, a
	mov	e, a
	mov	d, a
	dad	sp			;  �������� SP � HL
	lxi	sp, SCREEN + SCR_ARRAY	;  ����� ���������� ����� ������ + 1
	mvi	a, SCR_ARRAY / 10 / 2	;  ����� ���� ������� 20 ���� �� ��������
					;  8-������� �������� ������� ��� ��������
out_char_code_cls_loop:
	.rept 10
	push	d			; (11)
	.endm
	dcr	a			; (5)
	jnz	out_char_code_cls_loop	; (10)
	;  ����: (11 * 10 + 15) * 78 * 30 / 10 / 2 = 14625 ������
	sphl

;  ����������� ���: ������ � ������ ������
out_char_esc_h:
out_char_code_ff:
	lxi	d, 0
	lxi	h, SCREEN_VIDEO
	ret

;  ����������� ���: �������� ������
out_char_code_bel:
	lxi	h, out_char_beep
	call	synthesizer3
	jmp	out_char_do_nothing

;  ����������� ���: ������ ESC-������������������, �������� ����� ������
out_char_code_esc:
	lhld	out_char_vector + 1
	shld	out_char_addr_storage
	lxi	h, out_char_escape
	shld	out_char_vector + 1	;  ��������� ��� - ����������
	jmp	out_char_do_nothing

;  ��������� ESC-������������������: ���
out_char_escape:
	;  ��� ���������� ESC+Y �������� ������ � ������ �������,
	;  ��� ������������ ����� ����� ������������ ��� ������� ��������
	cpi	'Y'
	jz	out_char_esc_y		;  ESC+Y
	;  ��� ��������� ����� ���������� ������� ���������
	;  ����������� �������� ����: A - K
	push	b
	push	d
	push	h
	push	psw
	lhld	out_char_addr_storage
	shld	out_char_vector + 1	;  � ��������
	;  �������� ��������� �� 'A' �� 'K'
	sui	'A'
	jc	pop_all_and_ret		;  ��������� ���
	cpi	'K' - '7' + 1
	jnc	pop_all_and_ret		;  ��������� ���
	;  ����� ������ �������� �� ���������� ESC-������������������
	;  ������ � �������� A
	lxi	h, out_char_esc_table	;  ����
	add	a			;  ������ ������ = �����
	add	l
	mov	l, a			;  �������� ����� ������
	mov	c, m
	inx	h
	mov	b, m			;  BC = ����� �����������
	;  ��������� ��� ����������� ������
	lxi	h, out_char_exit
	push	h
	lhld	cursor_pos
	xchg				;  D = posY, E = posX
	lhld	cursor_addr		;  HL = scr addr
	xra	a			;  A = 0
	;  ������� �� ������ ����� ����
	push	b
	ret

out_char_esc_table:
	.if msb(out_char_esc_table_end - 1) - msb($)
	.error out_char_esc_table
	.endif
	;  ����������� ���� ��������� VT52
	dw	out_char_esc_a		;  ESC+A
	dw	out_char_esc_b		;  ESC+B
	dw	out_char_esc_c		;  ESC+C
	dw	out_char_esc_d		;  ESC+D
	dw	out_char_esc_e		;  ESC+E
	dw	out_char_esc_f		;  ESC+F
	dw	out_char_esc_g		;  ESC+G
	dw	out_char_esc_h		;  ESC+H
	dw	out_char_esc_i		;  ESC+I
	dw	out_char_esc_j		;  ESC+J
	dw	out_char_esc_k		;  ESC+K
out_char_esc_table_end:

out_char_esc_f:
out_char_esc_g:
out_char_do_nothing:
	pop	b			;  ������� ����� �������� �� �����
	jmp	pop_all_and_ret


;  ESC+A: ������ �����, ��������������� � ������� �������
out_char_esc_a:
	cmp	d			;  A = 0
	rz
	lxi	b, -SCR_SIZE_X
	dad	b
	dcr	d
	ret

;  ESC+B: ������ ����, ��������������� � ������ �������
out_char_esc_b:
	mvi	a, SCR_VIDEO_SIZE_Y - 1
	cmp	d
	rz
	lxi	b, SCR_SIZE_X
	dad	b
	inr	d
	ret

;  ESC+C: ������ ������, ��������������� � ������ �������
out_char_esc_c:
	mvi	a, SCR_VIDEO_SIZE_X - 1
	cmp	e
	rz
	inx	h
	inr	e
	ret

;  ESC+D: ������ �����, ��������������� � ����� �������
out_char_esc_d:
	cmp	e			;  A = 0
	rz
	dcx	h
	dcr	e
	ret

;  ESC+I: ������ �����, ���� ������ ��� ��� �� ����� ������� �������,
;  ������������ ��������� ������ ����
out_char_esc_i:
	cmp	d			;  A = 0
	jz	out_char_esc_i_scroll
	lxi	b, -SCR_SIZE_X
	dad	b
	dcr	d
	ret

out_char_esc_i_scroll:
	mov	l, a			;  A = 0
	mov	h, a			;  A = 0
	dad	sp			;  �������� SP � HL
	xchg				;  � ��������� HL � DE
	;  ����� ��������
	lxi	sp, SCREEN + SCR_SIZE_X * (SCR_PAD_Y + SCR_VIDEO_SIZE_Y)
	;  ����� ���������
	lxi	h, SCREEN + SCR_SIZE_X * (SCR_PAD_Y + SCR_VIDEO_SIZE_Y - 1)
	;  ������� �������� �����
	mvi	a, SCR_SIZE_X * SCR_VIDEO_SIZE_Y / 10
out_char_esc_i_scroll_loop:
	.rept 5
	dcx	h
	mov	b, m
	dcx	h
	mov	c, m
	push	b
	.endm
	dcr	a
	jnz	out_char_esc_i_scroll_loop
	xchg
	sphl
	jmp	out_char_do_nothing

;  ESC+J: ������� ������ �� ������� �������, ��������� ������� �� ��������
out_char_esc_j:
	mov	m, a			;  ������ ����� ������� ���, � ������ ��������� ������
					;  ���������� ��� ��� ���������, ��� ������� �� ����� ������
	lxi	b, -SCREEN		;  ��������� ���������� �� �������� � �����. ������
	dad	b			;  HL = ����� ������� ������� ������� �� ����
	mov	e, l			;  ������� 4 ���� ����� ��� �����
	dad	h
	dad	h
	dad	h
	dad	h			;  ����� HL ����� �� 4 �������, H = ����� / 16
	mov	b, a			;  A = 0
	mov	c, a			;  A = 0
	mvi	a, SCR_ARRAY / 16	;  ������� �������� ��� ����� ������
	sub	h			;  ������� �������� ��� ����� ������
	mov	h, b			;  B = 0
	mov	l, b			;  B = 0
	dad	sp			;  �������� SP � HL
	lxi	sp, SCREEN + SCR_ARRAY	;  ����� ���������� ����� ������ + 1
out_char_esc_j_loop:
	.rept 8
	push	b
	.endm
	dcr	a
	jnz	out_char_esc_j_loop
	mov	a, e			;  �����-�� �������
	rrc				;  �������������
	ani	7			;  ������� �� ������� �� 8
	jz	out_char_esc_j_lbl	;  � �� �������� ������
	push	b
	dcr	a
	jnz	$-2
out_char_esc_j_lbl:
	sphl
	;  �������������� ������ ���������
	lxi	h, SCREEN + SCR_ARRAY - (SCR_SIZE_X - SCR_VIDEO_SIZE_X - SCR_PAD_X)
	lxi	b, -SCR_SIZE_X
	mvi	a, SCR_SIZE_Y + 1
	mvi	e, ATTR_RESET
	sub	d			;  �������
	rar
	jnc	$+5
	mov	m, e
	dad	b
	mov	m, e
	dad	b
	dcr	a
	jnz	$-5
	jmp	out_char_do_nothing

;  ESC+K: ������� ������ �� ������� �������, ��������� ������� �� ��������
out_char_esc_k:
	mov	c, a			;  A = 0
	mvi	a, SCR_VIDEO_SIZE_X
	sub	e			;  �������
	inr	a
	rar
	jnc	out_char_esc_k_lbl
out_char_esc_k_loop:
	mov	m, c
	inx	h
out_char_esc_k_lbl:
	mov	m, c
	inx	h
	dcr	a
	jnz	out_char_esc_k_loop
	jmp	out_char_do_nothing

;  ESC+Y: ��������� ������� �� �����������
out_char_esc_y:
	;  ���� �� ������� ��� ��������� �� ������ ������ �������� �� �����
	push	h
	lxi	h, out_char_esc_y_p1
	shld	out_char_vector + 1	;  ��������� ��� - ��������� ����������
	pop	h
	ret

;  ESC+Y: ������ �������� - ����� ������
out_char_esc_y_p1:
	;  ��������� ��������, ��������� ����� �����������, �� ��������� ����
	sta	out_char_param
	push	h
	lxi	h, out_char_esc_y_p2
	shld	out_char_vector + 1	;  ��������� ���
	pop	h
	ret

;  ESC+Y: ������ �������� - ����� �������
out_char_esc_y_p2:
	push	b
	push	d
	push	h
	push	psw
	lhld	out_char_addr_storage
	shld	out_char_vector + 1	;  � ��������
	sui	' '			;  �������� �������� � ������� ����
	mov	l, a
	lda	out_char_param		;  ������ ������ ��������
	sui	' '			;  �������� �������� � ������� ����
	mov	h, a
out_char_set_cursor:
	mov	a, l
	cpi	SCR_VIDEO_SIZE_X
	jc	$+4			;  ok
	xra	a
	mov	e, a			;  E = POS_X
	mov	a, h
	cpi	SCR_VIDEO_SIZE_Y
	jc	$+4			;  ok
	xra	a
	mov	d, a			;  D = POS_Y
	;  ����������� ����� ������ �� �����������
	;  HL = POS_Y * SCR_SIZE_X + POS_X + SCREEN_VIDEO
	;  �����: A = D = POS_Y, E = POS_X
	mvi	h, 00h
	mov	l, d
	mov	b, h
	mov	c, d
	dad	h			;  y * 2
	dad	h			;  y * 4
	dad	h			;  y * 8
	dad	b			;  y * 9
	dad	h			;  y * 18
	dad	b			;  y * 19
	dad	h			;  y * 38
	dad	b			;  y * 39
	dad	h			;  y * 78
	mov	c, e			;  BC = POS_X
	dad	b
	lxi	b, SCREEN_VIDEO
	dad	b

out_char_exit:
	shld	cursor_addr
	xchg
	shld	cursor_pos
	lxi	d, (SCR_PAD_Y << 8) | SCR_PAD_X
	dad	d
	xchg
	;  ��������� ������� � ����� �������
	lxi	h, ADDR_CRT_CTRL	;  HL = ����� �������� ������ CRT
	mvi	m, 80h			;  ������� "�������� �������"
	dcx	h			;  HL = ����� �������� ���������� CRT
	mov	m, e			;  ����� ����� (X)
	mov	m, d			;  ����� ��������� (Y)
	;
pop_all_and_ret:
	pop	psw
pop_hdb_and_ret:
	pop	h
pop_db_and_ret:
	pop	d
	pop	b
	ret

;  ����� �������  __________________________________________________________________________________
;  ����:  C - ��� �������
out_char_c:
	push	psw
	mov	a, c
	call	out_char_vector
	pop	psw
	ret

;  ����� ������ ��������  __________________________________________________________________________
;  ����:  HL - ����� ������, ������ ������������ ������� ��������
out_str:
	mov	a, m
	inx	h
	ana	a
	rz
	call	out_char_vector
	jmp	out_str

;  ����� ������ ��������  __________________________________________________________________________
;  ����: ������ �������� ������ ��������� ����� �� ������� ���� �������,
;        ������ ������������ ������� ��������
;  ����������: ��� �������� �����������, ����� A
print:
	xthl
	call	out_str
	xthl
	ret

;  ����� ����� � HEX-����  _________________________________________________________________________
;  ����:  A - ����
out_hex:
	push	psw
	rrc
	rrc
	rrc
	rrc
	call	$+4
	pop	psw
	ani	0Fh
	cpi	10
	sbi	'0' - 1
	daa
	jmp	out_char_vector

;  ������ ��������� �������  _______________________________________________________________________
;  �����: H - ����� ������
;         L - ����� �������
;  ���������: ������� ���������� ��������� ������� �� ������ ������� ������� ������, ��� ���������
;         ���������� �� �������� � ��. �.�. �������� ������� � �� ����������� � �����������, �� ���
;         ������, �������� ����� ������� � ������� ������������ ��������� ������� -- ��� ���� ������
;         ������� ������������� �� � ��-�� ����� ������� ������ � ��� ���� ���������� �� � ����.
;         ��������� � ��� ������� �� ����� ������ ������ ������, � ���� ����������� ��������
;         ���������� �� ������� �������, ��� ��� ������� �� ���� ���������� �����������. �������,
;         ��� �������� � ��������������� � ���������� �����������, �� ����� ��������� ���������, ���
;         ����� ������ �������.
;         ��: ESC+Y+posY+posX � ������ �/� �� out_char ��������� ����������
;         ��� �������� - �� ����, ��� ����� ��� ��������.
get_cursor:
	lhld	cursor_pos
	ret

;  ��������� ��������� �������  ____________________________________________________________________
;  ����:  H - ����� ������ (Y)
;         L - ����� ������� (X)
;  ����������: ������ �� ����
set_cursor:
	push	b
	push	d
	push	h
	push	psw
	jmp	out_char_set_cursor

;  ������ ����� �� ��������� ������  _______________________________________________________________
;  �����: A - ��� �� ������
get_scr:
	push	h
	lhld	cursor_addr
	mov	a, m
	pop	h
	ret

;  =================================================================================================
;  ====================================================================  ������������ ����������  ==

;  ����� ��������� ����������  _____________________________________________________________________
;  �����: A = 00 - �� ������
;         A = FF - ������
;  ����������: ����� �������� �������� A ����� ������������ �������� ����� ZF
;         ���� ZF = 1 - �� ������
;         ���� ZF = 0 - ������
kbd_state:
	lda	kbd_buffer_full
	ana	a
	rnz				;  � ������ ���� ������������� ���
	push	h
	call	in_key_vector
	lhld	kbd_key_status
	cmp	l
	jz	kbd_state_hold
	mov	l, a
kbd_state_released:
	mvi	h, 1			;  �������� ������ ������� �������
	lda	kbd_delay_second_const	;  �������� ����������� ��� ������� �������
	sta	kbd_delay
	xra	a			;  CF = 0, ��� ������: �� ������
kbd_state_rst:
	lda	antibounce_const	;  ������������ ������� ������������
	sta	antibounce
	sbb	a			;  CF = 0 => A = 0, CF = 1 => A = FF
	shld	kbd_key_status
kbd_state_exit:
	pop	h
	ret

kbd_state_hold:
	inr	a			;  in_key == FF ?
	jz	kbd_state_exit		;  ������ �� ������
	inr	a			;  in_key == FE ?
	jz	kbd_state_rus		;  ������ [���/���]
	lda	antibounce
	dcr	a
	jnz	kbd_state_rst + 3	;  ���� ������������
	dcr	h			;  ���������� �������� ������ �������
	jnz	kbd_state_rst		;  ��� �� �����
	;  �������� ������
	lda	kbd_delay
	mov	h, a			;  ������� ����������
	lda	kbd_delay_regular_const	;  �������� ����������� ��� ��������� ��������
	sta	kbd_delay
kbd_state_pressed:
	stc				;  CF = 1
	sbb	a			;  A = FF - ��� ������: ������
	sta	kbd_buffer_full
	jmp	kbd_state_rst

kbd_state_rus:
	;  ��������� ������� �� �������� ���������������:
	;  ��� ������������ �/� (0, ������ ��������� ��������� � ������� �����):
	;    -  ����������� ���������: ������� [���/���] �� ���������� ������
	;  ��� ������������ �/� (2, ��������� � �������� ����� ����� ���������):
	;    -  ������� [���/���] ���������� ��� 0E ��� ������������ �� �������
	;        ��������� � ��� 0F ��� ������������ �� ��������� ���������
	call	in_key_vector
	cpi	CHAR_CODE_ALF
	jz	kbd_state_rus		;  ��� ���������� ������� [���/���]
	lda	kbd_rus
	cma
	sta	kbd_rus
	mov	h, a			;  ��������� ��������� kbd_rus
	mvi	l, 0FFh			;  ��� "������ �� ������"
	lda	ADDR_KBD_PC		;  KBD_PC - ��� ��������� ������ �/�
	rar				;  ��������� 0-� ������
	jnc	kbd_state_released	;  ����������� ���������
	;  8-������ ����� ���������� ������ ��� �/� � ������ 2
	lda	kbd_8bit_mode
	ana	a
	jnz	kbd_state_8bit
	;  7-������ ����� ����������
	mvi	a, CHAR_CODE_SI		;  A = 0F - ��� �������� �� ��������� ���������
	add	h			;  H = 0/-1
	mov	l, a			;  L = 0F/0E
	mvi	h, 1
	jmp	kbd_state_pressed

kbd_state_8bit:
	mvi	a, 80h
	ana	h
	sta	kbd_8bit_rus
	jmp	kbd_state_released

;  ���� ������� � ����������  ______________________________________________________________________
;  �����: A - ��������� ���
in_char:
	call	kbd_state_vector
	jz	in_char
	push	h
	lxi	h, in_char_lat_beep	;  ��������� ������� ��� ��������� ���������
	lda	kbd_rus
	ana	a
	jz	$+6
	lxi	h, in_char_rus_beep	;  ��������� ������� ��� ������� ���������
	xra	a
	sta	kbd_buffer_full		;  ����� ����� "����� �����"
	cmp	m
	cnz	synthesizer3
	pop	h
	lda	kbd_8bit_rus
	ral				;  ������� ������� ��������� ��������� � 7-� ����
	lda	kbd_key_status
	rnc
	cpi	20h			;  ����������� ������� �� ������ �����������������
	rc
	ori	80h
	ret

;  ������� ���������� �����-86��  __________________________________________________________________
;  �����: A = FF - �� ������
;         A = FE - ���/���
;         A - ��� �������
;  ��������: ������������ ���������� ��� ������� ������� ��� ��������. ��� ������������ ��������
;         ��������� (����������� ��������) � ��������� ��������� ���� ������������, ������� �������
;         � ������������ ���������. �� ��� ������, ������������� ����� ������������ � ������������
;         in_key �������� �������, �.�. �� ���� ��������, ������� ����������� � ������������
;         kbd_state, � ����� �� � � ������������ in_char, � �������� ������� ������������. �����
;         �������, ������������ in_key ������ ����������� �������� ��� ������ ����������, ���
;         ��������� ������������ � � �����, ��� ������� ������ �������.

in_key:
	lda	ADDR_KBD_PC
	ani	KBD_RUS_FLAG
	mvi	a, CHAR_CODE_ALF
	rz				;  ���������: FE, ������ [���/���]
	lda	kbd_rus
	ani	1
	ori	3 << 1			;  3-� ��� ����� C
	sta	ADDR_KBD_CTRL		;  ��������� "���"
	xra	a
	sta	ADDR_KBD_PA
	lda	ADDR_KBD_PB
	cpi	0FFh
	rz				;  ���������: ������ �� ������, A = FF
	push	b
	push	d
	push	h
	lxi	h, pop_hdb_and_ret
	push	h
	lxi	b, 0FF1Fh
	lxi	d, ADDR_KBD_PA
	lxi	h, ADDR_KBD_PB
	xra	a
	dcr	a
	;  A = FF, �������� ����
	;  B = ����� �������
	;  C = const 1F
	;  ����� ���� CF ������ ���� ����� 0
in_key_loop:
	ral
	rnc				;  ���������: �� ������, A = FF
	stax	d
	inr	b
	inr	m
	jz	in_key_loop

	;  ������� ����� � ������������ ����-���
	mov	a, b
	rlc
	rlc
	rlc
	add	c
	mov	b, a			;  B = B * 8 + 1F
	mov	a, m
	inr	b
	rar
	jc	$-2
	;  ������� �������
	lxi	d, 205Fh
	;  D = const 20 - ��� �������
	;  E = const 5F
	mov	a, b
	cmp	e			;  ����-��� 5F - ��� ������
	mov	a, d			;  A = 20
	rz				;  ���������: ������
	mov	a, b
	cpi	30h			;  ��� ������� '0'
	rz				;  ���������: '0', �� �������������� ������

	lxi	h, ADDR_KBD_PC
	jc	in_key_20_2F		;  ����� ������ A0-A1
	;  ����� ������ A2-A7
	cpi	40h
	jc	in_key_31_3F

	;  ���� 40-7Fh
	mov	a, m			;  A = KBD_PC
	ani	KBD_CTRL_FLAG		;  KBD_PC & KBD_CTRL_FLAG
	jnz	in_key_40_7F		;  no ctrl
	;  ctrl
	mov	a, b
	ana	c
	ret				;  ���������: ���� 00-1F

in_key_40_7F:
	lda	kbd_rus
	ana	a
	jz	$+6			;  lat
	;  rus
	mov	a, b
	ora	d			;  4x => 6x
	mov	b, a
	mov	a, m			;  A = KBD_PC
	ana	d			;  KBD_PC & KBD_SHIFT_FLAG
	mov	a, b
	rnz				;  ���������: ��������� ������� ��� �����
	xra	d			;  4x => 6x, 6x => 4x
	ret				;  ���������: ��������� ������� � ������

in_key_31_3F:
	;  ���� 31h-3Fh
	mov	a, m			;  A = KBD_PC
	ana	d			;  KBD_PC & KBD_SHIFT_FLAG
	mov	a, b
	jnz	$+6			;  no shift
	;  shift
	ani	2Fh
	mov	b, a
	ani	0Fh
	cpi	0Ch
	mov	a, b
	rc
	xri	10h			;  ��� ����� xC-xF ������������� 4-� ���:
					;  2x => 3x, 3x => 2x
	ret				;  ���������: ���� 20-3F

in_key_20_2F:
	;  ����� ������ A0-A1
	;  ����-���� 20-2F, ����������� �������� ����� �������
	lxi	b, kbd_table - 20h
	add	c
	mov	c, a
	ldax	b
	cpi	CHAR_CODE_BACKSPACE
	rnz				;  ���������: ���� ����������� ������
	mov	a, m			;  A = KBD_PC
	ana	d			;  KBD_PC & KBD_SHIFT_FLAG
	mvi	a, CHAR_CODE_BACKSPACE
	rnz				;  ���������: �����
	mov	a, e
	ret				;  ���������: 5F - ������ �������������

kbd_table:
	;  ������� ������ ������� ��������� � 256-�������� ��������
	db	0Ch, 1Fh, 1Bh, 00h, 01h, 02h, 03h, 04h
	db	09h, 0Ah, 0Dh, 7Fh, 08h, 19h, 18h, 1Ah
kbd_table_end:

;  =================================================================================================
;  ========================================================================  ������ ������������  ==

;  �������������� HEX-������ � �����  ______________________________________________________________
;  ����:  DE - ����� ������
;  �����: HL - ���������
;         DE - �����, ��� ������������ ���������
;         ���� ZF = 1 � CF = 0 - ��������� ����� ������
;         ���� CF = 1 - ���������� ������, �� ��������������� hex-�����
;  ����������: �������� �� ������������ �� ������������, ������� ����� ���������� �����, ���� �
;         ������ ����������� HEX-�����, ��������, ������ "123ACF" ���� ��������� 3ACF
str2hex:
	xra	a
	mov	h, a		;  HL = ���������
str2hex_loop:
	mov	l, a
	ldax	d
	ana	a
	rz
	sui	'0'
	rc
	cpi	10
	jc	str2hex_add
	sui	7
	cpi	10
	rc
	cpi	16
	cmc
	rc
str2hex_add:
	dad	h
	dad	h
	dad	h
	dad	h
	ora	l
	inx	d
	jmp	str2hex_loop

;  ������� �� ������ �� ������� ���������  _________________________________________________________
;  ����:  A - ������� �������� ��� ������, ������ ���� �������� �� ����
;         ������� ��������� ������ ��������� ����� �� ������� ���� �������
;  ������ �������:
;         DB  XX, ��� XX - ���� ������������
;         DW  ADDR, ��� ADDR - ����� �������� ��� ����������
;         ������� ���� XX - ���������� ������� 
;  ��������: ��� ���������� �������� ����� � ����� �� ������ ������������
;         ���������� ������� �� ������ ADDR, ���� ������������ ����� � �������
;         �� ������������, ���������� ������� �� ������, ���������� �� ��������.
;  ����������: ��� �������� �����������
branch:
	xthl				;  (18)
	push	b			;  (11)
	mov	c, a			;  (5)
	dcx	h			;  (5)
	dcx	h			;  (5)
branch_loop:
	inx	h			;  (5)
	inx	h			;  (5)
	mov	a, m			;  (7)
	inx	h			;  (5)
	ana	a			;  (4)
	jz	branch_exit		;  (10)
	cmp	c			;  (4)
	jnz	branch_loop		;  (10) / 50 ������ �� ��������
	;  ������� ����������
	mov	a, m			;  (7)
	inx	h			;  (5)
	mov	h, m			;  (7)
	mov	l, a			;  (5)
branch_exit:
	mov	a, c			;  (5)
	pop	b			;  (10)
	xthl				;  (18)
	ret				;  (10)
	;  161 ���� ���� ���

;  ��������� ���� 16-��������� �����  ______________________________________________________________
;  ����:  DE - ������ �����
;         HL - ������ �����
;  �����: ���� ZF = 1: DE == HL
;         ���� ZF = 0 � CF = 1: DE < HL
;         ���� ZF = 0 � CF = 0: DE > HL
cmp_de_hl:
	mov	a, d
	cmp	h
	rnz
	mov	a, e
	cmp	l
	ret

;  ����ר� ����������� ����� �����  ________________________________________________________________
;  ����:  HL - ����� ������ �����
;         DE - ����� ����� �����
;  �����: BC - ����������� �����
check_sum:
	lxi	b, 0
	jmp	check_sum_start
check_sum_loop:
	mov	a, c
	add	m
	mov	c, a
	mov	a, b
	adc	m
	mov	b, a
	inx	h
check_sum_start:
	call	cmp_de_hl
	jnz	check_sum_loop
	mov	a, c
	add	m
	mov	c, a
	ret

;  ������������� � �������� ���������������  _______________________________________________________
wait_sync:
	lda	ADDR_CRT_CTRL		;  ����� �������� ������
	lda	ADDR_CRT_CTRL		;  ������ ����� ���������
	ani	20h			;  ����� ���� IR - ������ ����������
	jz	$-5			;  ��� �������������� IR
	ret

;  SYNTHESIZER  ____________________________________________________________________________________
;  ������ ���������� � ����� ������
;  ����:  A  - ����� ������ [0, 1, 2]
;         H  - �������� � ��, ���� 0 - ��� ��������
;         DE - ����������� �������
synthesizer:
	cpi	3
	rnc
	mov	l, a
	push	h
	lxi	h, ADDR_TIMER
	add	l
	mov	l, a
	mov	m, e			;  ������� ����
	mov	m, d			;  ������� ����
	pop	h
	inr	h
	dcr	h
	rz				;  ��� ��������
	;  1 ����(���) = 1000 / CPU_CLOCK(���)
	;  ���������� ������ ��� 1��� = CPU_CLOCK(���) / 1000
	;  ��� �������� � 1�� ���������� �������� = 1000 * (�.�.1���) / 20
synthesizer_delay:
	mvi	a, (1000 * CPU_CLOCK / 1000) / 20
	mov	a, a			;  (5)
	dcr	a			;  (5)
	jnz	$-2			;  (10)
	dcr	h
	jnz	synthesizer_delay
	mov	a, l			;  ����� 1 � 0 ������� � 7 � 6 �������
	rar
	rar
	rar
	ori	00110110b		;  D7:D6 - ����� �������
	sta	ADDR_TIMER_CTRL		;  ��������� �����
	ret

;  SYNTHESIZER3  ___________________________________________________________________________________
;  ������ ���������� ����� � ��� �������
;  ����:  HL - ����� ��������� � �������
;              ������ ���������:
;                  DB	�������� � �� (�����������)
;                  DW	����������� �������
synthesizer3:
	push	b
	mov	a, m
	inx	h
	mov	c, m
	inx	h
	mov	b, m
	lxi	h, ADDR_TIMER
	mov	m, c
	mov	m, b
	inx	h
	mov	m, c
	mov	m, b
	inx	h
	mov	m, c
	mov	m, b
	inx	h
	mov	c, a
synthesizer_int_delay:
	mvi	a, (1000 * CPU_CLOCK / 1000) / 20
	mov	a, a			;  (5)
	dcr	a			;  (5)
	jnz	$-2			;  (10)
	dcr	c
	jnz	synthesizer_int_delay
	mvi	m, 00110110b
	mvi	m, 01110110b
	mvi	m, 10110110b
	pop	b
	ret

;  ����� ��������������� / ������ ���������� � �������  ____________________________________________
;  ����:  A - ����� ���������������
;         A = 0 - ����������� �/�: ������ ��������� ��������� � ������� �����
;         A = 1 - ����������� �/� ������
;         A = 2 - ����������� �/�: ��������� � �������� ����� ����� ���������
;         A = 3 - ���������� � 8-������ ������, ������� � 8-������ ������
;         A = 4 - ���������� � 7-������ ������, ������� � 7-������ ������
;         A = 5 - ���������� � 8-������, ������� � 7-������ ������
;         A = 6 - ���������� � 7-������ ������, ������� � 8-������ ������
set_charset:
	;  PC0 = ROM_A11
	;  PC1 = 0 => ROM_A10 = 1
	;  PC1 = 1 => ROM_A10 = screen attr
	;  A = 0: PC = 10b
	;  A = 1: PC = 00b
	;  A = 2: PC = 11b
	cpi	3
	jnc	set_charset_koi
	xri	1		;  A = 1, 0, 3
	push	psw
	ani	1
	ori	1 << 1
	sta	ADDR_KBD_CTRL	;  PC1
	pop	psw
	rar
	sta	ADDR_KBD_CTRL	;  PC0
	ret

set_charset_koi:
	;  ��� 0 - ����� ����������: 7 ��� (0) / 8 ��� (1)
	;  ��� 1 - ����� �������: 7 ��� (0) / 8 ��� (1)
	rar
	push	psw
	sbb	a
	sta	kbd_8bit_mode
	xra	a
	sta	kbd_rus			;  ���������� �������� ���� ������� ���������, �� ������
	sta	kbd_8bit_rus		;  � ��� ����
	pop	psw
	rar
	sbb	a
	sta	out_char_8bit_mode
	ret

;  ������������� �������� ��� �������� ������  _____________________________________________________
init_monitor:
	call	init_video	;  �������� �� ���������,
				;  ���� ���������� ���������� �������, �������
				;  ����������� ��� ������ ���������
	;  ������ ����� ���������� ������� �������� � ����� PC ����������.
	;  ���� PC �� ����, ��� ������ ������������
	;  ���� PC �������� ������������ ����������:
	;  PC0 = 0 - �������������� �������� � ROM
	;  PC0 = 1 - �������������� �������� � RAM
	;  PC2 = 0 - ����� ����� ������ 6 ��������
	;  PC2 = 1 - ����� ����� ������ 8 ��������
	lxi	h, ADDR_KBD_CTRL
	mvi	m, 10001011b
	lda	ADDR_KBD_PC
	sta	config_rk
	;  ���� ���������� � ������ 0
	;  ����� A �� �����, ����� B �� ����,
	;  ����� PC0-PC3 �� �����, PC4-PC7 �� ����
	mvi	m, 10001010b
	;  ��������� ���� ����� PC ������ ������ ������� �������� ������������
	ani	CFG_RK_FONT_8BIT
	sta	ADDR_KBD_PC
	;  ����������� ����� ���� �� ROM � RAM
	lxi	h, rom_data			;  ������
	lxi	d, rom_data_end - 1		;  ������
	lxi	b, ram_data			;  ����
	call	directive_t_loop
	;  ���������
	call	print
	db	CHAR_CODE_CLS, ATTR_COLOR_YELLOW, "\x0eradio-86rk/60K\x0f", ATTR_COLOR_WHITE, 0

;  ������������� ������������  _________________________________________________________________
init_video:
	push	h
	lxi	h, ADDR_CRT_CTRL
	mvi	m, 0			;  ������� "�����"
	dcx	h

	;  ���������� �����: ����������� 4 ����� � ������� ����������
	;  1. SHHHHHHH
	;     S        - ���������:
	;                0 - ���������� ���������
	;                1 - ������������ ���������
	;      HHHHHHH - ����� ������ � ��������� ����� ���� (�� 1 �� 80)
	mvi	m, (SCR_SIZE_X - 1) | (CRT_SPACED_ROWS << 7)

	;  2. VVRRRRRR
	;     VV       - ������������ ��������� ���� �������� ���������
	;                00 - 1 ��������
	;                01 - 2 ���������
	;                10 - 3 ���������
	;                11 - 4 ���������
	;       RRRRRR - ����� ���������� � ����� ����� ���� (�� 1 �� 64):
	mvi	m, (SCR_SIZE_Y - 1) | ((CRT_VERT_ROW_COUNT - 1) << 6)

	;  3. UUUULLLL
	;     UUUU     - ����� ������ ������������� � ���������, ������� ���
	;                ���������� ������� ������� � ������ ����� ������ �
	;                ���������, ���� UUUU = 1xxx, �� ������ �������
	;         LLLL - ����� ����� ������ � ��������� (�� 1 �� 16)
	mvi	m, ((CRT_UNDERLINE - 1) << 4) | (CRT_LINES_PER_ROW - 1)

	;  4. MFCCZZZZ
	;     M        - ����� �������� �����:
	;                0 - �� ��������
	;                1 - ������� �� 1 ����
	;                �������� �� ���. 125
	;      F       - ����� ��������� ����:
	;                0 - ����������
	;                1 - ������������
	;       CC     - ��� �������:
	;                00 - ��������� ���������� ���������
	;                01 - ��������� �������������
	;                10 - ����������� ���������� ���������
	;                11 - ����������� �������������
	;         ZZZZ - ����� ������ ��� �������� ���� ��������
	;                ��������� (2, 4, 6, ..., 32): (3 + 1) * 2 = 8
	lda	ADDR_KBD_PC
	ani	CFG_RK_FONT_8BIT
	mvi	l, CRT_ZZZZ6 | (CRT_LINE_OFFSET << 7) | (CRT_NON_TRANSP_ATTR << 6)
	jz	$+5
	mvi	l, CRT_ZZZZ8 | (CRT_LINE_OFFSET << 7) | (CRT_NON_TRANSP_ATTR << 6)
	lda	cursor_view
	ora	l
	mvi	l, low (ADDR_CRT_PARAM)
	mov	m, a
	inx	h			;  HL = ����� �������� ������ CRT

	;  001SSSBB - ������� "������ ���������������"
	;     SSS   - �������� ����� ��������, ����� ���������������
	;             ����� ����� ��������� ��������� ���:
	;             000 = 0
	;             001 = 7
	;             010 = 15
	;             011 = 23
	;             100 = 31
	;             101 = 39
	;             110 = 47
	;             111 = 55
	;        BB - ����� �������� ��� � ������:
	;             00 = 1
	;             01 = 2
	;             10 = 4
	;             11 = 8
	mvi	m, 00100000b | (CRT_BURST_SPACE_CODE << 2) | CRT_BURST_COUNT_CODE
	call	wait_sync

	lxi	h, ADDR_DMA + 8		;  ����� �������� ������� ���
	mvi	m, 10000000b		;  ������ ���
	mvi	l, low (ADDR_DMA + 04h)	;  ����� �������� ������ ������ 2 ���
	mvi	m, low (SCREEN)		;  ������� ����� ������
	mvi	m, high (SCREEN)	;  ������� ����� ������
	inr	l			;  ����� �������� ���������� ������ ��� ������ 2

	;  16 ��� = RWCCCCCC CCCCCCCC
	;  CCCCCC CCCCCCCC - ���������� ������
	;  RW = 00 - ���� �������� ��
	;  RW = 01 - ���� ������ ��
	;  RW = 10 - ���� ������ ��
	;  RW = 11 - ����������� ����������
	;  ������� ���� �������� ������ (���� C7-C0)
	mvi	m, low (SCR_ARRAY - 1)
	;  ������� ���� �������� ������ (���� C13-C8)
	mvi	m, high (SCR_ARRAY - 1) | (01b << 6)
	mvi	l, low (ADDR_DMA + 08h)	;  ����� �������� ������� ���

	;  D7 [AL]  = 1 - ������������
	;  D6 [TCS] = 0 - ��-����
	;  D5 [EW]  = 1 - ���������� ������
	;  D4 [RP]  = 0 - ����������� �����
	;  D3 [EN3] = 0 - ���������� ������ 3
	;  D2 [EN2] = 1 - ���������� ������ 2
	;  D1 [EN1] = 0 - ���������� ������ 1
	;  D0 [EN0] = 0 - ���������� ������ 0
	mvi	m, 10100100b		;  ��������� ������

	;  ����� ���������� ����� ���
	pop	h
	ret

;  =================================================================================================
;  =====================================================================================  ������  ==

;  ���� ����, ������� ����������� � ����������� ������  ____________________________________________
rom_data:
	jmp	out_char		;  out_char_vector
	jmp	in_char			;  in_char_vector
	jmp	in_key			;  in_key_vector
	jmp	kbd_state		;  kbd_state_vector
	jmp	dummy_func		;  tape_rd_byte_vector
	jmp	dummy_func		;  tape_wr_byte_vector
	jmp	dummy_func		;  tape_rd_block_vector
	jmp	dummy_func		;  tape_wr_block_vector
	jmp	out_error_txt

	dw	MONITOR_DATA - 1	;  ram_top
	syn_note	4, 2, 4		;  in_char_lat_beep: ��������� ���������
					;  "��" ������ ������, 4 ��
	syn_note	4, 2, 7		;  in_char_rus_beep: ������� ���������
					;  "����" ������ ������, 4 ��
	syn_note	50, 1, 9	;  out_char_beep: "��" ������ ������, 50 ��
	db	KBD_ANTIBOUNCE		;  antibounce
	db	KBD_ANTIBOUNCE		;  antibounce_const
	db	KBD_DELAY_SECOND	;  
	db	KBD_DELAY_REGULAR	;  kbd_delay_regular_const
	dw	0FFFFh			;  kbd_key_status
	db	CURSOR_VIEW_INITIAL	;  cursor_view: 00h, 10h, 20h, 30h
rom_data_end:

	ds	10000h - 2 - $, 0FFh
	org	10000h - 2
	db	"60"

;  =================================================================================================
;  ������� ���������� �������� � ����������� ������

	org	MONITOR_DATA

;  ������� ��� � ������� ���������� ������ �� ���  _________________________________________________
ram_data:
;  ������� ����������� ��������
out_char_vector:			;  #0
	ds	3
in_char_vector:				;  #1
	ds	3
in_key_vector:				;  #2
	ds	3
kbd_state_vector:			;  #3
	ds	3
tape_rd_byte_vector:			;  #4
	ds	3
tape_wr_byte_vector:			;  #5
	ds	3
tape_rd_block_vector:			;  #6
	ds	3
tape_wr_block_vector:			;  #7
	ds	3
extended_directive_handler:
	ds	3
ram_top:				;  ������� ������� ������ [get_ram_top] [set_ram_top]
	ds	2
in_char_lat_beep:			;  ������ ������� ��� ��������� ��������� [in_char]
	ds	3
in_char_rus_beep:			;  ������ ������� ��� ������� ��������� [in_char]
	ds	3
out_char_beep:				;  ��� 7 [out_char]
	ds	3
antibounce:				;  ������� ������������ [kbd_state]
	ds	1
antibounce_const:			;  [kbd_state]
	ds	1
kbd_delay_second_const:			;  [kbd_state]
	ds	1
kbd_delay_regular_const:		;  [kbd_state]
	ds	1
kbd_key_status:				;  ��� ������� � ���������� �������� [kbd_state]
	ds	2
cursor_view:				;  ��� ������� (���������/�������������) [init_video]
	ds	1			;  ���������� ��������: 00h, 10h, 20h, 30h
;  end ram_data
;  _________________________________________________________________________________________________
cursor_addr:				;  ������� �������� ������ ������� [out_char]
	ds	2
cursor_pos:				;  ������� ��������� ������� [out_char]
	ds	2
out_char_charset:			;  ��� ��� ������������ ��������������� [out_char]
	ds	1
out_char_param:				;  ������� ������ ESC+Y [out_char]
	ds	1
out_char_8bit_mode:			;  8-������ ����� ��� ������ ������� [out_char]
	ds	1
kbd_8bit_mode:				;  8-������ ����� ��� ���������� [in_char]
	ds	1
kbd_8bit_rus:				;  ���� ������� ��������� � ����� 8 ��� [in_char]
	ds	1
kbd_buffer_full:			;  ���� ������� ���� � ������ ���������� [kbd_state]
	ds	1
kbd_delay:				;  ��������� �������� ������ ���� [kbd_state]
	ds	1
kbd_rus:				;  ���� ������� ��������� ���������� [kbd_state] [in_key]
	ds	1
out_char_addr_storage:			;  ���������� ������������� ������ ������� out_char
	ds	2
tmp_storage:				;  ���������� ��� ���������� ��������
	ds	2
inp_buffer:				;  ����� ��������� ������
	ds	INP_BUFFER_SIZE
inp_buffer_end:

config_rk:				;  ���� ������������, ������������ ����������
	ds	1

	org	MONITOR_DATA + MONITOR_DATA_SIZE
stack:

;  =================================================================================================
;  end of file  ====================================================================================
