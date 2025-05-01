;  #################################################################################################
;  ##  УПРАВЛЯЮЩАЯ ПРОГРАММА "МОНИТОР" ДЛЯ КОМПЬЮТЕРА "РАДИО-86РК/60-Nova"                        ##
;  #################################################################################################
;
;  Author:  Vitaliy Poedinok aka Vital72
;  License: MIT
;  www:     http://www.86rk.ru/
;  e-mail:  vital72@86rk.ru
;  Version: 1.0
;  =================================================================================================

VERSION			EQU	"1.0"

CPU_CLOCK		EQU	3000	;  тактовая частота CPU в килогерцах

MONITOR_BASE		EQU	0F800h	;  стартовый адрес МОНИТОРА
MONITOR_EXTENSION	EQU	0F000h	;  стартовый адрес расширения МОНИТОРА
MONITOR_DATA		EQU	0E600h	;  начало области рабочих ячеек МОНИТОРА
MONITOR_DATA_SIZE	EQU	000D0h	;  размер области рабочих ячеек МОНИТОРА
MONITOR_WARM_START	EQU	0F86Ch	;  горячий старт/консоль

;  базовые адреса микросхем периферии
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

;  флаги управляющих клавиш клавиатуры
KBD_RUS_FLAG		EQU	80h
KBD_CTRL_FLAG		EQU	40h
KBD_SHIFT_FLAG		EQU	20h

;  константы задержек при обработке нажатий клавиш
KBD_ANTIBOUNCE		EQU	8	;  антидребезг
KBD_DELAY_SECOND	EQU	90	;  задержка автоповтора для второго символа
KBD_DELAY_REGULAR	EQU	24	;  задержка автоповтора для остальных символов

;  размер видимой части экрана в символах
SCR_VIDEO_SIZE_X	EQU	64	;  по X
SCR_VIDEO_SIZE_Y	EQU	25	;  по Y
;  полный размер экрана, включающий бланкирующие зоны, в символах
SCR_SIZE_X		EQU	78	;  по X
SCR_SIZE_Y		EQU	30	;  по Y
SCR_ARRAY		EQU	SCR_SIZE_X * SCR_SIZE_Y
; отступ левого верхнего угла видимой части экрана, в символах
SCR_PAD_X		EQU	8	;  по горизонтали
SCR_PAD_Y		EQU	3	;  по вертикали
;  адреса экранной области и видимой его части
SCREEN			EQU	MONITOR_DATA + MONITOR_DATA_SIZE
SCREEN_VIDEO		EQU	SCREEN + SCR_SIZE_X * SCR_PAD_Y + SCR_PAD_X

;  коды атрибутов 8275 для вывода цветного изображения
ATTR_COLOR_BLACK	EQU	8Dh
ATTR_COLOR_RED		EQU	8Ch
ATTR_COLOR_GREEN	EQU	85h
ATTR_COLOR_YELLOW	EQU	84h
ATTR_COLOR_BLUE		EQU	89h
ATTR_COLOR_MAGENTA	EQU	88h
ATTR_COLOR_CYAN		EQU	81h
ATTR_COLOR_WHITE	EQU	80h

;  коды атрибутов 8275 для подчеркивания, мерцания и негативного изображения
ATTR_UNDERLINE		EQU	0A0h
ATTR_BLINKING		EQU	82h
ATTR_REVERSE		EQU	90h
ATTR_RESET		EQU	80h

;  коды атрибутов 8275 для переключения знакогенератора
ATTR_CHARSET_G1		EQU	0E5h
ATTR_CHARSET_G0		EQU	0E4h

;  управляющие коды дисплея
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

;  код клавиши "АЛФ"
CHAR_CODE_ALF		EQU	0FEh

;  параметры настройки контроллера CRT
CRT_PIXEL_CLOCK		EQU	10000	;  kHz
CRT_CHAR_WIDTH		EQU	8	;  ширина символа, пикселы
CRT_HORIZ_TIME		EQU	64	;  длительность строки, мкс
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

;  управляющие регистры RTC MSM6242
;  управляющий регистр D
RTC_CD_30_S_ADJ		EQU	1 << 3		;  30-second adjustment
RTC_CD_IRQ_FLAG		EQU	1 << 2
RTC_CD_BUSY		EQU	1 << 1
RTC_CD_HOLD		EQU	1 << 0

;  управляющий регистр E
RTC_CE_T_MASK		EQU	3 << 2
RTC_CE_T_64HZ		EQU	0 << 2		;  period 1/64 second
RTC_CE_T_1HZ		EQU	1 << 2		;  period 1 second
RTC_CE_T_1MINUTE	EQU	2 << 2		;  period 1 minute
RTC_CE_T_1HOUR		EQU	3 << 2		;  period 1 hour

RTC_CE_ITRPT_STND	EQU	1 << 1
RTC_CE_MASK		EQU	1 << 0		;  STD.P staut control

;  управляющий регистр F
RTC_CF_TEST		EQU	1 << 3
RTC_CF_12H		EQU	0 << 2
RTC_CF_24H		EQU	1 << 2
RTC_CF_STOP		EQU	1 << 1
RTC_CF_RESET		EQU	1 << 0

;  битовые маски байта конфигурации config_rk
CFG_RK_FONT_RAM		EQU	00000001b
CFG_RK_FONT_8BIT	EQU	00000100b

;  =================================================================================================

.macro dbdw
	db	%%1
	dw	%%2
.endm

;  использование:
;  syn_note ДЛИТЕЛЬНОСТЬ, ОКТАВА, НОТА
;      ДЛИТЕЛЬНОСТЬ, ms
;      ОКТАВА = -2..5
;      НОТА   = 1..12
.macro syn_note
	dbdw	%%1, 1000 * CRT_PIXEL_CLOCK / (CRT_CHAR_WIDTH * 440 * 2 ** (((%%2 - 1) * 12 - 10 + %%3) / 12)) + .5
.endm

;  =================================================================================================
;  ====================================================================================  МОНИТОР  ==

	org	MONITOR_BASE

	jmp	cold_start		;  00  //  холодный старт
	jmp	in_char_vector		;  03  //  ввод символа с клавиатуры (блок)
	jmp	tape_rd_byte_vector	;  06  //  чтение байта с ленты
	jmp	out_char_c		;  09  //  вывод символа на экран (рег. C)
	jmp	tape_wr_byte_vector	;  0c  //  запись байта на ленту
	jmp	out_char_vector		;  0f  //  вывод символа на экран (рег. A)
	jmp	kbd_state_vector	;  12  //  состояние клавиатуры
	jmp	out_hex			;  15  //  вывод на экран байта в hex-коде
	jmp	out_str			;  18  //  вывод строки на экран
	jmp	in_key_vector		;  1b  //  код нажатой клавиши (не блок)
	jmp	get_cursor		;  1e  //  получение координат курсора
	jmp	get_scr			;  21  //  чтение байта с экрана в текущей позиции
	jmp	tape_rd_block_vector	;  24  //  чтение блока с ленты
	jmp	tape_wr_block_vector	;  27  //  запись блока на ленту
	jmp	check_sum		;  2a  //  подсчёт контрольной суммы блока
	jmp	init_video		;  2d  //  инициализация видео
	jmp	get_ram_top		;  30  //  получение верхней границы памяти
	jmp	set_ram_top		;  33  //  установка верхней границы памяти
	jmp	wait_sync		;  36  //  синхронизация с кадровым синхроимпульсом
	ret				;  39
	nop
	nop
	jmp	set_cursor		;  3c  //  установка курсора по координатам
	jmp	synthesizer		;  3f  //  трёхголосый синтезатор
	jmp	set_charset		;  42  //  выбор знакогенератора
	lda	config_rk		;  45  //  чтение конфигурации
	ret

