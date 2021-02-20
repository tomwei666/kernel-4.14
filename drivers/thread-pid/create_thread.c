#include <linux/module.h>
#include <linux/init.h>
#include <asm/sysreg.h>
#include <linux/sched/task.h>
#include <asm/thread_info.h>


register unsigned long current_stack_pointer asm ("sp");
static inline struct task_struct *current_task_spel1(void) __attribute_const__;
static inline struct task_struct *current_task_spel1(void)
{
	void *stack1 =(void *)(current_stack_pointer & ~(THREAD_SIZE - 1));
	struct task_struct * task_tmp = container_of(stack1, struct task_struct, stack);
	return task_tmp;
}
static inline void *current_thread_info2(void)
{
    return (void *)
        (current_stack_pointer & ~(THREAD_SIZE - 1));
}

int kthread_fn(void *unsed)
{
	/*1. get task_struct from current function*/
	printk(KERN_ERR "tom F=%s L=%d current->pid=%d\n",__func__,__LINE__,current->pid);
	/*struct thread_info *ti = current_thread_info();*/

	/*2. get task_struct from sp_el1 stack*/
	struct task_struct * task_tmp = current_task_spel1();
	printk(KERN_ERR "tom F=%s L=%d pid from sp_el1=%d\n",__func__,__LINE__,task_tmp->pid);

	/*3. get stack from two method: 1.current->stac(from sp_el0) 2. from sp_el1*/
	printk(KERN_ERR "tom F=%s L=%d current->stack=%llx\n",__func__,__LINE__,current->stack);
	printk(KERN_ERR "tom F=%s L=%d current->stack=%llx\n",__func__,__LINE__,(current_stack_pointer & ~(THREAD_SIZE - 1)));
	printk(KERN_ERR "tom F=%s L=%d current->stack=%llx\n",__func__,__LINE__,task_tmp->stack);

	
	return 0;
}
static int __init thread_pid_init(void)
{
	int pid;
	pid = kernel_thread(kthread_fn,NULL , CLONE_FS | CLONE_FILES);
	printk(KERN_ERR "tom F=%s pid=%d\n",__func__,pid);
	return 0;
}

static void __exit thread_pid_exit(void)
{
	printk("tom thread_pid_exit\n");
}

module_init(thread_pid_init);
module_exit(thread_pid_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("tom");
MODULE_DESCRIPTION("my test kernel module");
MODULE_ALIAS("mytest");

