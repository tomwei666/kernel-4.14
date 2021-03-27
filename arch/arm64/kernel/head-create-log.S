PGDIR_SHIFT=0x27 PMD_SHIFT=15 PUD_SHIFT=1e PAGE_SHIFT=c

PGDIR_SHIFT=39 PUD_SHIFT=30 PMD_SHIFT=21 PAGE_SHIFT=12
WAPPER_PGTABLE_LEVELS=3 SWAPPER_TABLE_SHIFT=30

PMD_SHIFT=21 PUD_SHIFT=1e PAGE_SHIFT=c
PAGE_SHIFT=

x14-uart base

0x900
000
x15-打印字符

x17-tpm1
x22-tpm2

x25-tpm3
x26
x27

init_uart:                                                                         
#ifdef EARLY_PRINTK_INIT_UART                                                      
        early_uart_init x23, 0                                                     
#endif                                                                             
        adr   x0, 1f                                                               
        b     puts                                                                 
1:      .asciz "- UART enabled -\r\n"                                              
        .align 4                                                                   
                                                                                   
/* Print early debug messages.                                                     
 * x0: Nul-terminated string to print.                                             
 * x23: Early UART base address                                                    
 * Clobbers x0-x1 */                                                               
puts:                                                                              
        early_uart_ready x23, 1                                                    
        ldrb  w1, [x0], #1           /* Load next char */                          
        cbz   w1, 1f                 /* Exit on nul */                             
        early_uart_transmit x23, w1                                                
        b     puts                                                                                                                                                                                                                                     
1:                                                                                 
        ret 

x14-uart base

0x900000
x15-打印字符


/* Print early debug messages.                                                     
 * x0: Nul-terminated string to print.                                             
 * x23: Early UART base address                                                    
 * Clobbers x0-x1 */                                                               
puts:                                                                              
        early_uart_ready x23, 1                                                    
        ldrb  w1, [x0], #1           /* Load next char */                          
        cbz   w1, 1f                 /* Exit on nul */                             
        early_uart_transmit x23, w1                                                
        b     puts                                                                                                                                                                                                                                     
1:                                                                                 
        ret 



x14-uart base

0x900000
x15-打印字符

x17-tpm1
x22-tpm2
x25-tpm3





x0-x15
x23-x14
x1-x17
x2-x22
x3-x25

/* Print a 32-bit number in hex.  Specific to the PL011 UART.                   
 * x15: Number to print.                                                         
 * x14: Early UART base address                                                 
 * Clobbers x15,x17,x22,x25 */                                                            
putn:                                                                           
        adr   x17, hex                                                           
        mov   x25, #8                                                            
1:                                                                              
        early_uart_ready x14, 2                                                 
        and   x22, x15, #0xf0000000    /* Mask off the top nybble */              
        lsr   x22, x22, #28                                                       
        ldrb  w22, [x17, x22]           /* Convert to a char */                    
        early_uart_transmit x14, w22                                             
        lsl   x15, x15, #4             /* Roll it through one nybble at a time */ 
        subs  x25, x25, #1                                                        
        b.ne  1b                                                                
        ret                                                                     
hex:    .ascii "0123456789abcdef"                                               
        .align 2