;  =================================================================================================

;  ПЕРЕДАЧА АДРЕСА ВЕРХНЕЙ ГРАНИЦЫ СВОБОДНОЙ ПАМЯТИ  _______________________________________________
;  Выход: HL - адрес границы
get_ram_top:
	lhld	ram_top
	ret

;  УСТАНОВКА АДРЕСА ВЕРХНЕЙ ГРАНИЦЫ СВОБОДНОЙ ПАМЯТИ  ______________________________________________
;  Вход:  HL - адрес границы
set_ram_top:
	shld	ram_top
	ret

;  =================================================================================================

cold_start:
	lxi	sp, stack
	;  все три канала таймера в режим 3
	lxi	h, ADDR_TIMER_CTRL
	mvi	m, 00110110b
	mvi	m, 01110110b
	mvi	m, 10110110b
	;  очистка рабочих ячеек МОНИТОРА
	lxi	h, MONITOR_DATA
	lxi	d, MONITOR_DATA + MONITOR_DATA_SIZE - 17
	mvi	c, 0
	call	directive_f
	call	init_monitor
	;  pad
	ds	MONITOR_WARM_START - $, 0

warm_start:
	;  т.н. теплый старт МОНИТОРА.
	;  для совместимости с программами, которые напрямую переходят
	;  на теплый старт, этот адрес должен быть равен F86C
	.if $ - MONITOR_WARM_START
	.error MONITOR_WARM_START
	.endif

	lxi	sp, stack
	lxi	h, warm_start
	push	h
	mvi	a, 2
	call	set_charset		;  переключение на расширенный знакогенератор
	mvi	a, 4
	call	set_charset		;  переключение на 7-битный ввод и вывод
	call	print			;  промт
	db	"\r\n>>\x1bK", 0
	call	get_str			;  ввод директивы
	rz
	inx	d
	call	get_param		;  получить первый параметр
	push	h
	cnc	get_param		;  получить второй параметр
	push	h
	lxi	h, 0
	cnc	get_param		;  получить третий параметр
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
	;  сюда произойдёт переход, если не нашлось ни одного соответствия
	jmp	extended_directive_handler

;  ВВОД СТРОКИ СИМВОЛОВ ВО ВНУТРЕННИЙ БУФЕР  _______________________________________________________
;  Вводим максимум 31 символа с клавиатуры в специальный буфер
;  Особо обрабатываемые клавиши:
;      [<-] и [ЗБ] - удаление последнего символа
;              [.] - Выход на промт
;             [ВК] - успешный возврат из п/п
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

;  ПОЛУЧЕНИЕ ПАРАМЕТРА ИЗ ВВЕДЕННОЙ СТРОКИ  ________________________________________________________
;  Вход:  DE - адрес буфера, код 0 в строке - конец строки
;  Выход: HL - число
;         флаг CF = 1 - достигнут конец строки
;         в случае ошибки синтаксиса происходит завершение подпрограммы
get_param:
	call	inp_buffer_skip_space
	call	str2hex
	call	inp_buffer_skip_space
	ana	a			;  конец строки?
	stc
	rz				;  да CF = 1
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
	
;  ПРОВЕРКА НА НАЖАТИЕ CTRL+C И ДОСТИЖЕНИЕ КОНЦА БЛОКА  ____________________________________________
;  Вход:  HL - текущий адрес блока
;         DE - конечный адрес блока
;  Действие: 1. нажата CTRL+C   - переход на тёплый старт
;            2. нажата АЛФ      - приостановка вывода
;            3. достигнут конец - выход из родительской подпрограммы
cmp_and_check_ctrl_c:
	call	in_key_vector
	cpi	CHAR_CODE_CTRL_C	;  CTRL+C/F4?
	jz	warm_start
	cpi	CHAR_CODE_ALF		;  АЛФ?
	jz	cmp_and_check_ctrl_c

;  ВЫХОД ИЗ РОДИТЕЛЬСКОЙ ПОДПРОГРАММЫ, ЕСЛИ ДОСТИГНУТ КОНЕЦ БЛОКА  _________________________________
;  Вход:  HL - текущий адрес блока
;         DE - конечный адрес блока
cmp_and_exit:
	call	cmp_de_hl
	jnz	$+5
	pop	psw			;  удаляем предыдущий адрес возврата
	ret				;  возврат из родительской подпрограммы
	inx	h			;  следующий адрес в блоке
	ret

;  ВЫВОД СЛОВА НА ЭКРАН  ___________________________________________________________________________
;  Вход:  HL - 16-разрядное слово
;  Действие: вывод начинается с новой строки с отступом от края в 4 символа
out_word:
	call	print
	db	"\r\n\x1bK    ", 0
	mov	a, h
	call	out_hex
	mov	a, l
	jmp	out_hex

;  ВЫВОД АДРЕСА НА ЭКРАН  __________________________________________________________________________
;  Вход:  HL - адрес
;  Действие: вывод начинается с новой строки, адрес выводится в формате:
;            "    xxxx: "
out_addr:
	call	out_word
	mvi	a, ':'
	call	out_char_vector
	jmp	out_space

;  ВЫВОД БАЙТА ИЗ ПАМЯТИ НА ЭКРАН В HEX  ___________________________________________________________
;  Вход:  HL - адрес ячейки памяти
out_mem_hex:
	mov	a, m
	call	out_hex
out_space:
	mvi	a, ' '
	jmp	out_char_vector

;  =================================================================================================
;  =========================================================================  ДИРЕКТИВЫ МОНИТОРА  ==

;  ДИРЕКТИВА B  ____________________________________________________________________________________
;  поиска байта в заданной области памяти
;  Вход:  HL - начальный адрес
;         DE - конечный адрес
;         C  - искомый байт
directive_b:
	mov	a, c
	cmp	m
	cz	out_addr
	call	cmp_and_check_ctrl_c
	jmp	directive_b

;  ДИРЕКТИВА W  ____________________________________________________________________________________
;  поиска слова в заданной области памяти
;  Вход:  HL - начальный адрес
;         DE - конечный адрес
;         BC - искомое слово
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

;  ДИРЕКТИВА C  ____________________________________________________________________________________
;  сравнение двух областей памяти
;  Вход:  HL - начальный адрес первой области памяти
;         DE - конечный адрес первой области памяти
;         BC - начальный адрес второй области памяти
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

;  ДИРЕКТИВА D  ____________________________________________________________________________________
;  вывод на экран содержимого области памяти в виде шестнадцатеричного дампа
;  Вход:  HL - начальный адрес
;         DE - конечный адрес
directive_d:
	call	out_addr
directive_d_loop:
	call	out_mem_hex
	call	cmp_and_check_ctrl_c
	mov	a, l
	ani	0Fh
	jz	directive_D
	jmp	directive_D_loop

