;数据段
Data SEGMENT
     count dw 0				;存放素数的个数
     sum dw 0				;存放素数的和
     sushu db 100 dup(?)		;存放素数

     ;0dh,0ah是回车、换行符
     msgsushu db 'The Primes Within 100 Are :','$'			;显示素数的提示信息
     msgcount db 0dh,0ah,'The Count Of These Primes :',0dh,0ah,'$';显示素数个数的提示信息
     msgsum db 0dh,0ah,'The Sum Of These Primes Are :',0dh,0ah,'$';显示素数和的提示信息
Data ENDS



;代码段
code SEGMENT
     assume cs:code, ds:Data

;主程序入口
main proc
     call Calculate		;将100以内素数的个数存入COUNT单元中，素数的和存入SUM单元中，并将素数存入内存自SUSHU开始的单元中

     mov dx,offset msgsushu	;显示素数的提示信息
     mov ah,9			;显示字符串  ds:dx = 串地址
     int 21h
     call showsushu		;显示素数
     
     mov dx,offset msgcount	;显示素数个数的提示信息
     mov ah,9
     int 21h
     call showcount		;显示素数个数
     
     mov cx,3
     mov dx,offset msgsum	;显示素数和的提示信息
     mov ah,9
     int 21h
sump:
     call showsum
     mov dl,20h		;加一个空格，便于区分
     mov ah,2
     int 21h
     call delay		;延时子程序
     loop sump		;显示3次
     
     call exit
     MAIN endp



;核心子程序 Calculate
;注意标号的特殊性
Calculate proc near
     mov ax,Data		;使ds得数据段字符串首地址
     mov ds,ax
     mov di,offset sushu   ;素数偏移地址给di
     mov bh,0		;为计算余数服务
     mov bl,2		;求从2到100的素数、素数个数、素数的和，bl从2到100变化
next11:
     cmp bl,100		;如果bl大于100就跳转到rt
     ja rt
     mov dl,2		;如果BL不能被DL从2到BL-1整除的话，则BL为素数
next12:
     cmp dl,bl		;if(dl>=bl) 是素数   jump next13
     jae next13
     mov ax,bx
     div dl			;除以dl (8 bits)
     cmp ah,0		;不是素数,即为合数   jump next14  ah是余数
     jz next14
     inc dl			;dl++,继续找下一个除数
     jmp next12		;短转 next12
next13:
     inc count		;是素数，则将个数加1
     add sum,bx		;是素数,则加到和中
     mov [di],bl	;是素数，则存入相应单元中
     inc di
next14:
     inc bl			;bl++,继续测试下一个数
     jmp next11
rt:
     ret
Calculate endp



;显示素数
showsushu proc near
     mov si,offset sushu
     mov cx,count
next21:
     mov ax,count	;每行10个素数
     sub ax,cx	;ax - cx
     mov bl,10
     div bl		;判断能不能被10整除
     cmp ah,0	;if(al%bl==0)	jump next22
     jnz next22
     mov dl,0dh		;每行10个素数，行末加回车换行
     mov ah,02h
     int 21h
     mov dl,0ah		;加换行
     mov ah,02h
     int 21h
next22:
     mov bl,[si]	;取出一个素数，call disp10 都是将bx作为参数传递进去
     mov bh,0	;后面有余数处理，以免引起错误
     call disp10	;以十进制形式输出
     mov dl,20h		;每个素数之间加一个空格，便于区分
     mov ah,2
     int 21h
     call delay		;每输出一个素数都有数秒的停顿，延时子程序
     inc si			;字符指针后移
     loop next21		;cx 不为0，跳回next21
     ret
showsushu endp



;显示count	千万注意bx不能变
showcount proc near
     mov bx,count	;取出素数个数
     call disp10	;以十进制形式输出
     ret
showcount endp



;显示sum	千万注意bx不能变
showsum proc near
     mov bx,sum		;取出素数的和
     call disp10	;以十进制形式输出
     ret
showsum endp


;将BX中的数以十进制形式输出
disp10 proc near
     push cx
     mov cx,1000d	;每次去掉最高位，比如 5121 ，经过一个 div 1000d 之后就是121了
     call Div10
     mov cx,100d
     call Div10
     mov cx,10d
     call Div10
     mov cx,1d
     call Div10
     pop cx
     ret
disp10 endp

Div10 proc near
     mov ax,bx	;ax = bx
     mov dx,0	;余数置0
     div cx		;ax = dx/cx    dx = 余数	如：ax = (5121/1000) == 0005   dx = 121
     mov bx,dx	;把dx赋给bx存起来返回
     mov dl,al	;输出al里值	如：05
     add dl,30h
     mov ah,2
     int 21h
     ret
Div10 endp



;延时子程序
delay proc near 
     push cx			;保存原值cx
     push ax			;保存原值ax
     mov ax,60000
next1:
     mov cx,6000
next2:
     loop next2
     dec ax
     jnz next1
     pop ax
     pop cx
     ret
delay endp



;退出系统的子程序
exit proc near
      mov ah,4ch
      int 21h
exit endp

code ENDS
	END MAIN
    