第一个页表：
tbl=x0=0x410a4000 virt=0x409af000
PGDIR_SHIFT=39 SWAPPER_TABLE_SHIFT=30
SWAPPER_PGTABLE_LEVELS=2
.macro  create_pgd_entry, tbl, virt, tmp1, tmp2                                                                                                                                                                                                    
create_table_entry \tbl, \virt, PGDIR_SHIFT, PTRS_PER_PGD, \tmp1, \tmp2 
				   0x410a4000 0x409af000 39

    .macro  create_table_entry, tbl, virt, shift, ptrs, tmp1, tmp2              
    lsr \tmp1, \virt, #\shift             // tmp1=0                                   
    and \tmp1, \tmp1, #\ptrs - 1          //  tmp1=0                              
    add \tmp2, \tbl, #PAGE_SIZE           //  tmp2=0x410a5000                                         
    orr \tmp2, \tmp2, #PMD_TYPE_TABLE    // tmp2=0x410a5003 
    str \tmp2, [\tbl, \tmp1, lsl #3]     // [0x410a4000]=0x410a5003                                     
    add \tbl, \tbl, #PAGE_SIZE      // x0=tbl=0x410a5000              
.endm   
                                               
create_table_entry \tbl, \virt, SWAPPER_TABLE_SHIFT, PTRS_PER_PTE, \tmp1, \tmp2   
                    0x410a5000 0x409af000 30 
    .macro  create_table_entry, tbl, virt, shift, ptrs, tmp1, tmp2              
    lsr \tmp1, \virt, #\shift           // tmp1=1                                              
    and \tmp1, \tmp1, #\ptrs - 1        // tmp1=1                            
    add \tmp2, \tbl, #PAGE_SIZE         // tmp2=0x410a6000                                      
    orr \tmp2, \tmp2, #PMD_TYPE_TABLE   // tmp2=0x410a6003
    str \tmp2, [\tbl, \tmp1, lsl #3]    // [0x410a5008]=0x410a6003                                    
    add \tbl, \tbl, #PAGE_SIZE          // x0=tbl=0x410a6000                
    .endm                                                                
.endm

1 x0=00000000410a6000
1 x7=0000000000000711
1 x3=00000000409af000
1 x5=00000000409af000
1 x6=00000000409af508

x0=00000000410a6000 x7=0000000000000711 x3=00000000409af000
x5=00000000409af000 x6=00000000409af508 SWAPPER_BLOCK_SHIFT=21
    create_block_map x0, x7, x3, x5, x6
    .macro  create_block_map, tbl(x0),    flags(x7), phys(x3),  start(x5),   end(x7)
         	                  0x410a6000  0x711     0x409af000  0x409af000   0x409af508
    lsr \phys, \phys, #SWAPPER_BLOCK_SHIFT       //x3=phys=phys>>21=0x204                        
    lsr \start, \start, #SWAPPER_BLOCK_SHIFT     //start=start>>21=0x204     
    and \start, \start, #PTRS_PER_PTE - 1   // start=4                   
    orr \phys, \flags, \phys, lsl #SWAPPER_BLOCK_SHIFT  // phys=409af711       
    lsr \end, \end, #SWAPPER_BLOCK_SHIFT               //  end=0x204                    
    and \end, \end, #PTRS_PER_PTE - 1                  //   end=0x4                 
9999:   str \phys, [\tbl, \start, lsl #3]       // 0:  [0x410a6000+32]=0x409af711          
    add \start, \start, #1          // start=5                              
    add \phys, \phys, #SWAPPER_BLOCK_SIZE       // phys= phys+2M             
    cmp \start, \end        //5<4结束                                                    
    b.ls    9999b                                                               
    .endm
	
	x5=0x409af000

第二个页表:
x0=0x00000000410a7000 x5=0xffff000008080000
.macro  create_pgd_entry, tbl, virt, tmp1, tmp2

create_table_entry \tbl, \virt, PGDIR_SHIFT, PTRS_PER_PGD, \tmp1, \tmp2 
				   0x410a7000 0xffff000008080000 39

    .macro  create_table_entry, tbl, virt, shift, ptrs, tmp1, tmp2              
    lsr \tmp1, \virt, #\shift             // tmp1=0                                   
    and \tmp1, \tmp1, #\ptrs - 1          //  tmp1=0                              
    add \tmp2, \tbl, #PAGE_SIZE           //  tmp2=0x410a8000                                        
    orr \tmp2, \tmp2, #PMD_TYPE_TABLE    // tmp2=0x410a8003
    str \tmp2, [\tbl, \tmp1, lsl #3]     // [0x410a7000]=0x410a8003                                    
    add \tbl, \tbl, #PAGE_SIZE      // x0=tbl=0x410a8000              
.endm   

create_table_entry \tbl, \virt, SWAPPER_TABLE_SHIFT, PTRS_PER_PTE, \tmp1, \tmp2   
                    0x410a8000 0xffff000008080000 30 
    .macro  create_table_entry, tbl, virt, shift, ptrs, tmp1, tmp2              
    lsr \tmp1, \virt, #\shift           // tmp1=0                                              
    and \tmp1, \tmp1, #\ptrs - 1        // tmp1=0                           
    add \tmp2, \tbl, #PAGE_SIZE         // tmp2=410a9000                                    
    orr \tmp2, \tmp2, #PMD_TYPE_TABLE   // tmp2=410a9003
    str \tmp2, [\tbl, \tmp1, lsl #3]    // [0x410a8000]=0x410a9003                                    
    add \tbl, \tbl, #PAGE_SIZE          // x0=tbl=0x410a9000                
    .endm                                                                
.endm

x0=00000000410a9000 x7=0000000000000711 x3=0000000040080000
x5=ffff000008080000 x6=ffff0000090aa000 SWAPPER_BLOCK_SHIFT=21

    create_block_map x0, x7, x3, x5, x6
    .macro  create_block_map, tbl(x0),    flags(x7),  phys(x3),      start(x5),          end(x6)
         	                  0x410a9000    0x711     0x40080000     0xffff000008080000  0xffff0000090aa000
    lsr \phys, \phys, #SWAPPER_BLOCK_SHIFT        //x3=phys=phys>>21=0x200                        
    lsr \start, \start, #SWAPPER_BLOCK_SHIFT     //start=0xFFFF FFFF F800 0040
    and \start, \start, #PTRS_PER_PTE - 1        // start=0x40              
    orr \phys, \flags, \phys, lsl #SWAPPER_BLOCK_SHIFT  // phys=0x40080711       
    lsr \end, \end, #SWAPPER_BLOCK_SHIFT               //  end= FFFF FFFF F800 0048                  
    and \end, \end, #PTRS_PER_PTE - 1                  //  end=0x48
	
9999:   str \phys, [\tbl, \start, lsl #3]       // 1:  [0x410a9000+0x40*8]=0x40080711          
    add \start, \start, #1                      // 1: start=0x41                              
    add \phys, \phys, #SWAPPER_BLOCK_SIZE       // 1: phys= 0x40080711+0x200000*1= 0x40280711            
    cmp \start, \end                                                       
    b.ls    9999b                                                               
    .endm
[0x410a9000+0x48*8]=0x40080711+(8-1)*0x200000=0x40080711+0x1C00000=0x41C80711