;  ДИРЕКТИВА L  ____________________________________________________________________________________
;  вывод на экран содержимого области памяти в виде алфавитно-цифровых символов
;  Вход:  HL - начальный адрес
;         DE - конечный адрес
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

;  ДИРЕКТИВА M  ____________________________________________________________________________________
;  просмотр и изменение содержимого одной или нескольких ячеек памяти
;  Вход:  HL - адрес
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

;  ДИРЕКТИВА F  ____________________________________________________________________________________
;  заполнение области памяти кодом
;  Вход:  HL - адрес начала области
;         DE - адрес конца области
;         C  - код
directive_f:
	mov	m, c
	call	cmp_and_exit
	jmp	directive_f

;  ДИРЕКТИВА -  ____________________________________________________________________________________
;  запуск шелла с SD карты
directive_sd_card:
	lxi	d, 007Fh
	mov	h, d
	mov	l, d
	mov	b, d
	mov	c, d
	push	b

;  ДИРЕКТИВА R  ____________________________________________________________________________________
;  чтение блока из внешнего ROM-диска
;  Вход:  HL - начальный адрес ПЗУ
;         DE - конечный адрес ПЗУ
;         BC - адрес назначения
directive_r:
	; режим 0, канал PA на ввод, каналы PB и PC на вывод
	mvi	a, 10010000b
	sta	ADDR_PORT_CTRL
directive_r_loop:
	shld	ADDR_PORT_PB
	lda	ADDR_PORT_PA
	stax	b
	inx	b
	call	cmp_and_exit
	jmp	directive_r_loop

;  ДИРЕКТИВА S  ____________________________________________________________________________________
;  подсчёт контрольной суммы блока
;  Вход:  HL - адрес начала блока
;         DE - адрес конца блока
directive_s:
	call	out_word
	xchg
	call	out_word
	xchg
	call	check_sum
	mov	l, c
	mov	h, b
	jmp	out_word

;  ДИРЕКТИВА T  ____________________________________________________________________________________
;  пересылка блока памяти
;  Вход:  HL - адрес начала блока
;         DE - адрес конца блока
;         BC - адрес назначения
directive_t:
	call	cmp_de_hl
	jc	out_error_txt		;  DE < HL
directive_t_loop:
	mov	a, m
	stax	b
	inx	b
	call	cmp_and_exit
	jmp	directive_t_loop

;  ДИРЕКТИВА G  ____________________________________________________________________________________
;  запуск программы
;  Вход:  HL - адрес запуска
directive_g:
	pchl

;  =================================================================================================
;  ========================================================================  ПОДПРОГРАММЫ ЭКРАНА  ==

;  ВЫВОД СИМВОЛА  __________________________________________________________________________________
;  Вход:  A - код символа
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
	;  проверку на вывод видимого символа делаем в начале, чтобы сэкономить
	;  такты на куче проверок, т.к. вывод обычных символов производится
	;  гораздо чаще, чем вывод управляющих символов
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
	jz	out_char_regular_out	;  режим 7 бит: все коды помещаются в экран как есть
	;  режим 8 бит

	lda	out_char_charset
	cpi	ATTR_CHARSET_G1		;  альтернативный знакогенератор?
	mov	a, b
	jnz	out_char_regular_g0	;  нет

	;  альтернативный знакогенератор
	ana	a
	jm	out_char_regular_out_7F
	;  необходимо переключиться на основной знакогенератор
	mvi	a, ATTR_CHARSET_G0
	jmp	out_char_regular_lbl1

out_char_regular_g0:
	;  основной знакогенератор
	ana	a
	jp	out_char_regular_out	;  никаких действий больше не нужно
	;  необходимо переключиться на альтернативный знакогенератор
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
	call	out_char_code_right	;  курсор вправо
	rnz				;  за экран не вышли, скроллинг не нужен
	;  здесь D = E = 0
	;  устанавливаем курсор на первой позиции последней строки
	mvi	d, SCR_VIDEO_SIZE_Y - 1
	lxi	h, SCREEN_VIDEO + SCR_SIZE_X * (SCR_VIDEO_SIZE_Y - 1)

;  скроллинг экрана
out_char_scroll:
	;  в цикле пересылки данных используется стек, таким образом
	;  записывается два байта за раз, что увеличивает скорость
	push	h
	lxi	h, 0
	dad	sp			;  копируем SP в HL
	shld	tmp_storage		;  и сохраняем SP
	;  адрес источника
	lxi	sp, SCREEN + SCR_SIZE_X * (SCR_PAD_Y + 1)
	;  адрес приёмника
	lxi	h, SCREEN + SCR_SIZE_X * SCR_PAD_Y
	;  счётчик итераций цикла
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
	;  цикл: (34 * 5 + 15) * 78 * 25 / 5 / 2 = 36075 тактов
	lhld	tmp_storage		;  восстанавливаем указатель стека
	sphl
	pop	h
	ret

;  управляющий код: возврат каретки
out_char_code_cr:
	mov	a, l
	sub	e
	mov	l, a
	mvi	e, 0
	rnc
	dcr	h
	ret

;  управляющий код: перевод строки
out_char_code_lf:
	mov	a, d
	cpi	SCR_VIDEO_SIZE_Y - 1
	jnc	out_char_scroll		;  если курсор на последней строке, то скролл
	inr	d			;  курсор сдвигаем вниз
	lxi	b, SCR_SIZE_X
	dad	b
	ret

;  управляющий код: переключение на альтернативный знакогенератор
out_char_code_so:
	mvi	a, ATTR_CHARSET_G1
	sta	out_char_charset
	jmp	out_char_regular

;  управляющий код: возврат на основной знакогенератор
out_char_code_si:
	mvi	a, ATTR_CHARSET_G0
	sta	out_char_charset
	jmp	out_char_regular

;  управляющий код: горизонтальная табуляция
out_char_code_ht:
	mov	a, e
	cma
	ani	07h
	mov	c, a
	mvi	b, 0
	dad	b
	add	e
	mov	e, a

;  управляющий код: курсор вправо
out_char_code_right:
	inx	h
	inr	e
	mov	a, e
	sui	SCR_VIDEO_SIZE_X
	rnz				;  ret if E < SCR_VIDEO_SIZE_X, ZF = 0
	lxi	b, -SCR_VIDEO_SIZE_X
	dad	b			;  правим текущий адрес вывода на экран
	mov	e, a			;  курсор переместился в начало строки

;  управляющий код: курсор вниз
out_char_code_down:
	lxi	b, SCR_SIZE_X
	dad	b
	inr	d
	mov	a, d
	sui	SCR_VIDEO_SIZE_Y
	rnz				;  ret if D < SCR_VIDEO_SIZE_X, ZF = 0
	lxi	b, -(SCR_SIZE_X * SCR_VIDEO_SIZE_Y)
	dad	b
	mov	d, a			;  курсор переместился на первую строку
	;  здесь флаги ZF = 1, CF = 0
	ret

;  управляющий код: курсор влево
out_char_code_left:
	dcx	h
	dcr	e
	rp				;  ret if E >= 0
	mvi	e, SCR_VIDEO_SIZE_X - 1
	lxi	b, SCR_VIDEO_SIZE_X	;  курсор переместился в конец строки
	dad	b

