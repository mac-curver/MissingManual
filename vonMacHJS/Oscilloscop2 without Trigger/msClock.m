unsigned long   startTime = 0;unsigned long	msClock(void){	UnsignedWide microTickCount;							// 2 * unsigned long		Microseconds(&microTickCount);							// for this external routine we need the Carbon.framework	// 4294960 = (0x100000000/1000)	return microTickCount.lo/1000 + microTickCount.hi*4294960 - startTime;					}void	msClockReset(void){	startTime = 0;	startTime = msClock();}