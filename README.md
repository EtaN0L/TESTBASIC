BASIC Inspired compiler (does nothing remotely related, may as well be just a name)

Here are the things it could do(if it worked):

OPERATIONS
CONTROL FLOW(IF ELSE)
COMMENTS(ALSO MULTI-LINE)


EXAMPLE:


```
START
	a = 2.21
	b = 3.17
	c = a + b - 1.2 * 3
	
	print(a)
	print(b)
	print(c)
	print(2 * 3^2 - a)
	
END
```



TODO: add line number recognition to written programs, would make GOTO easy(like in BASIC)

HOW IT WOULD BE:
```
10  START
20  	a = 2.21
30  	b = 3.17
40  	c = a + b - 1.2 * 3
50  	print(a)
60  	print(b)
70  	print(c)
80    	print(2 * 3^2 - a)	
90  END
```

With this, GOTO would be simple to implement, a while(1){printf("SOMETHING")}; would be:
```
10 PRINT "SOMETHING"
20 GOTO 10
```