;  управляющий код: курсор вверх
out_char_code_up:
	lxi	b, -SCR_SIZE_X
	dad	b
	dcr	d
	rp				;  ret if D >= 0
	mvi	d, SCR_VIDEO_SIZE_Y - 1	;  курсор переместился на последнюю строку
	lxi	b, SCR_SIZE_X * SCR_VIDEO_SIZE_Y
	dad	b
	ret
	
;  управляющий код: очистка экрана
out_char_esc_e:
out_char_code_cls:
	xra	a
	sta	out_char_charset
	mov	l, a
	mov	h, a
	mov	e, a
	mov	d, a
	dad	sp			;  копируем SP в HL
	lxi	sp, SCREEN + SCR_ARRAY	;  адрес последнего байта экрана + 1
	mvi	a, SCR_ARRAY / 10 / 2	;  через стек заносим 20 байт за итерацию
					;  8-битного регистра хватает для счётчика
out_char_code_cls_loop:
	.rept 10
	push	d			; (11)
	.endm
	dcr	a			; (5)
	jnz	out_char_code_cls_loop	; (10)
	;  цикл: (11 * 10 + 15) * 78 * 30 / 10 / 2 = 14625 тактов
	sphl

;  управляющий код: курсор в начало экрана
out_char_esc_h:
out_char_code_ff:
	lxi	d, 0
	lxi	h, SCREEN_VIDEO
	ret

;  управляющий код: звуковой сигнал
out_char_code_bel:
	lxi	h, out_char_beep
	call	synthesizer3
	jmp	out_char_do_nothing

;  управляющий код: начало ESC-последовательности, меняется режим вывода
out_char_code_esc:
	lhld	out_char_vector + 1
	shld	out_char_addr_storage
	lxi	h, out_char_escape
	shld	out_char_vector + 1	;  следующий шаг - обработчик
	jmp	out_char_do_nothing

;  обработка ESC-последовательности: код
out_char_escape:
	;  для комбинации ESC+Y проверку делаем в первую очередь,
	;  как потенциально самую часто используемую для меньших задержек
	cpi	'Y'
	jz	out_char_esc_y		;  ESC+Y
	;  для остальных кодов используем таблицу переходов
	;  допустимыми являются коды: A - K
	push	b
	push	d
	push	h
	push	psw
	lhld	out_char_addr_storage
	shld	out_char_vector + 1	;  в исходное
	;  проверка диапазона от 'A' до 'K'
	sui	'A'
	jc	pop_all_and_ret		;  ошибочный код
	cpi	'K' - '7' + 1
	jnc	pop_all_and_ret		;  ошибочный код
	;  выбор адреса перехода на обработчик ESC-последовательности
	;  индекс в регистре A
	lxi	h, out_char_esc_table	;  база
	add	a			;  размер адреса = слово
	add	l
	mov	l, a			;  получили адрес ячейки
	mov	c, m
	inx	h
	mov	b, m			;  BC = адрес обработчика
	;  загружаем все необходимые данные
	lxi	h, out_char_exit
	push	h
	lhld	cursor_pos
	xchg				;  D = posY, E = posX
	lhld	cursor_addr		;  HL = scr addr
	xra	a			;  A = 0
	;  переход по адресу через стек
	push	b
	ret

out_char_esc_table:
	.if msb(out_char_esc_table_end - 1) - msb($)
	.error out_char_esc_table
	.endif
	;  управляющие коды терминала VT52
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
	pop	b			;  удаляем адрес возврата из стека
	jmp	pop_all_and_ret


;  ESC+A: курсор вверх, останавливается в верхней позиции
out_char_esc_a:
	cmp	d			;  A = 0
	rz
	lxi	b, -SCR_SIZE_X
	dad	b
	dcr	d
	ret

;  ESC+B: курсор вниз, останавливается в нижней позиции
out_char_esc_b:
	mvi	a, SCR_VIDEO_SIZE_Y - 1
	cmp	d
	rz
	lxi	b, SCR_SIZE_X
	dad	b
	inr	d
	ret

;  ESC+C: курсор вправо, останавливается в правой позиции
out_char_esc_c:
	mvi	a, SCR_VIDEO_SIZE_X - 1
	cmp	e
	rz
	inx	h
	inr	e
	ret

;  ESC+D: курсор влево, останавливается в левой позиции
out_char_esc_d:
	cmp	e			;  A = 0
	rz
	dcx	h
	dcr	e
	ret

;  ESC+I: курсор вверх, если курсор уже был на самой верхней позиции,
;  производится прокрутка экрана вниз
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
	dad	sp			;  копируем SP в HL
	xchg				;  и сохраняем HL в DE
	;  адрес приёмника
	lxi	sp, SCREEN + SCR_SIZE_X * (SCR_PAD_Y + SCR_VIDEO_SIZE_Y)
	;  адрес источника
	lxi	h, SCREEN + SCR_SIZE_X * (SCR_PAD_Y + SCR_VIDEO_SIZE_Y - 1)
	;  счётчик итераций цикла
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

;  ESC+J: очистка экрана от текущей позиции, положение курсора не меняется
out_char_esc_j:
	mov	m, a			;  первым делом очищаем тут, в случае нечётного адреса
					;  дальнейший код его пропустит, для чётного не имеет смысла
	lxi	b, -SCREEN		;  вычитание заменяется на сложение с отриц. числом
	dad	b			;  HL = адрес текущей позиции курсора от нуля
	mov	e, l			;  младшие 4 бита будут ещё нужны
	dad	h
	dad	h
	dad	h
	dad	h			;  сдвиг HL влево на 4 разряда, H = адрес / 16
	mov	b, a			;  A = 0
	mov	c, a			;  A = 0
	mvi	a, SCR_ARRAY / 16	;  сколько итераций для всего экрана
	sub	h			;  сколько итераций для части экрана
	mov	h, b			;  B = 0
	mov	l, b			;  B = 0
	dad	sp			;  копируем SP в HL
	lxi	sp, SCREEN + SCR_ARRAY	;  адрес последнего байта экрана + 1
out_char_esc_j_loop:
	.rept 8
	push	b
	.endm
	dcr	a
	jnz	out_char_esc_j_loop
	mov	a, e			;  какие-то остатки
	rrc				;  уполовиниваем
	ani	7			;  остаток от деления на 8
	jz	out_char_esc_j_lbl	;  а не осталось нихера
	push	b
	dcr	a
	jnz	$-2
out_char_esc_j_lbl:
	sphl
	;  восстановление сброса атрибутов
	lxi	h, SCREEN + SCR_ARRAY - (SCR_SIZE_X - SCR_VIDEO_SIZE_X - SCR_PAD_X)
	lxi	b, -SCR_SIZE_X
	mvi	a, SCR_SIZE_Y + 1
	mvi	e, ATTR_RESET
	sub	d			;  сколько
	rar
	jnc	$+5
	mov	m, e
	dad	b
	mov	m, e
	dad	b
	dcr	a
	jnz	$-5
	jmp	out_char_do_nothing

;  ESC+K: очистка строки от текущей позиции, положение курсора не меняется
out_char_esc_k:
	mov	c, a			;  A = 0
	mvi	a, SCR_VIDEO_SIZE_X
	sub	e			;  сколько
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

;  ESC+Y: установка курсора по кооодинатам
out_char_esc_y:
	;  пока не получим все параметры на экране ничего меняться не будет
	push	h
	lxi	h, out_char_esc_y_p1
	shld	out_char_vector + 1	;  следующий шаг - получение параметров
	pop	h
	ret

;  ESC+Y: первый параметр - номер строки
out_char_esc_y_p1:
	;  сохраняем параметр, обработка будет происходить, на последнем шаге
	sta	out_char_param
	push	h
	lxi	h, out_char_esc_y_p2
	shld	out_char_vector + 1	;  следующий шаг
	pop	h
	ret

;  ESC+Y: второй параметр - номер позиции
out_char_esc_y_p2:
	push	b
	push	d
	push	h
	push	psw
	lhld	out_char_addr_storage
	shld	out_char_vector + 1	;  в исходное
	sui	' '			;  приводим параметр к нужному виду
	mov	l, a
	lda	out_char_param		;  теперь первый параметр
	sui	' '			;  приводим параметр к нужному виду
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
	;  вычисляется адрес экрана по координатам
	;  HL = POS_Y * SCR_SIZE_X + POS_X + SCREEN_VIDEO
	;  здесь: A = D = POS_Y, E = POS_X
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
	;  установка курсора в новую позицию
	lxi	h, ADDR_CRT_CTRL	;  HL = адрес регистра команд CRT
	mvi	m, 80h			;  команда "загрузка курсора"
	dcx	h			;  HL = адрес регистра параметров CRT
	mov	m, e			;  номер знака (X)
	mov	m, d			;  номер знакоряда (Y)
	;
pop_all_and_ret:
	pop	psw
pop_hdb_and_ret:
	pop	h
pop_db_and_ret:
	pop	d
	pop	b
	ret

;  ВЫВОД СИМВОЛА  __________________________________________________________________________________
;  Вход:  C - код символа
out_char_c:
	push	psw
	mov	a, c
	call	out_char_vector
	pop	psw
	ret

;  ВЫВОД СТРОКИ СИМВОЛОВ  __________________________________________________________________________
;  Вход:  HL - адрес строки, строка оканчивается нулевым символом
out_str:
	mov	a, m
	inx	h
	ana	a
	rz
	call	out_char_vector
	jmp	out_str

;  ВЫВОД СТРОКИ СИМВОЛОВ  __________________________________________________________________________
;  Вход: строка символов должна следовать сразу за вызовом этой функции,
;        строка оканчивается нулевым символом
;  Примечание: все регистры сохраняются, кроме A
print:
	xthl
	call	out_str
	xthl
	ret

;  ВЫВОД БАЙТА В HEX-КОДЕ  _________________________________________________________________________
;  Вход:  A - байт
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

;  ЗАПРОС ПОЛОЖЕНИЯ КУРСОРА  _______________________________________________________________________
;  Выход: H - номер строки
;         L - номер позиции
;  Замечание: функция возвращает положение курсора от начала видимой области экрана, это поведение
;         отличается от принятой в РК. т.к. импульсы гашения в РК формируются в видеопамяти, на мой
;         взгляд, сместить точку отсчёта в область формирования импульсов гашения -- это было глупое
;         решение разработчиков РК и из-за этого нулевой отсчёт у них стал начинаться не с нуля.
;         поскольку в эту область всё равно ничего писать нельзя, я буду отсчитывать экранные
;         координаты от видимой области, как это сделано во всех нормальных компьютерах. конечно,
;         это приведет к несовместимости с некоторыми программами, но лучше исправить программу, чем
;         иметь кривое решение.
;         пс: ESC+Y+posY+posX в родной п/п РК out_char принимает координаты
;         как положено - от нуля, вот такой вот парадокс.
get_cursor:
	lhld	cursor_pos
	ret

;  УСТАНОВКА ПОЛОЖЕНИЯ КУРСОРА  ____________________________________________________________________
;  Вход:  H - номер строки (Y)
;         L - номер позиции (X)
;  Примечание: отсчёт от нуля
set_cursor:
	push	b
	push	d
	push	h
	push	psw
	jmp	out_char_set_cursor

;  ЗАПРОС БАЙТА ИЗ ЭКРАННОГО БУФЕРА  _______________________________________________________________
;  Выход: A - код из буфера
get_scr:
	push	h
	lhld	cursor_addr
	mov	a, m
	pop	h
	ret

;  =================================================================================================
;  ====================================================================  ПОДПРОГРАММЫ КЛАВИАТУРЫ  ==

;  ОПРОС СОСТОЯНИЯ КЛАВИАТУРЫ  _____________________________________________________________________
;  Выход: A = 00 - не нажата
;         A = FF - нажата
;  Примечание: кроме проверки регистра A можно использовать проверку флага ZF
;         флаг ZF = 1 - не нажата
;         флаг ZF = 0 - нажата
kbd_state:
	lda	kbd_buffer_full
	ana	a
	rnz				;  в буфере есть непрочитанный код
	push	h
	call	in_key_vector
	lhld	kbd_key_status
	cmp	l
	jz	kbd_state_hold
	mov	l, a
kbd_state_released:
	mvi	h, 1			;  задержка выдачи первого символа
	lda	kbd_delay_second_const	;  задержка автоповтора для второго символа
	sta	kbd_delay
	xra	a			;  CF = 0, код выхода: не нажата
kbd_state_rst:
	lda	antibounce_const	;  восстановить счётчик антидребезга
	sta	antibounce
	sbb	a			;  CF = 0 => A = 0, CF = 1 => A = FF
	shld	kbd_key_status
kbd_state_exit:
	pop	h
	ret

kbd_state_hold:
	inr	a			;  in_key == FF ?
	jz	kbd_state_exit		;  ничего не нажато
	inr	a			;  in_key == FE ?
	jz	kbd_state_rus		;  нажата [РУС/ЛАТ]
	lda	antibounce
	dcr	a
	jnz	kbd_state_rst + 3	;  цикл антидребезга
	dcr	h			;  переменная задержки выдачи символа
	jnz	kbd_state_rst		;  ещё не время
	;  задержка прошла
	lda	kbd_delay
	mov	h, a			;  рабочая переменная
	lda	kbd_delay_regular_const	;  задержка автоповтора для остальных символов
	sta	kbd_delay
kbd_state_pressed:
	stc				;  CF = 1
	sbb	a			;  A = FF - код выхода: нажата
	sta	kbd_buffer_full
	jmp	kbd_state_rst

kbd_state_rus:
	;  результат зависит от текущего знакогенератора:
	;  для стандартного з/г (0, только заглавные латинские и русские буквы):
	;    -  стандартное поведение: клавиша [РУС/ЛАТ] не возвращает ничего
	;  для расширенного з/г (2, заглавные и строчные буквы обоих алфавитов):
	;    -  клавиша [РУС/ЛАТ] возвращает код 0E при переключении на русскую
	;        раскладку и код 0F при переключении на латинскую раскладку
	call	in_key_vector
	cpi	CHAR_CODE_ALF
	jz	kbd_state_rus		;  ждём отпускания клавиши [РУС/ЛАТ]
	lda	kbd_rus
	cma
	sta	kbd_rus
	mov	h, a			;  запомнить состояние kbd_rus
	mvi	l, 0FFh			;  код "ничего не нажато"
	lda	ADDR_KBD_PC		;  KBD_PC - для получения режима з/г
	rar				;  проверить 0-й разряд
	jnc	kbd_state_released	;  стандартное поведение
	;  8-битный режим клавиатуры только для з/г в режиме 2
	lda	kbd_8bit_mode
	ana	a
	jnz	kbd_state_8bit
	;  7-битный режим клавиатуры
	mvi	a, CHAR_CODE_SI		;  A = 0F - код перехода на латинскую раскладку
	add	h			;  H = 0/-1
	mov	l, a			;  L = 0F/0E
	mvi	h, 1
	jmp	kbd_state_pressed

kbd_state_8bit:
	mvi	a, 80h
	ana	h
	sta	kbd_8bit_rus
	jmp	kbd_state_released

;  ВВОД СИМВОЛА С КЛАВИАТУРЫ  ______________________________________________________________________
;  Выход: A - введенный код
in_char:
	call	kbd_state_vector
	jz	in_char
	push	h
	lxi	h, in_char_lat_beep	;  параметры сигнала для латинской раскладки
	lda	kbd_rus
	ana	a
	jz	$+6
	lxi	h, in_char_rus_beep	;  параметры сигнала для русской раскладки
	xra	a
	sta	kbd_buffer_full		;  сброс флага "буфер полон"
	cmp	m
	cnz	synthesizer3
	pop	h
	lda	kbd_8bit_rus
	ral				;  признак русской раскладки находится в 7-м бите
	lda	kbd_key_status
	rnc
	cpi	20h			;  управляющие символы не должны преобразовываться
	rc
	ori	80h
	ret

;  ДРАЙВЕР КЛАВИАТУРЫ РАДИО-86РК  __________________________________________________________________
;  Выход: A = FF - не нажата
;         A = FE - РУС/ЛАТ
;         A - код клавиши
;  Описание: подпрограмма возвращает код нажатой клавиши без ожидания. для максимальной скорости
;         обработки (минимальных задержек) в алгоритме отсутвует цикл антидребезга, который имеется
;         в оригинальном алгоритме. на мой взгляд, использование цикла антидребезга в подпрограмме
;         in_key является ошибкой, т.к. по сути задержки, которые применяются в подпрограмме
;         kbd_state, а через неё и в подпрограмме in_char, и являются циклами антидребезга. таким
;         образом, подпрограмма in_key создаёт минимальные издержки при опросе клавиатуры, что
;         позволяет использовать её в играх, без прямого опроса матрицы.

in_key:
	lda	ADDR_KBD_PC
	ani	KBD_RUS_FLAG
	mvi	a, CHAR_CODE_ALF
	rz				;  результат: FE, нажата [РУС/ЛАТ]
	lda	kbd_rus
	ani	1
	ori	3 << 1			;  3-й бит порта C
	sta	ADDR_KBD_CTRL		;  светодиод "РУС"
	xra	a
	sta	ADDR_KBD_PA
	lda	ADDR_KBD_PB
	cpi	0FFh
	rz				;  результат: ничего не нажато, A = FF
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
	;  A = FF, бегающий ноль
	;  B = номер столбца
	;  C = const 1F
	;  здесь флаг CF должен быть равен 0
in_key_loop:
	ral
	rnc				;  результат: не нажато, A = FF
	stax	d
	inr	b
	inr	m
	jz	in_key_loop

	;  находим линию и подсчитываем скан-код
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
	;  подсчёт окончен
	lxi	d, 205Fh
	;  D = const 20 - код пробела
	;  E = const 5F
	mov	a, b
	cmp	e			;  скан-код 5F - это пробел
	mov	a, d			;  A = 20
	rz				;  результат: пробел
	mov	a, b
	cpi	30h			;  код символа '0'
	rz				;  результат: '0', не модифицируется шифтом

	lxi	h, ADDR_KBD_PC
	jc	in_key_20_2F		;  линии опроса A0-A1
	;  линии опроса A2-A7
	cpi	40h
	jc	in_key_31_3F

	;  коды 40-7Fh
	mov	a, m			;  A = KBD_PC
	ani	KBD_CTRL_FLAG		;  KBD_PC & KBD_CTRL_FLAG
	jnz	in_key_40_7F		;  no ctrl
	;  ctrl
	mov	a, b
	ana	c
	ret				;  результат: коды 00-1F

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
	rnz				;  результат: буквенные клавиши без шифта
	xra	d			;  4x => 6x, 6x => 4x
	ret				;  результат: буквенные клавиши с шифтом

in_key_31_3F:
	;  коды 31h-3Fh
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
	xri	10h			;  для кодов xC-xF инвертировать 4-й бит:
					;  2x => 3x, 3x => 2x
	ret				;  результат: коды 20-3F

in_key_20_2F:
	;  линии опроса A0-A1
	;  скан-коды 20-2F, конвертация сканкода через таблицу
	lxi	b, kbd_table - 20h
	add	c
	mov	c, a
	ldax	b
	cpi	CHAR_CODE_BACKSPACE
	rnz				;  результат: коды управляющих клавиш
	mov	a, m			;  A = KBD_PC
	ana	d			;  KBD_PC & KBD_SHIFT_FLAG
	mvi	a, CHAR_CODE_BACKSPACE
	rnz				;  результат: Забой
	mov	a, e
	ret				;  результат: 5F - символ подчёркивания

kbd_table:
	;  таблица должна целиком умещаться в 256-байтовом сегменте
	db	0Ch, 1Fh, 1Bh, 00h, 01h, 02h, 03h, 04h
	db	09h, 0Ah, 0Dh, 7Fh, 08h, 19h, 18h, 1Ah
kbd_table_end:

;  =================================================================================================
;  ========================================================================  ПРОЧИЕ ПОДПРОГРАММЫ  ==

;  ПРЕОБРАЗОВАНИЕ HEX-СТРОКИ В ЧИСЛО  ______________________________________________________________
;  Вход:  DE - адрес строки
;  Выход: HL - результат
;         DE - адрес, где остановилась обработка
;         флаг ZF = 1 и CF = 0 - достигнут конец строки
;         флаг CF = 1 - встретился символ, не соответствующий hex-цифре
;  Примечание: проверка на переполнение не производится, разряды будут сдвигаться влево, пока в
;         строке встречаются HEX-цифры, например, строка "123ACF" даст результат 3ACF
str2hex:
	xra	a
	mov	h, a		;  HL = результат
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

;  ПЕРЕХОД ПО АДРЕСУ ИЗ ТАБЛИЦЫ ПЕРЕХОДОВ  _________________________________________________________
;  Вход:  A - входное значения для поиска, должно быть отличное от нуля
;         таблица переходов должна следовать сразу за вызовом этой функции
;  Формат таблицы:
;         DB  XX, где XX - байт соответствия
;         DW  ADDR, где ADDR - адрес перехода при совпадении
;         нулевой байт XX - завершение таблицы 
;  Описание: при совпадении входного байта с одним из байтов соответствия
;         произойдет переход по адресу ADDR, если соответствия байта в таблице
;         не обнаружилось, произойдет переход по адресу, следующему за таблицей.
;  Примечание: все регистры сохраняются
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
	jnz	branch_loop		;  (10) / 50 тактов за итерацию
	;  найдено совпадение
	mov	a, m			;  (7)
	inx	h			;  (5)
	mov	h, m			;  (7)
	mov	l, a			;  (5)
branch_exit:
	mov	a, c			;  (5)
	pop	b			;  (10)
	xthl				;  (18)
	ret				;  (10)
	;  161 такт весь код

;  СРАВНЕНИЕ ДВУХ 16-РАЗРЯДНЫХ ЧИСЕЛ  ______________________________________________________________
;  Вход:  DE - первое слово
;         HL - второе слово
;  Выход: флаг ZF = 1: DE == HL
;         флаг ZF = 0 и CF = 1: DE < HL
;         флаг ZF = 0 и CF = 0: DE > HL
cmp_de_hl:
	mov	a, d
	cmp	h
	rnz
	mov	a, e
	cmp	l
	ret

;  ПОДСЧЁТ КОНТРОЛЬНОЙ СУММЫ БЛОКА  ________________________________________________________________
;  Вход:  HL - адрес начала блока
;         DE - адрес конца блока
;  Выход: BC - контрольная сумма
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

;  СИНХРОНИЗАЦИЯ С КАДРОВЫМ СИНХРОИМПУЛЬСОМ  _______________________________________________________
wait_sync:
	lda	ADDR_CRT_CTRL		;  сброс регистра флагов
	lda	ADDR_CRT_CTRL		;  чтение слова состояния
	ani	20h			;  нужен флаг IR - запрос прерывания
	jz	$-5			;  ждём установленного IR
	ret

;  SYNTHESIZER  ____________________________________________________________________________________
;  Запуск генератора в одном канале
;  Вход:  A  - номер канала [0, 1, 2]
;         H  - задержка в мс, если 0 - без задержки
;         DE - коэффициент деления
synthesizer:
	cpi	3
	rnc
	mov	l, a
	push	h
	lxi	h, ADDR_TIMER
	add	l
	mov	l, a
	mov	m, e			;  младший байт
	mov	m, d			;  старший байт
	pop	h
	inr	h
	dcr	h
	rz				;  без задержек
	;  1 такт(мкс) = 1000 / CPU_CLOCK(кГц)
	;  количество тактов для 1мкс = CPU_CLOCK(кГц) / 1000
	;  для задержки в 1мс количество итераций = 1000 * (к.т.1мкс) / 20
synthesizer_delay:
	mvi	a, (1000 * CPU_CLOCK / 1000) / 20
	mov	a, a			;  (5)
	dcr	a			;  (5)
	jnz	$-2			;  (10)
	dcr	h
	jnz	synthesizer_delay
	mov	a, l			;  сдвиг 1 и 0 разряда в 7 и 6 разряды
	rar
	rar
	rar
	ori	00110110b		;  D7:D6 - канал таймера
	sta	ADDR_TIMER_CTRL		;  выключить канал
	ret

;  SYNTHESIZER3  ___________________________________________________________________________________
;  Запуск генератора сразу в трёх каналах
;  Вход:  HL - адрес структуры с данными
;              формат структуры:
;                  DB	задержка в мс (обязательно)
;                  DW	коэффициент деления
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

;  ВЫБОР ЗНАКОГЕНЕРАТОРА / РЕЖИМЫ КЛАВИАТУРЫ И ДИСПЛЕЯ  ____________________________________________
;  Вход:  A - номер знакогенератора
;         A = 0 - стандартный з/г: только заглавные латинские и русские буквы
;         A = 1 - графический з/г Апогея
;         A = 2 - расширенный з/г: заглавные и строчные буквы обоих алфавитов
;         A = 3 - клавиатура в 8-битном режиме, дисплей в 8-битном режиме
;         A = 4 - клавиатура в 7-битном режиме, дисплей в 7-битном режиме
;         A = 5 - клавиатура в 8-битном, дисплей в 7-битном режиме
;         A = 6 - клавиатура в 7-битном режиме, дисплей в 8-битном режиме
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
	;  бит 0 - режим клавиатуры: 7 бит (0) / 8 бит (1)
	;  бит 1 - режим дисплея: 7 бит (0) / 8 бит (1)
	rar
	push	psw
	sbb	a
	sta	kbd_8bit_mode
	xra	a
	sta	kbd_rus			;  необходимо сбросить флаг русской раскладки, на всякий
	sta	kbd_8bit_rus		;  и это тоже
	pop	psw
	rar
	sbb	a
	sta	out_char_8bit_mode
	ret

;  ИНИЦИАЛИЗАЦИЯ МОНИТОРА ПРИ ХОЛОДНОМ СТАРТЕ  _____________________________________________________
init_monitor:
	call	init_video	;  возможно не требуется,
				;  надо подсчитать количество времени, которое
				;  потребуется для вывода заголовка
	;  первым делом необходимо считать значения с порта PC клавиатуры.
	;  порт PC на ввод, для чтения конфигурации
	;  порт PC содержит конфигурацию компьютера:
	;  PC0 = 0 - знакогенератор хранится в ROM
	;  PC0 = 1 - знакогенератор хранится в RAM
	;  PC2 = 0 - шрифт имеет ширину 6 пикселов
	;  PC2 = 1 - шрифт имеет ширину 8 пикселов
	lxi	h, ADDR_KBD_CTRL
	mvi	m, 10001011b
	lda	ADDR_KBD_PC
	sta	config_rk
	;  порт клавиатуры в режиме 0
	;  канал A на вывод, канал B на ввод,
	;  линии PC0-PC3 на вывод, PC4-PC7 на ввод
	mvi	m, 10001010b
	;  установка бита порта PC выбора ширины символа согласно конфигурации
	ani	CFG_RK_FONT_8BIT
	sta	ADDR_KBD_PC
	;  копирование части кода из ROM в RAM
	lxi	h, rom_data			;  откуда
	lxi	d, rom_data_end - 1		;  докуда
	lxi	b, ram_data			;  куда
	call	directive_t_loop
	;  заголовок
	call	print
	db	CHAR_CODE_CLS, ATTR_COLOR_YELLOW, "\x0eradio-86rk/60K\x0f", ATTR_COLOR_WHITE, 0

;  ИНИЦИАЛИЗАЦИЯ КОНТРОЛЛЕРОВ  _________________________________________________________________
init_video:
	push	h
	lxi	h, ADDR_CRT_CTRL
	mvi	m, 0			;  команда "сброс"
	dcx	h

	;  компоновка кадра: загружаются 4 байта в регистр параметров
	;  1. SHHHHHHH
	;     S        - знакоряды:
	;                0 - нормальные знакоряды
	;                1 - чередующиеся знакоряды
	;      HHHHHHH - число знаков в знакоряду минус один (от 1 до 80)
	mvi	m, (SCR_SIZE_X - 1) | (CRT_SPACED_ROWS << 7)

	;  2. VVRRRRRR
	;     VV       - длительность обратного хода кадровой развертки
	;                00 - 1 знакоряд
	;                01 - 2 знакоряда
	;                10 - 3 знакоряда
	;                11 - 4 знакоряда
	;       RRRRRR - число знакорядов в кадре минус один (от 1 до 64):
	mvi	m, (SCR_SIZE_Y - 1) | ((CRT_VERT_ROW_COUNT - 1) << 6)

	;  3. UUUULLLL
	;     UUUU     - номер строки подчеркивания в знакоряду, старший бит
	;                определяет гашение верхней и нижней строк растра в
	;                знакоряду, если UUUU = 1xxx, то строки гасятся
	;         LLLL - число строк растра в знакоряду (от 1 до 16)
	mvi	m, ((CRT_UNDERLINE - 1) << 4) | (CRT_LINES_PER_ROW - 1)

	;  4. MFCCZZZZ
	;     M        - режим счетчика строк:
	;                0 - не сдвинуто
	;                1 - смещено на 1 счет
	;                подробно на стр. 125
	;      F       - режим атрибутов поля:
	;                0 - прозрачный
	;                1 - непрозрачный
	;       CC     - тип курсора:
	;                00 - мерцающий негативный видеоблок
	;                01 - мерцающие подчеркивание
	;                10 - немерцающий негативный видеоблок
	;                11 - немерцающее подчеркивание
	;         ZZZZ - число знаков при обратном ходе строчной
	;                развертки (2, 4, 6, ..., 32): (3 + 1) * 2 = 8
	lda	ADDR_KBD_PC
	ani	CFG_RK_FONT_8BIT
	mvi	l, CRT_ZZZZ6 | (CRT_LINE_OFFSET << 7) | (CRT_NON_TRANSP_ATTR << 6)
	jz	$+5
	mvi	l, CRT_ZZZZ8 | (CRT_LINE_OFFSET << 7) | (CRT_NON_TRANSP_ATTR << 6)
	lda	cursor_view
	ora	l
	mvi	l, low (ADDR_CRT_PARAM)
	mov	m, a
	inx	h			;  HL = адрес регистра команд CRT

	;  001SSSBB - команда "начало воспроизведения"
	;     SSS   - интервал между пакетами, число синхроимпульсов
	;             знака между пакетными запросами ПДП:
	;             000 = 0
	;             001 = 7
	;             010 = 15
	;             011 = 23
	;             100 = 31
	;             101 = 39
	;             110 = 47
	;             111 = 55
	;        BB - число запросов ПДП в пакете:
	;             00 = 1
	;             01 = 2
	;             10 = 4
	;             11 = 8
	mvi	m, 00100000b | (CRT_BURST_SPACE_CODE << 2) | CRT_BURST_COUNT_CODE
	call	wait_sync

	lxi	h, ADDR_DMA + 8		;  адрес регистра режимов ПДП
	mvi	m, 10000000b		;  запрет ПДП
	mvi	l, low (ADDR_DMA + 04h)	;  адрес регистра адреса канала 2 ПДП
	mvi	m, low (SCREEN)		;  младший адрес памяти
	mvi	m, high (SCREEN)	;  старший адрес памяти
	inr	l			;  адрес регистра количества циклов ПДП канала 2

	;  16 бит = RWCCCCCC CCCCCCCC
	;  CCCCCC CCCCCCCC - количество циклов
	;  RW = 00 - цикл проверки ПД
	;  RW = 01 - цикл записи ПД
	;  RW = 10 - цикл чтения ПД
	;  RW = 11 - запрещенная комбинация
	;  младший байт счётчика циклов (биты C7-C0)
	mvi	m, low (SCR_ARRAY - 1)
	;  старший байт счётчика циклов (биты C13-C8)
	mvi	m, high (SCR_ARRAY - 1) | (01b << 6)
	mvi	l, low (ADDR_DMA + 08h)	;  адрес регистра режимов ПДП

	;  D7 [AL]  = 1 - автозагрузка
	;  D6 [TCS] = 0 - КС-стоп
	;  D5 [EW]  = 1 - удлиненная запись
	;  D4 [RP]  = 0 - циклический сдвиг
	;  D3 [EN3] = 0 - разрешение канала 3
	;  D2 [EN2] = 1 - разрешение канала 2
	;  D1 [EN1] = 0 - разрешение канала 1
	;  D0 [EN0] = 0 - разрешение канала 0
	mvi	m, 10100100b		;  установка режима

	;  здесь начинаются циклы ПДП
	pop	h
	ret

;  =================================================================================================
;  =====================================================================================  ДАННЫЕ  ==

;  блок кода, который переносится в оперативную память  ____________________________________________
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
	syn_note	4, 2, 4		;  in_char_lat_beep: латинская раскладка
					;  "ми" второй октавы, 4 мс
	syn_note	4, 2, 7		;  in_char_rus_beep: русская раскладка
					;  "соль" второй октавы, 4 мс
	syn_note	50, 1, 9	;  out_char_beep: "ля" первой октавы, 50 мс
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
;  рабочие переменные МОНИТОРА в оперативной памяти

	org	MONITOR_DATA

;  область ОЗУ в которую копируются данные из ПЗУ  _________________________________________________
ram_data:
;  вектора подпрограмм МОНИТОРА
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
ram_top:				;  верхняя граница памяти [get_ram_top] [set_ram_top]
	ds	2
in_char_lat_beep:			;  сигнал клавиши для латинской раскладки [in_char]
	ds	3
in_char_rus_beep:			;  сигнал клавиши для русской раскладки [in_char]
	ds	3
out_char_beep:				;  код 7 [out_char]
	ds	3
antibounce:				;  счётчик антидребезга [kbd_state]
	ds	1
antibounce_const:			;  [kbd_state]
	ds	1
kbd_delay_second_const:			;  [kbd_state]
	ds	1
kbd_delay_regular_const:		;  [kbd_state]
	ds	1
kbd_key_status:				;  код клавиши и переменная задержки [kbd_state]
	ds	2
cursor_view:				;  вид курсора (видеоблок/подчеркивание) [init_video]
	ds	1			;  допустимые значения: 00h, 10h, 20h, 30h
;  end ram_data
;  _________________________________________________________________________________________________
cursor_addr:				;  текущее значение адреса курсора [out_char]
	ds	2
cursor_pos:				;  текущее положение курсора [out_char]
	ds	2
out_char_charset:			;  код для переключения знакогенератора [out_char]
	ds	1
out_char_param:				;  рабочая ячейка ESC+Y [out_char]
	ds	1
out_char_8bit_mode:			;  8-битный режим для вывода символа [out_char]
	ds	1
kbd_8bit_mode:				;  8-битный режим для клавиатуры [in_char]
	ds	1
kbd_8bit_rus:				;  флаг русской раскладки в режим 8 бит [in_char]
	ds	1
kbd_buffer_full:			;  флаг наличия кода в буфере клавиатуры [kbd_state]
	ds	1
kbd_delay:				;  константа задержки выдачи кода [kbd_state]
	ds	1
kbd_rus:				;  флаг русской раскладки клавиатуры [kbd_state] [in_key]
	ds	1
out_char_addr_storage:			;  сохранение оригинального адреса вектора out_char
	ds	2
tmp_storage:				;  переменная для временного хранения
	ds	2
inp_buffer:				;  буфер введенной строки
	ds	INP_BUFFER_SIZE
inp_buffer_end:

config_rk:				;  биты конфигурации, выставленные джамперами
	ds	1

	org	MONITOR_DATA + MONITOR_DATA_SIZE
stack:

;  =================================================================================================
;  end of file  ====================================================================================
